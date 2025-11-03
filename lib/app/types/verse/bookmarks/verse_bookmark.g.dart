// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse_bookmark.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerseBookmarkRM _$VerseBookmarkRMFromJson(Map<String, dynamic> json) =>
    VerseBookmarkRM(
      source: json['source'] as String?,
      key: json['key'] as String,
      text: json['text'] as String,
      pk: (json['pk'] as num).toInt(),
    );

Map<String, dynamic> _$VerseBookmarkRMToJson(VerseBookmarkRM instance) =>
    <String, dynamic>{
      'source': instance.source,
      'key': instance.key,
      'text': instance.text,
      'pk': instance.pk,
    };
