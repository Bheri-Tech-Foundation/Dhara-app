// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'getall_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerseBookmarkGetAllDto _$VerseBookmarkGetAllDtoFromJson(
  Map<String, dynamic> json,
) => VerseBookmarkGetAllDto(
  message: json['message'] as String,
  data:
      (json['data'] as List<dynamic>)
          .map((e) => VerseBookmarkRM.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$VerseBookmarkGetAllDtoToJson(
  VerseBookmarkGetAllDto instance,
) => <String, dynamic>{'message': instance.message, 'data': instance.data};
