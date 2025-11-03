// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'execution_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExecutionEvent _$ExecutionEventFromJson(Map<String, dynamic> json) =>
    ExecutionEvent(
      event: $enumDecode(_$ExecutionEventTypeEnumMap, json['event']),
      time: (json['time'] as num).toDouble(),
      content: json['content'] as String,
    );

Map<String, dynamic> _$ExecutionEventToJson(ExecutionEvent instance) =>
    <String, dynamic>{
      'event': _$ExecutionEventTypeEnumMap[instance.event]!,
      'time': instance.time,
      'content': instance.content,
    };

const _$ExecutionEventTypeEnumMap = {
  ExecutionEventType.runStarted: 'RunStarted',
  ExecutionEventType.toolCallStarted: 'ToolCallStarted',
  ExecutionEventType.toolCallCompleted: 'ToolCallCompleted',
  ExecutionEventType.runContent: 'RunContent',
  ExecutionEventType.runCompleted: 'RunCompleted',
  ExecutionEventType.unknown: 'Unknown',
};

ExecutionLog _$ExecutionLogFromJson(Map<String, dynamic> json) => ExecutionLog(
  model: json['model'] as String,
  events:
      (json['events'] as List<dynamic>)
          .map((e) => ExecutionEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$ExecutionLogToJson(ExecutionLog instance) =>
    <String, dynamic>{'model': instance.model, 'events': instance.events};
