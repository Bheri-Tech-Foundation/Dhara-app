// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_login_req_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthLoginReqDto _$AuthLoginReqDtoFromJson(Map<String, dynamic> json) =>
    AuthLoginReqDto(
      accessToken: json['access_token'] as String?,
      idToken: json['id_token'] as String?,
      client: json['client'] as String?,
    );

Map<String, dynamic> _$AuthLoginReqDtoToJson(AuthLoginReqDto instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'id_token': instance.idToken,
      'client': instance.client,
    };
