// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchHistoryResultRM _$SearchHistoryResultRMFromJson(
  Map<String, dynamic> json,
) => SearchHistoryResultRM(
  success: json['success'] as bool?,
  history: (json['history'] as List<dynamic>).map((e) => e as String).toList(),
  message: json['message'] as String?,
);

Map<String, dynamic> _$SearchHistoryResultRMToJson(
  SearchHistoryResultRM instance,
) => <String, dynamic>{
  'success': instance.success,
  'history': instance.history,
  'message': instance.message,
};
