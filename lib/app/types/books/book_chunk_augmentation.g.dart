// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_chunk_augmentation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookChunkAugmentationListRM _$BookChunkAugmentationListRMFromJson(
  Map<String, dynamic> json,
) => BookChunkAugmentationListRM(
  augmentations:
      (json['augmentations'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$BookChunkAugmentationListRMToJson(
  BookChunkAugmentationListRM instance,
) => <String, dynamic>{'augmentations': instance.augmentations};

BookChunkAugmentedRM _$BookChunkAugmentedRMFromJson(
  Map<String, dynamic> json,
) => BookChunkAugmentedRM(
  data: BookChunkRM.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BookChunkAugmentedRMToJson(
  BookChunkAugmentedRM instance,
) => <String, dynamic>{'data': instance.data};

BookChunkOriginalRM _$BookChunkOriginalRMFromJson(Map<String, dynamic> json) =>
    BookChunkOriginalRM(
      chunk: BookChunkRM.fromJson(json['chunk'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BookChunkOriginalRMToJson(
  BookChunkOriginalRM instance,
) => <String, dynamic>{'chunk': instance.chunk};
