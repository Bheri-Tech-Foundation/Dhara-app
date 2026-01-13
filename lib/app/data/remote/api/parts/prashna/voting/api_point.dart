import 'package:dharak_flutter/app/data/remote/api/parts/prashna/voting/dto/vote_response_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_point.g.dart';

@RestApi()
abstract class PrashnaVotingApiPoint {
  factory PrashnaVotingApiPoint(Dio dio, {String baseUrl}) = _PrashnaVotingApiPoint;

  @GET("/prashna/vote/")
  Future<PrashnaVoteResponseDto> submitVote({
    @Query("query_id") required int queryId,
    @Query("v_type") required String vType,
    @Query("vote") required String vote,
    @Header("requiresToken") bool requiresToken = true, // Auth required for voting
  });
}



