// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dict_word_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DictWordDetailRM _$DictWordDetailRMFromJson(Map<String, dynamic> json) =>
    DictWordDetailRM(
      llmDef: json['llm_def'] as String?,
      word: json['word'] as String?,
      definitions:
          (json['definitions'] as List<dynamic>?)
              ?.map((e) => WordDefinitionRM.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      otherScripts:
          (json['other_scripts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String?),
          ) ??
          const {},
    );

Map<String, dynamic> _$DictWordDetailRMToJson(DictWordDetailRM instance) =>
    <String, dynamic>{
      'llm_def': instance.llmDef,
      'word': instance.word,
      'definitions': instance.definitions,
      'other_scripts': instance.otherScripts,
    };
