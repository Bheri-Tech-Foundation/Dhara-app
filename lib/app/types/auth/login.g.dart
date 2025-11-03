// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthLoginRM _$AuthLoginRMFromJson(Map<String, dynamic> json) => AuthLoginRM(
  accessToken: json['access_token'] as String,
  refreshToken: json['refresh_token'] as String,
  user:
      json['user'] == null
          ? null
          : UserRM.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuthLoginRMToJson(AuthLoginRM instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
      'user': instance.user,
    };
