import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dharak_flutter/app/data/services/developer_mode_service.dart';
import 'package:dharak_flutter/app/types/unified/unified_search_response.dart';
import 'package:dharak_flutter/flavors.dart';

class UnifiedSearchApiPointSimple {
  final Dio _dio = Dio();

  String get _baseUrl {
    // Use developer mode service to get effective URL
    return DeveloperModeService.instance.getEffectiveApiUrl();
  }

  /// Perform unified search using the quick_search endpoint
  Stream<UnifiedSearchResponse> unifiedSearch(String query) async* {
    final uri = Uri.parse('$_baseUrl/quick_search/');
    final url = uri.replace(queryParameters: {'query': query}).toString();

    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Accept': '*/*',
            'User-Agent': 'Dhara-Flutter-App',
          },
          responseType: ResponseType.stream,
        ),
      );

      final stream = response.data.stream as Stream<List<int>>;
      String buffer = '';

      await for (final chunk in stream) {
        buffer += utf8.decode(chunk);
        
        // Process complete lines
        final lines = buffer.split('\n');
        buffer = lines.removeLast(); // Keep incomplete line in buffer

        for (final line in lines) {
          final trimmedLine = line.trim();
          if (trimmedLine.isNotEmpty) {
            try {
              final json = jsonDecode(trimmedLine) as Map<String, dynamic>;
              yield UnifiedSearchResponse.fromJson(json);
            } catch (e) {
              // Skip unparseable lines
            }
          }
        }
      }

      // Process any remaining data in buffer
      if (buffer.trim().isNotEmpty) {
        try {
          final json = jsonDecode(buffer.trim()) as Map<String, dynamic>;
          yield UnifiedSearchResponse.fromJson(json);
        } catch (e) {
          // Skip unparseable final buffer
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Process unified search responses and organize them
  Future<UnifiedSearchResult> processUnifiedSearch(String query) async {
    UnifiedSplitsResponse? splits;
    List<UnifiedDefinitionResponse> definitions = [];
    UnifiedVerseResponse? verses;
    UnifiedChunkResponse? chunks;

    try {
      await for (final response in unifiedSearch(query)) {
        try {
          switch (response.type) {
            case 'splits':
              if (response.data is Map<String, dynamic>) {
                splits = UnifiedSplitsResponse.fromJson(
                  response.data as Map<String, dynamic>
                );
              }
              break;
            
            case 'definition':
              if (response.data is Map<String, dynamic>) {
                definitions.add(UnifiedDefinitionResponse.fromJson(
                  response.data as Map<String, dynamic>
                ));
              }
              break;
            
            case 'verse':
              try {
                if (response.data is Map<String, dynamic>) {
                  verses = UnifiedVerseResponse.fromJson(
                    response.data as Map<String, dynamic>
                  );
                } else if (response.data is List) {
                  // Handle verse data that comes as a list
                  verses = UnifiedVerseResponse.fromList(
                    response.data as List<dynamic>
                  );
                }
              } catch (e, stackTrace) {
                // Verse processing error
              }
              break;
            
            case 'chunk':
              if (response.data is Map<String, dynamic>) {
                chunks = UnifiedChunkResponse.fromJson(
                  response.data as Map<String, dynamic>
                );
              } else if (response.data is List) {
                // Handle chunk data that comes as a list
                chunks = UnifiedChunkResponse.fromList(
                  response.data as List<dynamic>
                );
              }
              break;
            
            default:
              break;
          }
        } catch (e) {
          // Error processing response
        }
      }
    } catch (e) {
      rethrow;
    }

    return UnifiedSearchResult(
      splits: splits,
      definitions: definitions,
      verses: verses,
      chunks: chunks,
    );
  }
}
