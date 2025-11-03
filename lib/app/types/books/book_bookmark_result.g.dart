// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_bookmark_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookChunkBookmarkToggleResultRM _$BookChunkBookmarkToggleResultRMFromJson(
  Map<String, dynamic> json,
) => BookChunkBookmarkToggleResultRM(
  message: json['message'] as String,
  success: json['success'] as bool?,
);

Map<String, dynamic> _$BookChunkBookmarkToggleResultRMToJson(
  BookChunkBookmarkToggleResultRM instance,
) => <String, dynamic>{
  'message': instance.message,
  'success': instance.success,
};

BookChunkStarredListResultRM _$BookChunkStarredListResultRMFromJson(
  Map<String, dynamic> json,
) => BookChunkStarredListResultRM(
  chunks:
      (json['chunks'] as List<dynamic>)
          .map((e) => BookChunkRM.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$BookChunkStarredListResultRMToJson(
  BookChunkStarredListResultRM instance,
) => <String, dynamic>{'chunks': instance.chunks};
