// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_chunk.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChunkMiscRM _$ChunkMiscRMFromJson(Map<String, dynamic> json) => ChunkMiscRM(
  title: json['title'] as String?,
  value: json['value'] as String?,
);

Map<String, dynamic> _$ChunkMiscRMToJson(ChunkMiscRM instance) =>
    <String, dynamic>{
      'title': instance.title,
      'value': instance.value,
    };

BookChunkRM _$BookChunkRMFromJson(Map<String, dynamic> json) => BookChunkRM(
  text: json['text'] as String?,
  chunkRefId: (json['chunk_ref_id'] as num?)?.toInt(),
  score: (json['score'] as num?)?.toDouble(),
  reference: json['reference'] as String?,
  sourceTitle: json['source_title'] as String?,
  sourceUrl: json['source_url'] as String?,
  sourceType: json['source_type'] as String?,
  isStarred: json['is_starred'] as bool?,
  chunkMisc: (json['chunk_misc'] as List<dynamic>?)
      ?.map((e) => ChunkMiscRM.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BookChunkRMToJson(BookChunkRM instance) =>
    <String, dynamic>{
      'text': instance.text,
      'chunk_ref_id': instance.chunkRefId,
      'score': instance.score,
      'reference': instance.reference,
      'source_title': instance.sourceTitle,
      'source_url': instance.sourceUrl,
      'source_type': instance.sourceType,
      'is_starred': instance.isStarred,
      'chunk_misc': instance.chunkMisc?.map((e) => e.toJson()).toList(),
    };
