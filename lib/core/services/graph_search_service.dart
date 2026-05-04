import 'dart:async';
import 'package:dharak_flutter/app/data/services/developer_mode_service.dart';
import 'package:dharak_flutter/core/models/graph_search_result.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:rxdart/rxdart.dart';

/// Service for NL-to-Cypher (Knowledge Graph) queries.
/// Only used in developer mode — the Graph tab in QuickSearch.
///
/// Uses its own Dio instance (like UnifiedSearchApiPointSimple) because
/// the shared Modular Dio has connectTimeout=0 which causes instant failures.
class GraphSearchService {
  static final GraphSearchService _instance = GraphSearchService._internal();
  static GraphSearchService get instance => _instance;

  GraphSearchService._internal();

  final Logger _logger = Logger();

  final Dio _client = Dio(BaseOptions(
    contentType: 'application/json',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 90),
    sendTimeout: const Duration(seconds: 30),
  ));

  final BehaviorSubject<GraphSearchResult?> _resultSubject =
      BehaviorSubject.seeded(null);
  Stream<GraphSearchResult?> get resultStream => _resultSubject.stream;
  GraphSearchResult? get currentResult => _resultSubject.valueOrNull;

  final BehaviorSubject<bool> _loadingSubject = BehaviorSubject.seeded(false);
  Stream<bool> get isLoadingStream => _loadingSubject.stream;
  bool get isLoading => _loadingSubject.value;

  final BehaviorSubject<String?> _errorSubject = BehaviorSubject.seeded(null);
  Stream<String?> get errorStream => _errorSubject.stream;

  /// Execute a natural-language-to-Cypher query against the knowledge graph.
  Future<GraphSearchResult?> searchGraph(String query) async {
    if (query.trim().isEmpty) return null;

    _loadingSubject.add(true);
    _errorSubject.add(null);

    try {
      final baseUrl = DeveloperModeService.instance.getEffectiveApiUrl();

      final response = await _client.post(
        '$baseUrl/api/nl_to_cypher/',
        data: {
          'query': query.trim(),
          'provider': 'ollama',
        },
        options: Options(
          headers: {
            'accept': 'application/json',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final result = GraphSearchResult.fromJson(
          response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : {},
        );
        _resultSubject.add(result);
        _loadingSubject.add(false);
        return result;
      } else {
        final errorMsg =
            'Graph query failed (${response.statusCode})';
        _errorSubject.add(errorMsg);
        _loadingSubject.add(false);
        return null;
      }
    } on DioException catch (e) {
      String errorMsg;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMsg = 'Request timed out. The knowledge graph query may take longer for complex questions.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = 'Could not connect to the server. Check your network and custom domain.';
      } else {
        errorMsg = 'Network error: ${e.message ?? 'Unknown error'}';
      }
      _errorSubject.add(errorMsg);
      _loadingSubject.add(false);
      return null;
    } catch (e) {
      _logger.e('Graph search error', error: e);
      _errorSubject.add('An unexpected error occurred');
      _loadingSubject.add(false);
      return null;
    }
  }

  void clearResults() {
    _resultSubject.add(null);
    _errorSubject.add(null);
    _loadingSubject.add(false);
  }

  void dispose() {
    _resultSubject.close();
    _loadingSubject.close();
    _errorSubject.close();
  }
}
