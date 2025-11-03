// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_chunk_nav_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookChunkNextResultRM _$BookChunkNextResultRMFromJson(
  Map<String, dynamic> json,
) => BookChunkNextResultRM(
  nextSib:
      json['next_sib'] == null
          ? null
          : BookChunkRM.fromJson(json['next_sib'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BookChunkNextResultRMToJson(
  BookChunkNextResultRM instance,
) => <String, dynamic>{'next_sib': instance.nextSib};

BookChunkPrevResultRM _$BookChunkPrevResultRMFromJson(
  Map<String, dynamic> json,
) => BookChunkPrevResultRM(
  prevSib:
      json['prev_sib'] == null
          ? null
          : BookChunkRM.fromJson(json['prev_sib'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BookChunkPrevResultRMToJson(
  BookChunkPrevResultRM instance,
) => <String, dynamic>{'prev_sib': instance.prevSib};
