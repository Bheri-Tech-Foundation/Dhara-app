import 'package:json_annotation/json_annotation.dart';

part 'book_chunk.g.dart';

@JsonSerializable()
class ChunkMiscRM {
  final String? title;
  final String? value;

  ChunkMiscRM({this.title, this.value});

  factory ChunkMiscRM.fromJson(Map<String, dynamic> json) =>
      _$ChunkMiscRMFromJson(json);

  Map<String, dynamic> toJson() => _$ChunkMiscRMToJson(this);
}

@JsonSerializable()
class BookChunkRM {
  final String? text;
  
  @JsonKey(name: 'chunk_ref_id')
  final int? chunkRefId;
  
  final double? score;
  final String? reference;
  
  @JsonKey(name: 'source_title')
  final String? sourceTitle;
  
  @JsonKey(name: 'source_url')
  final String? sourceUrl;
  
  @JsonKey(name: 'source_type')
  final String? sourceType;
  
  @JsonKey(name: 'is_starred')
  final bool? isStarred;

  @JsonKey(name: 'chunk_misc')
  final List<ChunkMiscRM>? chunkMisc;

  BookChunkRM({
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

  factory BookChunkRM.fromJson(Map<String, dynamic> json) =>
      _$BookChunkRMFromJson(json);

  Map<String, dynamic> toJson() => _$BookChunkRMToJson(this);
  
  BookChunkRM copyWith({
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
    return BookChunkRM(
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

