import 'package:dharak_flutter/app/data/remote/api/base/api_request.dart';
import 'package:dharak_flutter/app/data/remote/api/base/api_response.dart';
import 'package:dharak_flutter/app/data/remote/api/base/dto/error_dto.dart';
import 'package:dharak_flutter/app/data/remote/api/parts/prashna/voting/api_point.dart';
import 'package:dharak_flutter/app/data/remote/api/parts/prashna/voting/dto/vote_response_dto.dart';
import 'package:dharak_flutter/app/types/prashna/vote_type.dart';
import 'package:logger/logger.dart';

/// Repository for Prashna voting operations
class PrashnaVotingRepository extends ApiRequest<ErrorDto> {
  final PrashnaVotingApiPoint _apiPoint;
  final Logger _logger = Logger();
  
  // In-memory cache for Prashna vote states (survives widget rebuilds)
  static final Map<String, String> _voteStateCache = {};

  PrashnaVotingRepository({
    required PrashnaVotingApiPoint apiPoint,
  })  : _apiPoint = apiPoint;

  /// Submit a Prashna vote (rating or feedback)
  Future<bool> submitVote(PrashnaVoteRequest voteRequest) async {
    try {
      final response = await sendRequest(
        () => _apiPoint.submitVote(
          queryId: voteRequest.queryId,
          vType: voteRequest.voteType.apiValue,
          vote: voteRequest.vote,
        ),
        (data) => Future.value(ErrorDto.fromJson(data)),
      );

      // Cache the vote state immediately for UI persistence
      _cacheVoteState(voteRequest);

      if (response.status == ApiResponseStatus.SUCCESS) {
        _logger.d('✅ Prashna vote submitted: ${response.data?.message}');
        return true;
      } else {
        _logger.w('⚠️ Prashna vote submission failed');
        return false;
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to submit Prashna vote', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Cache vote state for UI persistence (survives widget rebuilds)
  void _cacheVoteState(PrashnaVoteRequest voteRequest) {
    final key = _buildVoteCacheKey(
      queryId: voteRequest.queryId,
      voteType: voteRequest.voteType,
    );
    _voteStateCache[key] = voteRequest.vote;
    _logger.d('💾 Cached Prashna vote state: $key => ${voteRequest.vote}');
  }

  /// Get cached vote state
  String? getCachedVoteState({
    required int queryId,
    required PrashnaVoteType voteType,
  }) {
    final key = _buildVoteCacheKey(queryId: queryId, voteType: voteType);
    final cachedVote = _voteStateCache[key];
    if (cachedVote != null) {
      _logger.d('📖 Retrieved cached Prashna vote: $key => $cachedVote');
    }
    return cachedVote;
  }

  /// Build cache key for vote state
  String _buildVoteCacheKey({
    required int queryId,
    required PrashnaVoteType voteType,
  }) {
    return '${queryId}_${voteType.name}';
  }

  /// Clear vote cache (useful for new searches)
  static void clearVoteCache() {
    _voteStateCache.clear();
  }
}

