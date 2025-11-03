// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorDto _$ErrorDtoFromJson(Map<String, dynamic> json) => ErrorDto(
  httpCode: (json['httpCode'] as num?)?.toInt() ?? 500,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  error: json['error'] as String?,
  success: json['success'] as bool? ?? false,
  message: json['message'] as String?,
);

Map<String, dynamic> _$ErrorDtoToJson(ErrorDto instance) => <String, dynamic>{
  'httpCode': instance.httpCode,
  'statusCode': instance.statusCode,
  'error': instance.error,
  'success': instance.success,
  'message': instance.message,
};
