// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_hyplink.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WordHyplinkRM _$WordHyplinkRMFromJson(Map<String, dynamic> json) =>
    WordHyplinkRM(
      word: json['word'] as String?,
      startIndex: (json['start_index'] as num?)?.toInt(),
      endIndex: (json['end_index'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WordHyplinkRMToJson(WordHyplinkRM instance) =>
    <String, dynamic>{
      'word': instance.word,
      'start_index': instance.startIndex,
      'end_index': instance.endIndex,
    };
