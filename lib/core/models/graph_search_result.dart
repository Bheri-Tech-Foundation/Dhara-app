import 'dart:convert';

/// Model for NL-to-Cypher (Knowledge Graph) API response.
/// Used exclusively in developer mode for the "Graph" search tab.
class GraphSearchResult {
  final String naturalLanguageQuery;
  final String cypherQuery;
  final String generationMethod;
  final List<GraphEntity> entities;
  final List<String> graphPaths;
  final List<String> canonicalPathSummary;
  final List<GraphSubgraph> graphSubgraphs;
  final String interpretation;
  final int resultCount;
  final bool dbModified;
  final String? modificationDetails;
  final String status;
  final String? error;
  final double? timeTaken;
  final Map<String, dynamic> rawJson;

  GraphSearchResult({
    required this.naturalLanguageQuery,
    required this.cypherQuery,
    required this.generationMethod,
    required this.entities,
    required this.graphPaths,
    this.canonicalPathSummary = const [],
    this.graphSubgraphs = const [],
    required this.interpretation,
    required this.resultCount,
    required this.dbModified,
    this.modificationDetails,
    required this.status,
    this.error,
    this.timeTaken,
    required this.rawJson,
  });

  String get rawJsonPretty {
    try {
      return const JsonEncoder.withIndent('  ').convert(rawJson);
    } catch (_) {
      return rawJson.toString();
    }
  }

  bool get isSuccess => status == 'success' && error == null;

  /// All unique relationships across all subgraphs.
  List<GraphRelationship> get allRelationships {
    final rels = <GraphRelationship>[];
    for (final sg in graphSubgraphs) {
      rels.addAll(sg.relationships);
    }
    return rels;
  }

