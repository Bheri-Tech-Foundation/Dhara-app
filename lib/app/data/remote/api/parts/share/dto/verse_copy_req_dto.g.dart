// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse_copy_req_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerseCopyReqDto _$VerseCopyReqDtoFromJson(Map<String, dynamic> json) =>
    VerseCopyReqDto(
      verseIds:
          (json['verse_ids'] as List<dynamic>)
              .map((e) => (e as num).toInt())
              .toList(),
    );

Map<String, dynamic> _$VerseCopyReqDtoToJson(VerseCopyReqDto instance) =>
    <String, dynamic>{'verse_ids': instance.verseIds};
