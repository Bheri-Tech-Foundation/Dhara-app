import 'dart:convert';

/// Model for NL-to-Cypher (Knowledge Graph) API response.
/// Used exclusively in developer mode for the "Graph" search tab.
class GraphSearchResult {
  final String naturalLanguageQuery;
  final String cypherQuery;
  final String generationMethod;
  final List<GraphEntity> entities;
  final List<String> graphPaths;
  final String interpretation;
  final int resultCount;
  final bool dbModified;
  final String? modificationDetails;
  final String status;
  final String? error;
  final Map<String, dynamic> rawJson;

  GraphSearchResult({
    required this.naturalLanguageQuery,
    required this.cypherQuery,
    required this.generationMethod,
    required this.entities,
    required this.graphPaths,
    required this.interpretation,
    required this.resultCount,
    required this.dbModified,
    this.modificationDetails,
    required this.status,
    this.error,
    required this.rawJson,
  });

  /// Pretty-printed JSON string for display.
  String get rawJsonPretty {
    try {
      return const JsonEncoder.withIndent('  ').convert(rawJson);
    } catch (_) {
      return rawJson.toString();
    }
  }

  bool get isSuccess => status == 'success' && error == null;

  factory GraphSearchResult.fromJson(Map<String, dynamic> json) {
    final dbResults = json['db_results'] as List<dynamic>? ?? [];
    final entities = <GraphEntity>[];

    for (final result in dbResults) {
      if (result is Map<String, dynamic>) {
        // The key is the variable name from the Cypher RETURN clause (e.g. "killer")
        for (final entry in result.entries) {
          final nodeData = entry.value;
          if (nodeData is Map<String, dynamic>) {
            entities.add(GraphEntity.fromJson(nodeData, role: entry.key));
          }
        }
      }
    }

    return GraphSearchResult(
      naturalLanguageQuery: json['natural_language_query'] as String? ?? '',
      cypherQuery: json['cypher_query'] as String? ?? '',
      generationMethod: json['generation_method'] as String? ?? 'unknown',
      entities: entities,
      graphPaths: (json['graph_paths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      interpretation: json['interpretation'] as String? ?? '',
      resultCount: json['result_count'] as int? ?? 0,
      dbModified: json['db_modified'] as bool? ?? false,
      modificationDetails: json['modification_details'] as String?,
      status: json['status'] as String? ?? 'unknown',
      error: json['error'] as String?,
      rawJson: json,
    );
  }
}

class GraphEntity {
  final String role;
  final List<String> labels;
  final String name;
  final String summary;
  final String id;

  GraphEntity({
    required this.role,
    required this.labels,
    required this.name,
    required this.summary,
    required this.id,
  });

  String get primaryLabel => labels.isNotEmpty ? labels.first : 'UNKNOWN';

  /// First 2-3 sentences for preview display.
  String get summaryPreview {
    final sentences = summary.split(RegExp(r'(?<=[.!?])\s+'));
    if (sentences.length <= 3) return summary;
    return '${sentences.take(3).join(' ')}...';
  }

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
    );
  }
}
