import 'package:dharak_flutter/app/data/remote/api/parts/voting/api.dart';
import 'package:dharak_flutter/app/data/remote/api/base/api_response.dart';
import 'package:dharak_flutter/app/types/voting/vote_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:logger/logger.dart';

/// Repository for managing voting operations
class VotingRepository {
  final VotingApiRepo _votingApi;
  final Logger _logger = Logger();
  static const String _pendingVotesKey = 'pending_votes';
  static const String _totalVotesKey = 'total_votes_count';
  
  // In-memory cache for vote states (survives widget rebuilds)
  static final Map<String, String> _voteStateCache = {};

  VotingRepository(this._votingApi);

  /// Submit a vote to the API
  Future<bool> submitVote(VoteRequest voteRequest) async {
    try {
      _logger.d('📤 Submitting vote: item_id=${voteRequest.itemId}, query_id=${voteRequest.queryId}, vote=${voteRequest.vote}');
      
      // Cache the vote state immediately for UI persistence
      _cacheVoteState(voteRequest);
      
      final response = await _votingApi.submitVote(voteRequest);

      if (response.status == ApiResponseStatus.SUCCESS) {
        _logger.d('✅ Vote submitted successfully: ${response.data}');
        await _incrementTotalVotesCount();
        return true;
      } else {
        _logger.w('⚠️ Vote submission failed, saving for later sync');
        // Save to pending votes for later sync
        await _savePendingVote(voteRequest);
        return false;
      }
    } catch (e) {
      _logger.e('❌ Error submitting vote: $e');
      // Save to pending votes for later sync
      await _savePendingVote(voteRequest);
      return false;
    }
  }

  /// Cache vote state for UI persistence (survives widget rebuilds)
  void _cacheVoteState(VoteRequest voteRequest) {
    final key = _buildVoteCacheKey(
      queryId: voteRequest.queryId,
      itemId: voteRequest.itemId,
      refId: voteRequest.value ?? '',
    );
    _voteStateCache[key] = voteRequest.vote;
    _logger.d('💾 Cached vote state: $key => ${voteRequest.vote}');
  }

  /// Get cached vote state
  String? getCachedVoteState({
    required int queryId,
    required String itemId,
    required String refId,
  }) {
    final key = _buildVoteCacheKey(queryId: queryId, itemId: itemId, refId: refId);
    final cachedVote = _voteStateCache[key];
    if (cachedVote != null) {
      _logger.d('📖 Retrieved cached vote: $key => $cachedVote');
    }
    return cachedVote;
  }

  /// Build cache key for vote state
  String _buildVoteCacheKey({
    required int queryId,
    required String itemId,
    required String refId,
  }) {
    return '${queryId}_${itemId}_$refId';
  }

  /// Clear vote cache (useful for new searches)
  static void clearVoteCache() {
    _voteStateCache.clear();
  }

  /// Save vote for later sync (offline support) - Static method for use without instance
  static Future<void> savePendingVote(VoteRequest voteRequest) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingVotesJson = prefs.getString(_pendingVotesKey) ?? '[]';
      final List<dynamic> pendingVotes = json.decode(pendingVotesJson);
      
      pendingVotes.add(voteRequest.toJson());
      
      await prefs.setString(_pendingVotesKey, json.encode(pendingVotes));
      
      // Also increment total votes count
      await _incrementTotalVotesCountStatic();
    } catch (e) {
      // Silent fail
    }
  }
  
  /// Instance method that calls the static version
  Future<void> _savePendingVote(VoteRequest voteRequest) async {
    await savePendingVote(voteRequest);
  }

  /// Get pending votes
  Future<List<VoteRequest>> getPendingVotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingVotesJson = prefs.getString(_pendingVotesKey) ?? '[]';
      final List<dynamic> pendingVotes = json.decode(pendingVotesJson);
      
      return pendingVotes.map((json) => VoteRequest(
        itemId: json['item_id'] as String,
        queryId: json['query_id'] as int,
        value: json['value'] as String?,
        vote: json['vote'] as String,
      )).toList();
    } catch (e) {
      return [];
    }
  }

  /// Sync pending votes
  Future<int> syncPendingVotes() async {
    final pendingVotes = await getPendingVotes();
    int successCount = 0;

    for (final vote in pendingVotes) {
      final success = await submitVote(vote);
      if (success) {
        successCount++;
      }
    }

    // Clear synced votes
    if (successCount > 0) {
      final prefs = await SharedPreferences.getInstance();
      final remainingVotes = pendingVotes.skip(successCount).toList();
      await prefs.setString(_pendingVotesKey, json.encode(
        remainingVotes.map((v) => v.toJson()).toList()
      ));
    }

    return successCount;
  }

  /// Get total votes count
  Future<int> getTotalVotesCount() async {
    return await getTotalVotesCountStatic();
  }
  
  /// Get total votes count - Static method for use without instance
  static Future<int> getTotalVotesCountStatic() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_totalVotesKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Increment total votes count
  Future<void> _incrementTotalVotesCount() async {
    await _incrementTotalVotesCountStatic();
  }
  
  /// Static version of increment for use without instance
  static Future<void> _incrementTotalVotesCountStatic() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt(_totalVotesKey) ?? 0;
      await prefs.setInt(_totalVotesKey, currentCount + 1);
    } catch (e) {
      // Silent fail
    }
  }

  /// Clear all voting data (for testing)
  Future<void> clearAllVotingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingVotesKey);
      await prefs.remove(_totalVotesKey);
    } catch (e) {
      // Silent fail
    }
  }
}

