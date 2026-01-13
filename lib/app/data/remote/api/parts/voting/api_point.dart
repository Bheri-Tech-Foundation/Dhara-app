import 'package:dharak_flutter/app/data/remote/api/parts/voting/dto/vote_response_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_point.g.dart';

@RestApi()
abstract class VotingApiPoint {
  factory VotingApiPoint(Dio dio, {String baseUrl}) = _VotingApiPoint;

  /// Submit a vote
  /// GET /vote/?item_id={itemId}&query_id={queryId}&value={value}&vote={vote}
  @GET("/vote/")
  Future<VoteResponseDto> submitVote(
    @Query("item_id") String itemId,
    @Query("query_id") int queryId,
    @Query("value") String? value,
    @Query("vote") String vote, {
    @Header("requiresToken") bool requiresToken = true, // Auth required for voting
  });
}




