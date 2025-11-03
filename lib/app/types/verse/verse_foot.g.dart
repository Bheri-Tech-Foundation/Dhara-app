// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse_foot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerseFootRM _$VerseFootRMFromJson(Map<String, dynamic> json) => VerseFootRM(
  dataType: json['data_type'] as String,
  totalVerse: (json['total_verse'] as num).toInt(),
);

Map<String, dynamic> _$VerseFootRMToJson(VerseFootRM instance) =>
    <String, dynamic>{
      'data_type': instance.dataType,
      'total_verse': instance.totalVerse,
    };
