// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verse_citation_res_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerseCitationResDto _$VerseCitationResDtoFromJson(Map<String, dynamic> json) =>
    VerseCitationResDto(
      citeData:
          json['cite_data'] == null
              ? null
              : VerseCitationDataDto.fromJson(
                json['cite_data'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$VerseCitationResDtoToJson(
  VerseCitationResDto instance,
) => <String, dynamic>{'cite_data': instance.citeData};

VerseCitationDataDto _$VerseCitationDataDtoFromJson(
  Map<String, dynamic> json,
) => VerseCitationDataDto(footnote: json['Footnote'] as String);

Map<String, dynamic> _$VerseCitationDataDtoToJson(
  VerseCitationDataDto instance,
) => <String, dynamic>{'Footnote': instance.footnote};
