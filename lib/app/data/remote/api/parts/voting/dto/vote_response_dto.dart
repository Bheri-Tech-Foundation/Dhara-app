import 'package:json_annotation/json_annotation.dart';

part 'vote_response_dto.g.dart';

@JsonSerializable()
class VoteResponseDto {
  final String message;

  VoteResponseDto({required this.message});

  factory VoteResponseDto.fromJson(Map<String, dynamic> json) =>
      _$VoteResponseDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$VoteResponseDtoToJson(this);
}





