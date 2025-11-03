// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShareLinkRM _$ShareLinkRMFromJson(Map<String, dynamic> json) => ShareLinkRM(
  shareId: json['shareId'] as String,
  shortUrl: json['shortUrl'] as String,
  deepLink: json['deepLink'] as String,
  shareMessage: json['shareMessage'] as String,
  expiresAt: json['expiresAt'] as String?,
);

Map<String, dynamic> _$ShareLinkRMToJson(ShareLinkRM instance) =>
    <String, dynamic>{
      'shareId': instance.shareId,
      'shortUrl': instance.shortUrl,
      'deepLink': instance.deepLink,
      'shareMessage': instance.shareMessage,
      'expiresAt': instance.expiresAt,
    };
