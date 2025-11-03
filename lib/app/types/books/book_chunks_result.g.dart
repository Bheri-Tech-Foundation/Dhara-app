// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_chunks_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookChunksResultRM _$BookChunksResultRMFromJson(Map<String, dynamic> json) =>
    BookChunksResultRM(
      success: json['success'] as bool,
      data:
          (json['data'] as List<dynamic>)
              .map((e) => BookChunkRM.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$BookChunksResultRMToJson(BookChunksResultRM instance) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};
