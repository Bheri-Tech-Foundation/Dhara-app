import 'dart:async';
import 'dart:convert';

import 'package:dharak_flutter/app/data/services/developer_mode_service.dart';
import 'package:dharak_flutter/app/types/books/book_chunk.dart';
import 'package:dharak_flutter/app/types/dhara_insights/dhara_insight_chunk.dart';
import 'package:dharak_flutter/app/types/dictionary/word_definitions.dart';
import 'package:dharak_flutter/app/types/unified/unified_response.dart';
import 'package:dharak_flutter/app/types/verse/verse.dart';
import 'package:dharak_flutter/core/cache/smart_search_cache.dart';
import 'package:dharak_flutter/core/services/graph_search_service.dart';
import 'package:dharak_flutter/core/services/verse_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:rxdart/rxdart.dart';

class UnifiedService {
  static final UnifiedService _instance = UnifiedService._internal();
  static UnifiedService get instance => _instance;
  UnifiedService._internal();

  Dio? _dio;
  
  // Use developer mode service to get effective URL
  String get _baseUrl => DeveloperModeService.instance.getEffectiveApiUrl();
  
  // Get the configured Dio instance with auth interceptors
  Dio get dio {
    _dio ??= Modular.get<Dio>();
    return _dio!;
  }

  // Track search sessions (incremented each time user clicks send)
  int _currentSearchSessionId = 0;
  
  // Verse response counter to ensure unique queries
  int _verseResponseCounter = 0;

  // Reactive streams for current search results
  final BehaviorSubject<List<UnifiedSearchResult>> _currentResults = 
      BehaviorSubject<List<UnifiedSearchResult>>.seeded([]);

  // Stream to track loading state
  final BehaviorSubject<bool> _isLoading = BehaviorSubject<bool>.seeded(false);
  
  // Stream to track if API is still streaming responses
  final BehaviorSubject<bool> _isStreaming = BehaviorSubject<bool>.seeded(false);

  // Stream getters
  Stream<List<UnifiedSearchResult>> get currentResults => _currentResults.stream;
  Stream<bool> get isLoading => _isLoading.stream;
  Stream<bool> get isStreaming => _isStreaming.stream;

  // Current values
  List<UnifiedSearchResult> get currentResultsValue => _currentResults.value;
  bool get isLoadingValue => _isLoading.value;

