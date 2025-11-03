// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersesResultRM _$VersesResultRMFromJson(Map<String, dynamic> json) =>
    VersesResultRM(
      head:
          json['head'] == null
              ? null
              : VerseHeadRM.fromJson(json['head'] as Map<String, dynamic>),
      verses:
          (json['verses'] as List<dynamic>)
              .map((e) => VerseRM.fromJson(e as Map<String, dynamic>))
              .toList(),
      foot:
          json['foot'] == null
              ? null
              : VerseFootRM.fromJson(json['foot'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VersesResultRMToJson(VersesResultRM instance) =>
    <String, dynamic>{
      'head': instance.head,
      'verses': instance.verses,
      'foot': instance.foot,
    };
