// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_link_res_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShareLinkResDto _$ShareLinkResDtoFromJson(Map<String, dynamic> json) =>
    ShareLinkResDto(
      shareId: json['share_id'] as String,
      shortUrl: json['short_url'] as String,
      deepLink: json['deep_link'] as String,
      shareMessage: json['share_message'] as String,
      expiresAt: json['expires_at'] as String?,
    );

Map<String, dynamic> _$ShareLinkResDtoToJson(ShareLinkResDto instance) =>
    <String, dynamic>{
      'share_id': instance.shareId,
      'short_url': instance.shortUrl,
      'deep_link': instance.deepLink,
      'share_message': instance.shareMessage,
      'expires_at': instance.expiresAt,
    };
