// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'args.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleLoginArgsResult _$GoogleLoginArgsResultFromJson(
  Map<String, dynamic> json,
) => GoogleLoginArgsResult(
  resultCode: json['resultCode'] as String,
  idToken: json['idToken'] as String?,
);

Map<String, dynamic> _$GoogleLoginArgsResultToJson(
  GoogleLoginArgsResult instance,
) => <String, dynamic>{
  'resultCode': instance.resultCode,
  'idToken': instance.idToken,
};