  /// Perform unified search with streaming response
  Future<void> searchUnified(String query, {bool forceRefresh = false}) async {
    if (query.trim().isEmpty) {
      return;
    }

    // Increment search session ID for new search
    _currentSearchSessionId++;
    final currentSessionId = _currentSearchSessionId;
    
    // Reset verse counter for new search
    _verseResponseCounter = 0;
    
    _currentResults.add([]);

    try {
      _isLoading.add(true);
      _isStreaming.add(true);
      
      // Check cache first (unless force refresh is requested)
      if (!forceRefresh) {
        final cachedResult = SmartSearchCache.instance.getUnifiedResult(query);
        if (cachedResult != null) {
        
        // ✅ FIX: Decompose cached result into individual tool results
        // Instead of adding the combined result, recreate individual tool cards
        
        // 1. Create definition result if exists
        if (cachedResult.hasDefinition) {
          final definitionResult = UnifiedSearchResult(
            query: cachedResult.definition!.givenWord ?? query,
            originalQuery: query, // Store original user query for Prashna
            timestamp: DateTime.now(),
            searchSessionId: currentSessionId, // ✅ NEW session ID
            splits: cachedResult.splits,
            definition: cachedResult.definition,
            queryId: cachedResult.queryId, // ✅ Preserve queryId from cache
            itemId: cachedResult.itemId, // ✅ Preserve itemId from cache
          );
          _addOrUpdateResult(definitionResult);
        }
        
        // 2. Create verse result if exists  
        if (cachedResult.hasVerses) {
          String verseQuery = query;
          if (cachedResult.splits != null && cachedResult.splits!.quotedTexts.isNotEmpty) {
            verseQuery = '"${cachedResult.splits!.quotedTexts.join('", "')}"';
          }
          
          final verseResult = UnifiedSearchResult(
            query: verseQuery,
            originalQuery: query, // Store original user query for Prashna
            timestamp: DateTime.now(),
            searchSessionId: currentSessionId, // ✅ NEW session ID
            splits: cachedResult.splits,
            verses: cachedResult.verses,
            outputScript: cachedResult.outputScript,
            queryId: cachedResult.queryId, // ✅ Preserve queryId from cache
            itemId: cachedResult.itemId, // ✅ Preserve itemId from cache
          );
          _addOrUpdateResult(verseResult);
          
          // Add verses to VerseService cache for interaction
          final verseService = VerseService.instance;
          for (var verse in cachedResult.verses!) {
            verseService.addVerseToCache(verse);
          }
        }
        
        // 3. Create chunk result if exists
        if (cachedResult.hasChunks) {
          String chunkQuery = query;
          if (cachedResult.splits != null && cachedResult.splits!.heritageQuery.isNotEmpty) {
            chunkQuery = cachedResult.splits!.heritageQuery;
          }
          
          final chunkResult = UnifiedSearchResult(
            query: chunkQuery,
            originalQuery: query, // Store original user query for Prashna
            timestamp: DateTime.now(),
            searchSessionId: currentSessionId, // ✅ NEW session ID
            splits: cachedResult.splits,
            chunks: cachedResult.chunks,
            queryId: cachedResult.queryId, // ✅ Preserve queryId from cache
            itemId: cachedResult.itemId, // ✅ Preserve itemId from cache
          );
          _addOrUpdateResult(chunkResult);
        }
        
          _isLoading.add(false);
          _isStreaming.add(false);
          return;
        }
      }

      // Prepare new result container
      final newResult = UnifiedSearchResult(
        query: query,
        originalQuery: query, // Store original user query for Prashna
        timestamp: DateTime.now(),
        searchSessionId: currentSessionId,
      );

      // Add empty result first (will be updated as we receive data)
      _addOrUpdateResult(newResult);

      // Start streaming request - let auth interceptor handle authentication
      final encodedQuery = Uri.encodeComponent(query);
      final url = '$_baseUrl/quick_search/?query=$encodedQuery';

      // Use configured Dio instance which will automatically add auth headers via interceptor
      final response = await dio.get<ResponseBody>(
        url,
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'accept': '*/*',
            'requiresToken': true, // Signal the auth interceptor to add auth headers
          },
        ),
      );

