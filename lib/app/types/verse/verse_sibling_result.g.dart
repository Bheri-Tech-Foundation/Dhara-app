// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse_sibling_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersePrevSiblingResultRM _$VersePrevSiblingResultRMFromJson(
  Map<String, dynamic> json,
) => VersePrevSiblingResultRM(
  success: json['success'] as bool?,
  message: json['message'] as String,
  prevSib:
      json['prev_sib'] == null
          ? null
          : VerseRM.fromJson(json['prev_sib'] as Map<String, dynamic>),
);

Map<String, dynamic> _$VersePrevSiblingResultRMToJson(
  VersePrevSiblingResultRM instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'prev_sib': instance.prevSib,
};

VerseNextSiblingResultRM _$VerseNextSiblingResultRMFromJson(
  Map<String, dynamic> json,
) => VerseNextSiblingResultRM(
  success: json['success'] as bool?,
  message: json['message'] as String,
  nextSib:
      json['next_sib'] == null
          ? null
          : VerseRM.fromJson(json['next_sib'] as Map<String, dynamic>),
);

Map<String, dynamic> _$VerseNextSiblingResultRMToJson(
  VerseNextSiblingResultRM instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'next_sib': instance.nextSib,
};
