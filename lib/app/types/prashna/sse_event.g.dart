// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sse_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContentDeltaEvent _$ContentDeltaEventFromJson(Map<String, dynamic> json) =>
    ContentDeltaEvent(
      content: json['content'] as String?,
      event: json['event'] as String,
    );

Map<String, dynamic> _$ContentDeltaEventToJson(ContentDeltaEvent instance) =>
    <String, dynamic>{'content': instance.content, 'event': instance.event};

SessionIdEvent _$SessionIdEventFromJson(Map<String, dynamic> json) =>
    SessionIdEvent(
      content: json['content'] as String?,
      event: json['event'] as String,
    );

Map<String, dynamic> _$SessionIdEventToJson(SessionIdEvent instance) =>
    <String, dynamic>{'content': instance.content, 'event': instance.event};

RunStartedEvent _$RunStartedEventFromJson(Map<String, dynamic> json) =>
    RunStartedEvent(
      content: json['content'] as String?,
      event: json['event'] as String,
    );

Map<String, dynamic> _$RunStartedEventToJson(RunStartedEvent instance) =>
    <String, dynamic>{'content': instance.content, 'event': instance.event};

ToolCallStartedEvent _$ToolCallStartedEventFromJson(
  Map<String, dynamic> json,
) => ToolCallStartedEvent(
  content: json['content'] as String?,
  event: json['event'] as String,
);

Map<String, dynamic> _$ToolCallStartedEventToJson(
  ToolCallStartedEvent instance,
) => <String, dynamic>{'content': instance.content, 'event': instance.event};

ToolParametersEvent _$ToolParametersEventFromJson(Map<String, dynamic> json) =>
    ToolParametersEvent(
      toolData: json['content'] as Map<String, dynamic>,
      event: json['event'] as String,
    );

Map<String, dynamic> _$ToolParametersEventToJson(
  ToolParametersEvent instance,
) => <String, dynamic>{'event': instance.event, 'content': instance.toolData};

ToolCallCompletedEvent _$ToolCallCompletedEventFromJson(
  Map<String, dynamic> json,
) => ToolCallCompletedEvent(
  content: json['content'] as String?,
  event: json['event'] as String,
);

Map<String, dynamic> _$ToolCallCompletedEventToJson(
  ToolCallCompletedEvent instance,
) => <String, dynamic>{'content': instance.content, 'event': instance.event};

RunContentEvent _$RunContentEventFromJson(Map<String, dynamic> json) =>
    RunContentEvent(
      content: json['content'] as String?,
      event: json['event'] as String,
    );

Map<String, dynamic> _$RunContentEventToJson(RunContentEvent instance) =>
    <String, dynamic>{'content': instance.content, 'event': instance.event};

EventDataEvent _$EventDataEventFromJson(Map<String, dynamic> json) =>
    EventDataEvent(
      eventData: json['content'] as Map<String, dynamic>,
      event: json['event'] as String,
    );

Map<String, dynamic> _$EventDataEventToJson(EventDataEvent instance) =>
    <String, dynamic>{'event': instance.event, 'content': instance.eventData};

UnknownEvent _$UnknownEventFromJson(Map<String, dynamic> json) => UnknownEvent(
  content: json['content'] as String?,
  event: json['event'] as String,
);

Map<String, dynamic> _$UnknownEventToJson(UnknownEvent instance) =>
    <String, dynamic>{'content': instance.content, 'event': instance.event};
