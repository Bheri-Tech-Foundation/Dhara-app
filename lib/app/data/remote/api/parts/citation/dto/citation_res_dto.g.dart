// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'citation_res_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CitationResDto _$CitationResDtoFromJson(Map<String, dynamic> json) =>
    CitationResDto(
      citeData:
          json['cite_data'] == null
              ? null
              : CitationDataDto.fromJson(
                json['cite_data'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$CitationResDtoToJson(CitationResDto instance) =>
    <String, dynamic>{'cite_data': instance.citeData};

CitationDataDto _$CitationDataDtoFromJson(Map<String, dynamic> json) =>
    CitationDataDto(
      apa: json['APA'] as String,
      mla: json['MLA'] as String,
      harvard: json['Harvard'] as String,
      chicago: json['Chichago'] as String,
      vancouver: json['Vancouver'] as String,
    );

Map<String, dynamic> _$CitationDataDtoToJson(CitationDataDto instance) =>
    <String, dynamic>{
      'APA': instance.apa,
      'MLA': instance.mla,
      'Harvard': instance.harvard,
      'Chichago': instance.chicago,
      'Vancouver': instance.vancouver,
    };
