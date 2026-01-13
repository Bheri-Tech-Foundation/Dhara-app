import 'package:json_annotation/json_annotation.dart';

part 'vote_response_dto.g.dart';

@JsonSerializable()
class PrashnaVoteResponseDto {
  final String message;

  PrashnaVoteResponseDto({required this.message});

  factory PrashnaVoteResponseDto.fromJson(Map<String, dynamic> json) =>
      _$PrashnaVoteResponseDtoFromJson(json);
      
  Map<String, dynamic> toJson() => _$PrashnaVoteResponseDtoToJson(this);
}




