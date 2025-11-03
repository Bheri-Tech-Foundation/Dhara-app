// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_definitions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DictWordDefinitionsRM _$DictWordDefinitionsRMFromJson(
  Map<String, dynamic> json,
) => DictWordDefinitionsRM(
  givenWord: json['given_word'] as String,
  success: json['success'] as bool,
  foundMatch: json['found_match'] as bool?,
  details: DictWordDetailRM.fromJson(json['details'] as Map<String, dynamic>),
  similarWords:
      (json['similar_words'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$DictWordDefinitionsRMToJson(
  DictWordDefinitionsRM instance,
) => <String, dynamic>{
  'given_word': instance.givenWord,
  'success': instance.success,
  'found_match': instance.foundMatch,
  'details': instance.details,
  'similar_words': instance.similarWords,
};
