// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_request_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRequestDto _$ChatRequestDtoFromJson(Map<String, dynamic> json) =>
    ChatRequestDto(
      message: json['message'] as String,
      sessionId: json['session_id'] as String,
    );

Map<String, dynamic> _$ChatRequestDtoToJson(ChatRequestDto instance) =>
    <String, dynamic>{
      'message': instance.message,
      'session_id': instance.sessionId,
    };

SseEventDto _$SseEventDtoFromJson(Map<String, dynamic> json) => SseEventDto(
  content: json['content'] as String,
  event: json['event'] as String,
);

Map<String, dynamic> _$SseEventDtoToJson(SseEventDto instance) =>
    <String, dynamic>{'content': instance.content, 'event': instance.event};

ToolParametersDto _$ToolParametersDtoFromJson(Map<String, dynamic> json) =>
    ToolParametersDto(
      toolName: json['tool_name'] as String,
      toolArgs: json['tool_args'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$ToolParametersDtoToJson(ToolParametersDto instance) =>
    <String, dynamic>{
      'tool_name': instance.toolName,
      'tool_args': instance.toolArgs,
    };
