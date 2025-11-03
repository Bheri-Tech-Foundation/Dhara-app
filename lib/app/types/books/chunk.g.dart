// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chunk.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookChunkRM _$BookChunkRMFromJson(Map<String, dynamic> json) => BookChunkRM(
  text: json['text'] as String,
  chunkRefId: (json['chunk_ref_id'] as num).toInt(),
  score: (json['score'] as num).toDouble(),
  reference: json['reference'] as String,
);

Map<String, dynamic> _$BookChunkRMToJson(BookChunkRM instance) =>
    <String, dynamic>{
      'text': instance.text,
      'chunk_ref_id': instance.chunkRefId,
      'score': instance.score,
      'reference': instance.reference,
    };

BookChunksResponseRM _$BookChunksResponseRMFromJson(
  Map<String, dynamic> json,
) => BookChunksResponseRM(
  success: json['success'] as bool,
  data:
      (json['data'] as List<dynamic>)
          .map((e) => BookChunkRM.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$BookChunksResponseRMToJson(
  BookChunksResponseRM instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};
