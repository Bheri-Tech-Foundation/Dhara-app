import 'package:dharak_flutter/app/data/remote/api/base/api_request.dart';
import 'package:dharak_flutter/app/data/remote/api/base/api_response.dart';
import 'package:dharak_flutter/app/data/remote/api/base/dto/error_dto.dart';
import 'package:dharak_flutter/app/data/remote/api/parts/voting/api_point.dart';
import 'package:dharak_flutter/app/types/voting/vote_request.dart';

class VotingApiRepo extends ApiRequest<ErrorDto> {
  VotingApiPoint apiPoint;

  VotingApiRepo({required this.apiPoint});

  /// Submit a vote to the API
  Future<ApiResponse<String, ErrorDto>> submitVote(VoteRequest voteRequest) async {
    var result = await sendRequest(
      () => apiPoint.submitVote(
        voteRequest.itemId,
        voteRequest.queryId,
        voteRequest.value,
        voteRequest.vote,
      ),
      (data) => Future.value(ErrorDto.fromJson(data)),
    );

    // Return the message from the response
    if (result.status == ApiResponseStatus.SUCCESS && result.data != null) {
      return ApiResponse<String, ErrorDto>.success(
        data: result.data!.message,
      );
    }
    
    return ApiResponse<String, ErrorDto>.error(error: result.error);
  }
}






