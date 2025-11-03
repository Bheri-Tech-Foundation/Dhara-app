// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'definition_copy_req_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DefinitionCopyReqDto _$DefinitionCopyReqDtoFromJson(
  Map<String, dynamic> json,
) => DefinitionCopyReqDto(
  defnIds:
      (json['defn_ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
);

Map<String, dynamic> _$DefinitionCopyReqDtoToJson(
  DefinitionCopyReqDto instance,
) => <String, dynamic>{'defn_ids': instance.defnIds};
