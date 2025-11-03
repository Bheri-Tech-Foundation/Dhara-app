// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_req_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShareReqDto _$ShareReqDtoFromJson(Map<String, dynamic> json) => ShareReqDto(
  contentType: json['content_type'] as String,
  contentId: json['content_id'] as String,
  platform: json['platform'] as String,
  shareType: json['share_type'] as String,
  userId: json['user_id'] as String?,
);

Map<String, dynamic> _$ShareReqDtoToJson(ShareReqDto instance) =>
    <String, dynamic>{
      'content_type': instance.contentType,
      'content_id': instance.contentId,
      'platform': instance.platform,
      'share_type': instance.shareType,
      'user_id': instance.userId,
    };
