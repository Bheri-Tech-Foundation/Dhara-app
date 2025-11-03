// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_citation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookChunkCitationRM _$BookChunkCitationRMFromJson(Map<String, dynamic> json) =>
    BookChunkCitationRM(
      citeData: BookCitationData.fromJson(
        json['cite_data'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$BookChunkCitationRMToJson(
  BookChunkCitationRM instance,
) => <String, dynamic>{'cite_data': instance.citeData};

BookCitationData _$BookCitationDataFromJson(Map<String, dynamic> json) =>
    BookCitationData(footnote: json['Footnote'] as String);

Map<String, dynamic> _$BookCitationDataToJson(BookCitationData instance) =>
    <String, dynamic>{'Footnote': instance.footnote};
