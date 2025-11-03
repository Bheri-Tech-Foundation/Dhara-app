// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SourceCitation _$SourceCitationFromJson(Map<String, dynamic> json) =>
    SourceCitation(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      text: json['text'] as String?,
      reference: json['reference'] as String?,
      url: json['url'] as String?,
    );

Map<String, dynamic> _$SourceCitationToJson(SourceCitation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'text': instance.text,
      'reference': instance.reference,
      'url': instance.url,
    };

ToolCall _$ToolCallFromJson(Map<String, dynamic> json) => ToolCall(
  name: json['name'] as String,
  parameters: json['parameters'] as Map<String, dynamic>,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime:
      json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
  result: json['result'] as String?,
);

Map<String, dynamic> _$ToolCallToJson(ToolCall instance) => <String, dynamic>{
  'name': instance.name,
  'parameters': instance.parameters,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime?.toIso8601String(),
  'result': instance.result,
};

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
  id: json['id'] as String,
  role: $enumDecode(_$MessageRoleEnumMap, json['role']),
  content: json['content'] as String,
  rawContent: json['rawContent'] as String?,
  status: $enumDecode(_$MessageStatusEnumMap, json['status']),
  timestamp: DateTime.parse(json['timestamp'] as String),
  aiModel: $enumDecodeNullable(_$AiModelEnumMap, json['aiModel']),
  sessionId: json['sessionId'] as String?,
  citations:
      (json['citations'] as List<dynamic>?)
          ?.map((e) => SourceCitation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  toolCalls:
      (json['toolCalls'] as List<dynamic>?)
          ?.map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  errorMessage: json['errorMessage'] as String?,
  executionLog:
      json['executionLog'] == null
          ? null
          : ExecutionLog.fromJson(json['executionLog'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'role': _$MessageRoleEnumMap[instance.role]!,
      'content': instance.content,
      'rawContent': instance.rawContent,
      'status': _$MessageStatusEnumMap[instance.status]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'aiModel': _$AiModelEnumMap[instance.aiModel],
      'sessionId': instance.sessionId,
      'citations': instance.citations,
      'toolCalls': instance.toolCalls,
      'errorMessage': instance.errorMessage,
      'executionLog': instance.executionLog,
    };

const _$MessageRoleEnumMap = {
  MessageRole.user: 'user',
  MessageRole.assistant: 'assistant',
};

const _$MessageStatusEnumMap = {
  MessageStatus.sending: 'sending',
  MessageStatus.streaming: 'streaming',
  MessageStatus.completed: 'completed',
  MessageStatus.error: 'error',
  MessageStatus.cancelled: 'cancelled',
};

const _$AiModelEnumMap = {AiModel.gemini: 'gemini', AiModel.qwen: 'qwen'};

ChatSession _$ChatSessionFromJson(Map<String, dynamic> json) => ChatSession(
  id: json['id'] as String,
  aiModel: $enumDecode(_$AiModelEnumMap, json['aiModel']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  messages:
      (json['messages'] as List<dynamic>)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$ChatSessionToJson(ChatSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'aiModel': _$AiModelEnumMap[instance.aiModel]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'messages': instance.messages,
      'isActive': instance.isActive,
    };
