import 'package:dharak_flutter/app/types/books/book_chunk.dart';

class DharaInsightChunkRM {
  final String? text;
  final int? chunkRefId;
  final double? score;
  final String? reference;
  final String? sourceTitle;
  final String? sourceUrl;
  final String? sourceType;
  final bool? isStarred;
  final List<ChunkMiscRM>? chunkMisc;

  DharaInsightChunkRM({
    this.text,
    this.chunkRefId,
    this.score,
    this.reference,
    this.sourceTitle,
    this.sourceUrl,
    this.sourceType,
    this.isStarred,
    this.chunkMisc,
  });

  factory DharaInsightChunkRM.fromJson(Map<String, dynamic> json) {
    return DharaInsightChunkRM(
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
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'chunk_ref_id': chunkRefId,
    'score': score,
    'reference': reference,
    'source_title': sourceTitle,
    'source_url': sourceUrl,
    'source_type': sourceType,
    'is_starred': isStarred,
    'chunk_misc': chunkMisc?.map((e) => e.toJson()).toList(),
  };

  BookChunkRM toBookChunkRM() {
    return BookChunkRM(
      text: text,
      chunkRefId: chunkRefId,
      score: score,
      reference: reference,
      sourceTitle: sourceTitle,
      sourceUrl: sourceUrl,
      sourceType: sourceType,
      isStarred: isStarred,
      chunkMisc: chunkMisc,
    );
  }

  DharaInsightChunkRM copyWith({
    String? text,
    int? chunkRefId,
    double? score,
    String? reference,
    String? sourceTitle,
    String? sourceUrl,
    String? sourceType,
    bool? isStarred,
    List<ChunkMiscRM>? chunkMisc,
  }) {
    return DharaInsightChunkRM(
      text: text ?? this.text,
      chunkRefId: chunkRefId ?? this.chunkRefId,
      score: score ?? this.score,
      reference: reference ?? this.reference,
      sourceTitle: sourceTitle ?? this.sourceTitle,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      sourceType: sourceType ?? this.sourceType,
      isStarred: isStarred ?? this.isStarred,
      chunkMisc: chunkMisc ?? this.chunkMisc,
    );
  }
}

class DharaInsightsResultRM {
  final bool success;
  final List<DharaInsightChunkRM> data;

  DharaInsightsResultRM({
    required this.success,
    required this.data,
  });

  factory DharaInsightsResultRM.fromJson(Map<String, dynamic> json) {
    return DharaInsightsResultRM(
      success: json['success'] as bool,
      data: (json['data'] as List<dynamic>)
          .map((e) => DharaInsightChunkRM.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
