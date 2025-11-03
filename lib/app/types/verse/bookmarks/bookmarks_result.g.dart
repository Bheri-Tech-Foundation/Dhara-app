// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmarks_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerseBookmarksResultRM _$VerseBookmarksResultRMFromJson(
  Map<String, dynamic> json,
) => VerseBookmarksResultRM(
  message: json['message'] as String,
  verse:
      (json['verse'] as List<dynamic>)
          .map((e) => VerseBookmarkRM.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$VerseBookmarksResultRMToJson(
  VerseBookmarksResultRM instance,
) => <String, dynamic>{'message': instance.message, 'verse': instance.verse};
