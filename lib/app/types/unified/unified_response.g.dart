// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnifiedResponseItem _$UnifiedResponseItemFromJson(Map<String, dynamic> json) =>
    UnifiedResponseItem(type: json['type'] as String, data: json['data']);

Map<String, dynamic> _$UnifiedResponseItemToJson(
  UnifiedResponseItem instance,
) => <String, dynamic>{'type': instance.type, 'data': instance.data};

QuerySplitsRM _$QuerySplitsRMFromJson(
  Map<String, dynamic> json,
) => QuerySplitsRM(
  nouns: (json['nouns'] as List<dynamic>).map((e) => e as String).toList(),
  verbs:
      (json['verbs'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  quotedTexts:
      (json['quoted_texts'] as List<dynamic>).map((e) => e as String).toList(),
  heritageQuery: json['heritage_query'] as String,
);

Map<String, dynamic> _$QuerySplitsRMToJson(QuerySplitsRM instance) =>
    <String, dynamic>{
      'nouns': instance.nouns,
      'verbs': instance.verbs,
      'quoted_texts': instance.quotedTexts,
      'heritage_query': instance.heritageQuery,
    };
