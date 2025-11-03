// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'definition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WordDefinitionRM _$WordDefinitionRMFromJson(Map<String, dynamic> json) =>
    WordDefinitionRM(
      text: json['text'] as String,
      shortText: json['short_text'] as String,
      language: json['language'] as String,
      source: json['source'] as String,
      srcShortTitle: json['src_short_title'] as String,
      sourceUrl: json['source_url'] as String?,
      dictRefId: (json['dict_ref_id'] as num?)?.toInt(),
      wordHyplinks:
          (json['word_hyplinks'] as List<dynamic>?)
              ?.map((e) => WordHyplinkRM.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$WordDefinitionRMToJson(WordDefinitionRM instance) =>
    <String, dynamic>{
      'text': instance.text,
      'short_text': instance.shortText,
      'language': instance.language,
      'source': instance.source,
      'src_short_title': instance.srcShortTitle,
      'source_url': instance.sourceUrl,
      'dict_ref_id': instance.dictRefId,
      'word_hyplinks': instance.wordHyplinks,
    };
