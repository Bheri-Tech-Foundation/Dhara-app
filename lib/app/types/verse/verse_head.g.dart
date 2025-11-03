// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse_head.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerseHeadRM _$VerseHeadRMFromJson(Map<String, dynamic> json) => VerseHeadRM(
  dataType: json['data_type'] as String,
  inputString: json['input_string'] as String?,
  searchScripts:
      (json['search_scripts'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  inputScript: json['input_script'] as String?,
  outputScript: json['output_script'] as String?,
);

Map<String, dynamic> _$VerseHeadRMToJson(VerseHeadRM instance) =>
    <String, dynamic>{
      'data_type': instance.dataType,
      'input_string': instance.inputString,
      'search_scripts': instance.searchScripts,
      'input_script': instance.inputScript,
      'output_script': instance.outputScript,
    };
