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

  /// Fetch NL-to-Cypher result from the quick_search polling endpoint.
  /// Called when the streaming quick_search response includes a
  /// `type: "nl_to_cypher"` chunk with a `result_key`.
  Future<GraphSearchResult?> fetchNlToCypherResult(String resultKey) async {
    _loadingSubject.add(true);
    _errorSubject.add(null);

    try {
      final baseUrl = DeveloperModeService.instance.getEffectiveApiUrl();
      final url = '$baseUrl/quick_search/nl_to_cypher_result/?result_key=$resultKey';

      // Poll until status is "completed" or we timeout
      const maxAttempts = 30;
      const pollInterval = Duration(seconds: 3);

      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        final response = await _client.get(
          url,
          options: Options(
            headers: {'accept': 'application/json'},
            validateStatus: (status) => status != null && status < 500,
          ),
        );

        // HTTP 202 = still processing, keep polling
        if (response.statusCode == 202) {
          await Future.delayed(pollInterval);
          continue;
        }

        if (response.statusCode == 200 && response.data != null) {
          final responseData = response.data is Map<String, dynamic>
              ? response.data as Map<String, dynamic>
              : <String, dynamic>{};

          final status = responseData['status'] as String? ?? '';

          if (status == 'completed') {
            final result = GraphSearchResult.fromWrapperJson(responseData);
            _resultSubject.add(result);
            _loadingSubject.add(false);
            return result;
          } else if (status == 'error' || status == 'failed') {
            final errorMsg = responseData['error']?.toString() ?? 'Graph query failed';
            _errorSubject.add(errorMsg);
            _loadingSubject.add(false);
            return null;
          }

          // Status is "pending" or "queued" — wait and retry
          await Future.delayed(pollInterval);
        } else if (response.statusCode == 404) {
          _errorSubject.add('Graph result not found or expired');
          _loadingSubject.add(false);
          return null;
        } else if (response.statusCode == 400) {
          _errorSubject.add('Invalid query for graph search');
          _loadingSubject.add(false);
          return null;
        } else {
          _errorSubject.add('Graph query failed (${response.statusCode})');
          _loadingSubject.add(false);
          return null;
        }
      }

      _errorSubject.add('Graph query timed out after polling');
      _loadingSubject.add(false);
      return null;
    } on DioException catch (e) {
      String errorMsg;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMsg = 'Request timed out.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMsg = 'Could not connect to the server.';
      } else {
        errorMsg = 'Network error: ${e.message ?? 'Unknown error'}';
      }
      _errorSubject.add(errorMsg);
      _loadingSubject.add(false);
      return null;
    } catch (e) {
      _logger.e('Graph poll error', error: e);
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
