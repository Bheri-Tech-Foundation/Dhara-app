// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse_prev_next_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersePrevNextResultRM _$VersePrevNextResultRMFromJson(
  Map<String, dynamic> json,
) => VersePrevNextResultRM(
  success: json['success'] as bool?,
  message: json['message'] as String,
  prevSib:
      json['prev_sib'] == null
          ? null
          : VerseRM.fromJson(json['prev_sib'] as Map<String, dynamic>),
  nextSib:
      json['next_sib'] == null
          ? null
          : VerseRM.fromJson(json['next_sib'] as Map<String, dynamic>),
);

Map<String, dynamic> _$VersePrevNextResultRMToJson(
  VersePrevNextResultRM instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'prev_sib': instance.prevSib,
  'next_sib': instance.nextSib,
};
