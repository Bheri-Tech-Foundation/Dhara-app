// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerseLanguagePrefGetResultDto _$VerseLanguagePrefGetResultDtoFromJson(
  Map<String, dynamic> json,
) => VerseLanguagePrefGetResultDto(
  message: json['message'] as String?,
  success: json['success'] as bool?,
  opLangPref: json['op_lang_pref'] as String?,
);

Map<String, dynamic> _$VerseLanguagePrefGetResultDtoToJson(
  VerseLanguagePrefGetResultDto instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'op_lang_pref': instance.opLangPref,
};