  factory GraphSearchResult.fromJson(Map<String, dynamic> json) {
    final dbResults = json['db_results'] as List<dynamic>? ?? [];
    final entities = <GraphEntity>[];

    for (final result in dbResults) {
      if (result is Map<String, dynamic>) {
        for (final entry in result.entries) {
          final nodeData = entry.value;
          if (nodeData is Map<String, dynamic>) {
            entities.add(GraphEntity.fromJson(nodeData, role: entry.key));
          }
        }
      }
    }

    final subgraphsJson = json['graph_subgraphs'] as List<dynamic>? ?? [];
    final subgraphs = subgraphsJson
        .whereType<Map<String, dynamic>>()
        .map((sg) => GraphSubgraph.fromJson(sg))
        .toList();

    return GraphSearchResult(
      naturalLanguageQuery: json['natural_language_query'] as String? ?? '',
      cypherQuery: json['cypher_query'] as String? ?? '',
      generationMethod: json['generation_method'] as String? ?? 'unknown',
      entities: entities,
      graphPaths: (json['graph_paths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      canonicalPathSummary: (json['canonical_path_summary'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      graphSubgraphs: subgraphs,
      interpretation: json['interpretation'] as String? ?? '',
      resultCount: json['result_count'] as int? ?? 0,
      dbModified: json['db_modified'] as bool? ?? false,
      modificationDetails: json['modification_details'] as String?,
      status: json['status'] as String? ?? 'unknown',
      error: json['error'] as String?,
      rawJson: json,
    );
  }

  /// Create from the wrapper response that includes status_code and time_taken.
  factory GraphSearchResult.fromWrapperJson(Map<String, dynamic> wrapper) {
    final data = wrapper['data'] as Map<String, dynamic>? ?? wrapper;
    final result = GraphSearchResult.fromJson(data);
    final timeTaken = wrapper['time_taken'];
    return GraphSearchResult(
      naturalLanguageQuery: result.naturalLanguageQuery,
      cypherQuery: result.cypherQuery,
      generationMethod: result.generationMethod,
      entities: result.entities,
      graphPaths: result.graphPaths,
      canonicalPathSummary: result.canonicalPathSummary,
      graphSubgraphs: result.graphSubgraphs,
      interpretation: result.interpretation,
      resultCount: result.resultCount,
      dbModified: result.dbModified,
      modificationDetails: result.modificationDetails,
      status: result.status,
      error: result.error,
      timeTaken: timeTaken is num ? timeTaken.toDouble() : null,
      rawJson: wrapper,
    );
  }
}

class GraphEntity {
  final String role;
  final List<String> labels;
  final String name;
  final String summary;
  final String id;
  final int? neo4jId;

  GraphEntity({
    required this.role,
    required this.labels,
    required this.name,
    required this.summary,
    required this.id,
    this.neo4jId,
  });

  String get primaryLabel => labels.isNotEmpty ? labels.first : 'UNKNOWN';

  String get summaryPreview {
    final sentences = summary.split(RegExp(r'(?<=[.!?])\s+'));
    if (sentences.length <= 3) return summary;
    return '${sentences.take(3).join(' ')}...';
  }

  bool get hasLongSummary => summary.length > summaryPreview.length;

  factory GraphEntity.fromJson(Map<String, dynamic> json, {String role = ''}) {
    final labels = (json['labels'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final properties = json['properties'] as Map<String, dynamic>? ?? {};

    return GraphEntity(
      role: role,
      labels: labels,
      name: properties['name'] as String? ?? 'Unknown',
      summary: properties['summary'] as String? ?? '',
      id: properties['id'] as String? ?? '',
      neo4jId: properties['neo4j_id'] as int? ?? json['neo4j_id'] as int?,
    );
  }
}

/// A relationship between two nodes in the knowledge graph.
class GraphRelationship {
  final String type;
  final String? details;
  final int? neo4jId;
  final int? startNodeNeo4jId;
  final int? endNodeNeo4jId;

  GraphRelationship({
    required this.type,
    this.details,
    this.neo4jId,
    this.startNodeNeo4jId,
    this.endNodeNeo4jId,
  });

  factory GraphRelationship.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'] as Map<String, dynamic>? ?? {};
    return GraphRelationship(
      type: json['type'] as String? ?? 'RELATED_TO',
      details: properties['details'] as String?,
      neo4jId: json['neo4j_id'] as int?,
      startNodeNeo4jId: json['start_node_neo4j_id'] as int?,
      endNodeNeo4jId: json['end_node_neo4j_id'] as int?,
    );
  }
}

/// A subgraph containing nodes and their relationships.
class GraphSubgraph {
  final List<GraphEntity> nodes;
  final List<GraphRelationship> relationships;

  GraphSubgraph({
    required this.nodes,
    required this.relationships,
  });

  factory GraphSubgraph.fromJson(Map<String, dynamic> json) {
    final nodesJson = json['nodes'] as List<dynamic>? ?? [];
    final relsJson = json['relationships'] as List<dynamic>? ?? [];

    return GraphSubgraph(
      nodes: nodesJson
          .whereType<Map<String, dynamic>>()
          .map((n) => GraphEntity.fromJson(n))
          .toList(),
      relationships: relsJson
          .whereType<Map<String, dynamic>>()
          .map((r) => GraphRelationship.fromJson(r))
          .toList(),
    );
  }
}

// ============================================================================
// Semantic KG Retrieval Models (POST /api/semantic_retrieval_kg/)
// ============================================================================

const List<String> kgDomains = [
  'epic',
  'purana',
  'mahabharata',
  'bhagavadgita',
  'ayurveda',
  'dharmashastra',
  'natyashastra',
  'agni_purana',
];

const Map<String, String> kgDomainLabels = {
  'epic': 'Epic',
  'purana': 'Purana',
  'mahabharata': 'Mahabharata',
  'bhagavadgita': 'Bhagavad Gita',
  'ayurveda': 'Ayurveda',
  'dharmashastra': 'Dharmashastra',
  'natyashastra': 'Natyashastra',
  'agni_purana': 'Agni Purana',
};

class KgRetrievalResult {
  final String query;
  final String answer;
  final String? interpretation;
  final String? interpretationId;
  final String interpretationStatus;
  final String strategyUsed;
  final double confidence;
  final List<KgGraphRelation> graphResults;
  final List<dynamic> chunkResults;
  final List<KgSource> sources;
  final List<String> cypherQueries;
  final String status;
  final String? error;
  final Map<String, dynamic> rawJson;

  KgRetrievalResult({
    required this.query,
    required this.answer,
    this.interpretation,
    this.interpretationId,
    this.interpretationStatus = 'pending',
    this.strategyUsed = 'unknown',
    this.confidence = 0.0,
    this.graphResults = const [],
    this.chunkResults = const [],
    this.sources = const [],
    this.cypherQueries = const [],
    required this.status,
    this.error,
    required this.rawJson,
  });

  bool get isSuccess => status == 'success' && error == null;
  bool get isInterpretationReady => interpretationStatus == 'ready';
  bool get isInterpretationPending => interpretationStatus == 'pending';

  String get rawJsonPretty {
    try {
      return const JsonEncoder.withIndent('  ').convert(rawJson);
    } catch (_) {
      return rawJson.toString();
    }
  }

  KgRetrievalResult copyWithInterpretation(String newInterpretation) {
    return KgRetrievalResult(
      query: query,
      answer: answer,
      interpretation: newInterpretation,
      interpretationId: interpretationId,
      interpretationStatus: 'ready',
      strategyUsed: strategyUsed,
      confidence: confidence,
      graphResults: graphResults,
      chunkResults: chunkResults,
      sources: sources,
      cypherQueries: cypherQueries,
      status: status,
      error: error,
      rawJson: rawJson,
    );
  }

  factory KgRetrievalResult.fromJson(Map<String, dynamic> json) {
    final graphResultsList = (json['graph_results'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((r) => KgGraphRelation.fromJson(r))
        .toList();

    final sourcesList = (json['sources'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map((s) => KgSource.fromJson(s))
        .toList();

    final cypherList = (json['cypher_queries'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return KgRetrievalResult(
      query: json['query'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      interpretation: json['interpretation'] as String?,
      interpretationId: json['interpretation_id'] as String?,
      interpretationStatus: json['interpretation_status'] as String? ?? 'pending',
      strategyUsed: json['strategy_used'] as String? ?? 'unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      graphResults: graphResultsList,
      chunkResults: json['chunk_results'] as List<dynamic>? ?? [],
      sources: sourcesList,
      cypherQueries: cypherList,
      status: json['status'] as String? ?? 'unknown',
      error: json['error'] as String?,
      rawJson: json,
    );
  }
}

class KgGraphRelation {
  final String source;
  final String relation;
  final String target;
  final String targetId;
  final List<String> targetLabels;
  final String evidence;
  final String chunkId;
  final double? sourceConfidence;

  KgGraphRelation({
    required this.source,
    required this.relation,
    required this.target,
    this.targetId = '',
    this.targetLabels = const [],
    this.evidence = '',
    this.chunkId = '',
    this.sourceConfidence,
  });

  String get primaryLabel => targetLabels.isNotEmpty ? targetLabels.first : 'UNKNOWN';

  factory KgGraphRelation.fromJson(Map<String, dynamic> json) {
    return KgGraphRelation(
      source: json['source'] as String? ?? '',
      relation: json['relation'] as String? ?? 'RELATED_TO',
      target: json['target'] as String? ?? '',
      targetId: json['target_id'] as String? ?? '',
      targetLabels: (json['target_labels'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      evidence: json['evidence'] as String? ?? '',
      chunkId: json['chunk_id'] as String? ?? '',
      sourceConfidence: (json['source_confidence'] as num?)?.toDouble(),
    );
  }
}

class KgSource {
  final String chunkId;
  final String text;
  final String evidence;
  final String type;

  KgSource({
    required this.chunkId,
    required this.text,
    this.evidence = '',
    this.type = 'graph',
  });

  String get textPreview {
    if (text.length <= 200) return text;
    return '${text.substring(0, 200)}...';
  }

  bool get hasLongText => text.length > 200;

  factory KgSource.fromJson(Map<String, dynamic> json) {
    return KgSource(
      chunkId: json['chunk_id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      evidence: json['evidence'] as String? ?? '',
      type: json['type'] as String? ?? 'graph',
    );
  }
}