      if (response.data != null) {
        // ✅ FIX: Only process response if it's still from the current session
        if (currentSessionId == _currentSearchSessionId) {
          await _handleStreamingResponse(response.data!, query, newResult, currentSessionId);
        }
      }

    } catch (e) {
      _isLoading.add(false);
      _isStreaming.add(false);
      rethrow;
    }
  }

  /// Handle streaming response from unified API
  Future<void> _handleStreamingResponse(
    ResponseBody responseBody, 
    String query, 
    UnifiedSearchResult result,
    int currentSessionId
  ) async {
    UnifiedSearchResult currentResult = result;
    String buffer = '';

    await for (final bytes in responseBody.stream) {
      final chunk = utf8.decode(bytes);
      buffer += chunk;
      
      // Try to extract complete JSON objects
      while (buffer.isNotEmpty) {
        // Find start of JSON object
        final startIndex = buffer.indexOf('{');
        if (startIndex == -1) {
          buffer = '';
          break;
        }
        
        if (startIndex > 0) {
          buffer = buffer.substring(startIndex);
        }
        
        // Try to find the complete JSON object
        int braceCount = 0;
        int endIndex = -1;
        bool inString = false;
        bool escaped = false;
        
        for (int i = 0; i < buffer.length; i++) {
          final char = buffer[i];
          
          if (escaped) {
            escaped = false;
            continue;
          }
          
          if (char == '\\') {
            escaped = true;
            continue;
          }
          
          if (char == '"') {
            inString = !inString;
            continue;
          }
          
          if (!inString) {
            if (char == '{') {
              braceCount++;
            } else if (char == '}') {
              braceCount--;
              if (braceCount == 0) {
                endIndex = i;
                break;
              }
            }
          }
        }
        
        if (endIndex == -1) {
          // Incomplete JSON, wait for more data
          break;
        }
        
        final jsonString = buffer.substring(0, endIndex + 1);
        buffer = buffer.substring(endIndex + 1);
        
            try {
              // Fix Python-style single-quoted JSON to valid JSON with double quotes
              // Replace single quotes with double quotes, but be careful with apostrophes in text
              String normalizedJson = jsonString;
              if (jsonString.contains("'type':") || jsonString.startsWith("{'")){
                // This looks like Python dict format, normalize it
                normalizedJson = jsonString
                    .replaceAll("'", '"')  // Replace all single quotes with double quotes
                    .replaceAll('True', 'true')  // Python True -> JSON true
                    .replaceAll('False', 'false')  // Python False -> JSON false
                    .replaceAll('None', 'null');  // Python None -> JSON null
              }
              
              final jsonMap = jsonDecode(normalizedJson) as Map<String, dynamic>;
              final type = jsonMap['type'] as String?;
              final data = jsonMap['data'];
              final itemId = jsonMap['item_id']?.toString(); // Parse item_id

              if (type == null || data == null) continue;
              
              // Parse query_id if this is the query_id response
              if (type == 'query_id') {
                // data can be int or string, convert to int
                final int? parsedQueryId = data is int ? data : (data is String ? int.tryParse(data) : null);
                if (parsedQueryId != null) {
                  // Update current result
                  currentResult = currentResult.copyWith(
                    queryId: parsedQueryId,
                    searchSessionId: currentSessionId
                  );
                  
                  // ✅ CRITICAL FIX: Update ALL existing results for this search with the queryId
                  final updatedResults = _currentResults.value.map((result) {
                    if (result.searchSessionId == currentSessionId) {
                      return result.copyWith(queryId: parsedQueryId);
                    }
                    return result;
                  }).toList();
                  
                  _currentResults.add(updatedResults);
                }
                continue;
              }

              // Handle nl_to_cypher — fire off graph result polling (developer mode only)
              if (type == 'nl_to_cypher') {
                if (DeveloperModeService.instance.isEnabled && data is Map<String, dynamic>) {
                  final resultKey = data['result_key'] as String?;
                  if (resultKey != null && resultKey.isNotEmpty) {
                    // Create a loading placeholder result for graph
                    final graphLoadingResult = UnifiedSearchResult(
                      query: query,
                      originalQuery: query,
                      timestamp: DateTime.now(),
                      searchSessionId: currentSessionId,
                      splits: currentResult.splits,
                      queryId: currentResult.queryId,
                      itemId: itemId,
                      graphLoading: true,
                    );
                    _addOrUpdateGraphResult(graphLoadingResult);

                    // Fire and forget — poll the result endpoint asynchronously
                    _pollGraphResult(resultKey, query, currentSessionId, currentResult, itemId);
                  }
                }
                continue;
              }

              // Normalize verse data before parsing to prevent type cast failures
              if (type == 'verse' && data is List) {
                for (var verse in data) {
                  if (verse is Map<String, dynamic>) {
                    if (verse['word_hyplinks'] == null) {
                      verse['word_hyplinks'] = <Map<String, dynamic>>[];
                    }
                    if (verse['other_fields'] == null) {
                      verse['other_fields'] = <Map<String, dynamic>>[];
                    }
                    if (verse['verse_pk'] == null) {
                      verse['verse_pk'] = 0;
                    }
                    // API may send similarity as number or string — ensure it's always a string
                    if (verse['similarity'] != null && verse['similarity'] is! String) {
                      verse['similarity'] = verse['similarity'].toString();
                    }
                  }
                }
              }

              switch (type) {
            case 'info':
              try {
                if (data is! Map<String, dynamic>) continue;
                final outputScript = data['output_script'] as String?;
                
                currentResult = currentResult.copyWith(
                  outputScript: outputScript,
                  searchSessionId: currentSessionId
                );
                
                if (currentResult.verses != null && currentResult.verses!.isNotEmpty) {
                  _reprocessVersesWithLanguage(currentResult, currentSessionId, query);
                }
              } catch (_) {}
              break;

            case 'splits':
              try {
                if (data is! Map<String, dynamic>) continue;
                final splits = QuerySplitsRM.fromJson(data);
                currentResult = currentResult.copyWith(
                  splits: splits,
                  searchSessionId: currentSessionId
                );
              } catch (_) {}
              break;

            case 'definition':
              try {
                if (data is! Map<String, dynamic>) continue;
                final definition = DictWordDefinitionsRM.fromJson(data);
                
                final definitionResult = UnifiedSearchResult(
                  query: definition.givenWord ?? query,
                  timestamp: DateTime.now(),
                  searchSessionId: currentSessionId,
                  splits: currentResult.splits,
                  definition: definition,
                  queryId: currentResult.queryId,
                  itemId: itemId,
                );
                
                _addOrUpdateResult(definitionResult);
              } catch (_) {}
              break;

            case 'verse':
              try {
                if (data is! List<dynamic>) continue;
                
                final verses = <VerseRM>[];
                for (int i = 0; i < data.length; i++) {
                  var v = data[i];
                  try {
                    if (v is Map<String, dynamic> && v['data_type'] == 'info') {
                      continue;
                    }
                    
                    final verse = VerseRM.fromJson(v as Map<String, dynamic>);
                    verses.add(verse);
                  } catch (_) {
                    // Skip this individual verse and continue with the rest
                  }
                }
                
                if (verses.isEmpty) break;
                
                _verseResponseCounter++;
                
                String cardQuery;
                if (currentResult.splits?.quotedTexts != null && currentResult.splits!.quotedTexts!.isNotEmpty) {
                  final quotedTexts = currentResult.splits!.quotedTexts!;
                  final quotedTextIndex = (_verseResponseCounter - 1) % quotedTexts.length;
                  cardQuery = quotedTexts[quotedTextIndex];
                } else {
                  cardQuery = query;
                }
                
                final verseResult = UnifiedSearchResult(
                  query: cardQuery,
                  originalQuery: query,
                  timestamp: DateTime.now(),
                  searchSessionId: currentSessionId,
                  splits: currentResult.splits,
                  verses: verses,
                  outputScript: currentResult.outputScript,
                  queryId: currentResult.queryId,
                  itemId: itemId,
                );
                
                if (currentResult.outputScript == null) {
                  final tempResult = verseResult.copyWith(outputScript: 'Devanagari');
                  _reprocessVersesWithLanguage(tempResult, currentSessionId, cardQuery);
                } else {
                  _addOrUpdateResult(verseResult);
                }
              } catch (_) {}
              break;

            case 'chunk':
              try {
                if (data is! List<dynamic>) continue;
                final chunks = <BookChunkRM>[];
                for (var c in data) {
                  try {
                    chunks.add(BookChunkRM.fromJson(c as Map<String, dynamic>));
                  } catch (_) {
                    // Skip this individual chunk and continue with the rest
                  }
                }
                
                if (chunks.isEmpty) break;
                
                String chunkQuery = query;
                if (currentResult.splits != null && currentResult.splits!.heritageQuery.isNotEmpty) {
                  chunkQuery = currentResult.splits!.heritageQuery;
                }
                
                final chunkResult = UnifiedSearchResult(
                  query: chunkQuery,
                  originalQuery: query,
                  timestamp: DateTime.now(),
                  searchSessionId: currentSessionId,
                  splits: currentResult.splits,
                  chunks: chunks,
                  queryId: currentResult.queryId,
                  itemId: itemId,
                );
                
                _addOrUpdateResult(chunkResult);
              } catch (_) {}
              break;

            case 'dhara_chunk':
              if (!DeveloperModeService.instance.isEnabled) break;
              try {
                if (data is! List<dynamic>) continue;
                final dharaChunks = <DharaInsightChunkRM>[];
                for (var c in data) {
                  try {
                    dharaChunks.add(DharaInsightChunkRM.fromJson(c as Map<String, dynamic>));
                  } catch (_) {}
                }

                if (dharaChunks.isEmpty) break;

                String dharaQuery = query;
                if (currentResult.splits != null && currentResult.splits!.heritageQuery.isNotEmpty) {
                  dharaQuery = currentResult.splits!.heritageQuery;
                }

                final dharaResult = UnifiedSearchResult(
                  query: dharaQuery,
                  originalQuery: query,
                  timestamp: DateTime.now(),
                  searchSessionId: currentSessionId,
                  splits: currentResult.splits,
                  dharaChunks: dharaChunks,
                  queryId: currentResult.queryId,
                  itemId: itemId,
                );

                _addOrUpdateDharaInsightsResult(dharaResult);
              } catch (_) {}
              break;
            }

        } catch (e) {
          // JSON structure-level parse error — skip to next JSON object in buffer
        }
      }
    }

    // Remove the initial empty placeholder if real results were added
    _removeEmptyPlaceholder(currentSessionId);

    // Cache the composite result for this search
    _cacheCurrentSessionResults(query, currentSessionId);
    _isLoading.add(false);
    _isStreaming.add(false);
  }




  /// Remove empty placeholder results that have no actual content
  void _removeEmptyPlaceholder(int sessionId) {
    final currentResults = List<UnifiedSearchResult>.from(_currentResults.value);
    final hasRealContent = currentResults.any(
      (r) => r.searchSessionId == sessionId && r.hasAnyResults,
    );
    if (hasRealContent) {
      currentResults.removeWhere(
        (r) => r.searchSessionId == sessionId && !r.hasAnyResults,
      );
      _currentResults.add(currentResults);
    }
  }

  /// Cache composite result from all results in this session
  void _cacheCurrentSessionResults(String query, int sessionId) {
    final sessionResults = _currentResults.value
        .where((r) => r.searchSessionId == sessionId)
        .toList();
    if (sessionResults.isEmpty) return;

    // Build a merged result for the cache
    DictWordDefinitionsRM? definition;
    List<VerseRM>? allVerses;
    List<BookChunkRM>? allChunks;
    QuerySplitsRM? splits;
    String? outputScript;
    int? queryId;
    String? itemId;

    for (final r in sessionResults) {
      splits ??= r.splits;
      queryId ??= r.queryId;
      itemId ??= r.itemId;
      outputScript ??= r.outputScript;
      if (r.definition != null) definition = r.definition;
      if (r.verses != null && r.verses!.isNotEmpty) {
        allVerses ??= [];
        allVerses.addAll(r.verses!);
      }
      if (r.chunks != null && r.chunks!.isNotEmpty) {
        allChunks ??= [];
        allChunks.addAll(r.chunks!);
      }
    }

    final cacheResult = UnifiedSearchResult(
      query: query,
      originalQuery: query,
      timestamp: DateTime.now(),
      searchSessionId: sessionId,
      splits: splits,
      definition: definition,
      verses: allVerses,
      chunks: allChunks,
      outputScript: outputScript,
      queryId: queryId,
      itemId: itemId,
    );
    SmartSearchCache.instance.setUnifiedResult(query, cacheResult);
  }

  /// Add or update a search result
  void _addOrUpdateResult(UnifiedSearchResult newResult) {
    final currentResults = List<UnifiedSearchResult>.from(_currentResults.value);
    
    // ✅ FIX: FORCE all new results to use current session ID
    final correctedResult = newResult.copyWith(
      searchSessionId: _currentSearchSessionId,
    );
    
    // Check for duplicates based on query and current session
    final existingIndex = currentResults.indexWhere(
      (result) => result.query.toLowerCase() == correctedResult.query.toLowerCase() && 
                  result.searchSessionId == _currentSearchSessionId
    );

    if (existingIndex != -1) {
      // Update existing result (prevent duplicates)
      currentResults[existingIndex] = correctedResult;
    } else {
      // Add new result at the beginning
      currentResults.insert(0, correctedResult);
    }

    _currentResults.add(currentResults);
  }

  /// Add or update a graph-specific result (keyed by "__graph__" query marker)
  void _addOrUpdateGraphResult(UnifiedSearchResult graphResult) {
    final currentResults = List<UnifiedSearchResult>.from(_currentResults.value);
    final graphKey = '__graph__${graphResult.searchSessionId}';

    final existingIndex = currentResults.indexWhere(
      (r) => r.itemId == graphKey,
    );

    final tagged = graphResult.copyWith(
      itemId: graphKey,
      searchSessionId: _currentSearchSessionId,
    );

    if (existingIndex != -1) {
      currentResults[existingIndex] = tagged;
    } else {
      currentResults.add(tagged);
    }

    _currentResults.add(currentResults);
  }

  /// Add or update a Dhara Insights result (identified by hasDharaInsights + sessionId)
  void _addOrUpdateDharaInsightsResult(UnifiedSearchResult dharaResult) {
    final currentResults = List<UnifiedSearchResult>.from(_currentResults.value);

    final tagged = dharaResult.copyWith(
      searchSessionId: _currentSearchSessionId,
    );

    // Find existing Dhara Insights result for this session
    final existingIndex = currentResults.indexWhere(
      (r) => r.hasDharaInsights && r.searchSessionId == _currentSearchSessionId,
    );

    if (existingIndex != -1) {
      currentResults[existingIndex] = tagged;
    } else {
      currentResults.add(tagged);
    }

    _currentResults.add(currentResults);
  }

  /// Poll the nl_to_cypher_result endpoint until completed
  Future<void> _pollGraphResult(
    String resultKey,
    String query,
    int sessionId,
    UnifiedSearchResult currentResult,
    String? itemId,
  ) async {
    try {
      final result = await GraphSearchService.instance.fetchNlToCypherResult(
        resultKey,
        queryId: currentResult.queryId != null ? int.tryParse(currentResult.queryId.toString()) : null,
      );

      final graphResult = UnifiedSearchResult(
        query: query,
        originalQuery: query,
        timestamp: DateTime.now(),
        searchSessionId: sessionId,
        splits: currentResult.splits,
        queryId: currentResult.queryId,
        itemId: '__graph__$sessionId',
        graphResult: result,
        graphLoading: false,
        graphError: result == null ? 'Graph query failed' : null,
      );
      _addOrUpdateGraphResult(graphResult);
    } catch (_) {
      final errorResult = UnifiedSearchResult(
        query: query,
        originalQuery: query,
        timestamp: DateTime.now(),
        searchSessionId: sessionId,
        splits: currentResult.splits,
        queryId: currentResult.queryId,
        itemId: '__graph__$sessionId',
        graphLoading: false,
        graphError: 'Failed to fetch graph results',
      );
      _addOrUpdateGraphResult(errorResult);
    }
  }

  void _reprocessVersesWithLanguage(UnifiedSearchResult currentResult, int sessionId, String query) {
    if (currentResult.verses == null || currentResult.verses!.isEmpty || currentResult.outputScript == null) {
      return;
    }

    final transformedVerses = <VerseRM>[];
    for (var verse in currentResult.verses!) {
      try {
        final processedVerse = verse.copyWith(
          verseText: verse.verseOtherScripts?[currentResult.outputScript] ?? verse.verseText,
          verseLetText: verse.verseLetOtherScripts?[currentResult.outputScript] ?? verse.verseLetText,
        );
        transformedVerses.add(processedVerse);
      } catch (e) {
        transformedVerses.add(verse);
      }
    }

    // Create verse result with transformed verses
    // ✅ FIX: Use the passed query parameter directly instead of combining all quoted texts
    String verseQuery = query;
    
    final verseResult = UnifiedSearchResult(
      query: verseQuery,
      originalQuery: currentResult.originalQuery ?? query, // Preserve or store original user query for Prashna
      timestamp: DateTime.now(),
      searchSessionId: sessionId, // ✅ FIX: Use session ID from current search
      splits: currentResult.splits,
      verses: transformedVerses,
      outputScript: currentResult.outputScript,
      queryId: currentResult.queryId, // ✅ Preserve queryId for voting
      itemId: currentResult.itemId, // ✅ Preserve itemId for voting
    );
    
    // Add verses to VerseService cache for interaction
    final verseService = VerseService.instance;
    for (var verse in transformedVerses) {
      verseService.addVerseToCache(verse);
    }
    
    _addOrUpdateResult(verseResult);
  }

  /// Clear all results
  void clearResults() {
    _currentResults.add([]);
    _isLoading.add(false);
    _isStreaming.add(false);
  }

  /// Clear cache to force fresh results (for language changes)
  void clearCache() {
    SmartSearchCache.instance.clearUnifiedCache();
  }

  /// Remove a specific result
  void removeResult(String query) {
    final currentResults = List<UnifiedSearchResult>.from(_currentResults.value);
    currentResults.removeWhere(
      (result) => result.query.toLowerCase() == query.toLowerCase()
    );
    _currentResults.add(currentResults);
    
    // Also remove from cache
    SmartSearchCache.instance.clearUnifiedResult(query);
  }

  /// Silent refresh of verses for language change
  /// This fetches fresh verse data from the API using verse PKs and applies the new language preference
  Future<void> refreshVersesForLanguageChange() async {
    try {
      final currentResults = _currentResults.value;
      if (currentResults.isEmpty) {
        return;
      }
      
      // Collect all verse PKs from current results
      final Set<int> allVersePks = {};
      for (final result in currentResults) {
        if (result.verses != null) {
          for (final verse in result.verses!) {
            allVersePks.add(verse.versePk);
          }
        }
      }
      
      if (allVersePks.isEmpty) {
        return;
      }
      
      // Create search query with all verse PKs
      final versePksString = allVersePks.join(' ');
      final url = '$_baseUrl/verse/v2/find/?input_string=${Uri.encodeComponent(versePksString)}';

      // Use configured Dio instance with auth interceptors
      final response = await dio.get(url, options: Options(headers: {
        'accept': '*/*',
        'requiresToken': true, // Signal the auth interceptor to add auth headers
      }));
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map<String, dynamic> && responseData['verses'] != null) {
          final versesData = responseData['verses'] as List<dynamic>;
          final refreshedVerses = <VerseRM>[];
          
          for (var v in versesData) {
            try {
              if (v is Map<String, dynamic>) {
                if (v['similarity'] != null && v['similarity'] is! String) {
                  v['similarity'] = v['similarity'].toString();
                }
                refreshedVerses.add(VerseRM.fromJson(v));
              }
            } catch (_) {
              // Skip invalid verse
            }
          }
          
          // Update all results with new verse data
          final updatedResults = <UnifiedSearchResult>[];
          for (final result in currentResults) {
            if (result.verses != null && result.verses!.isNotEmpty) {
              final updatedVerses = <VerseRM>[];
              
              for (final oldVerse in result.verses!) {
                // Find the refreshed version of this verse
                final refreshedVerse = refreshedVerses.firstWhere(
                  (rv) => rv.versePk == oldVerse.versePk,
                  orElse: () => oldVerse, // Keep original if not found
                );
                updatedVerses.add(refreshedVerse);
              }
              
              updatedResults.add(result.copyWith(verses: updatedVerses));
            } else {
              // Keep non-verse results unchanged
              updatedResults.add(result);
            }
          }
          
          // Emit the updated results
          _currentResults.add(updatedResults);
        }
      }
    } catch (e) {
      // Silent refresh error - fail silently
    }
  }

  /// Dispose resources
  void dispose() {
    _currentResults.close();
    _isLoading.close();
  }
}
