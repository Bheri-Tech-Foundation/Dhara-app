import 'dart:convert';

import 'package:dharak_flutter/app/types/verse/verse.dart';
import 'package:dharak_flutter/app/types/verse/verse_foot.dart';
import 'package:dharak_flutter/app/types/verse/verse_head.dart';
import 'package:dharak_flutter/app/types/verse/verses.dart';

class VerseDtoConverter {
  /// Normalize verse JSON to prevent type-cast failures in generated fromJson code
  static void normalizeVerseJson(Map<String, dynamic> json) {
    if (json['word_hyplinks'] == null) {
      json['word_hyplinks'] = <Map<String, dynamic>>[];
    }
    if (json['other_fields'] == null) {
      json['other_fields'] = <Map<String, dynamic>>[];
    }
    if (json['verse_pk'] == null) {
      json['verse_pk'] = 0;
    }
    if (json['similarity'] != null && json['similarity'] is! String) {
      json['similarity'] = json['similarity'].toString();
    }
  }

  static VersesResultRM parseResponse(String rawResponse) {
    List<VerseRM> parsedVerses = [];
    VerseHeadRM? parsedHead;
    VerseFootRM? parsedFoot;

    List<String> lines = rawResponse.trim().split("\n");

    for (var line in lines) {
      Map<String, dynamic>? jsonMap;
      try {
        jsonMap = jsonDecode(line);
      } catch (_) {}
      try {
        if (jsonMap == null || jsonMap.isEmpty) continue;

        final dataType = jsonMap["data_type"];
        if (dataType == null || dataType is! String) continue;

        switch (dataType) {
          case "head":
            parsedHead = VerseHeadRM.fromJson(jsonMap);
            break;
          case "verse":
            normalizeVerseJson(jsonMap);
            parsedVerses.add(VerseRM.fromJson(jsonMap));
            break;
          case "foot":
            parsedFoot = VerseFootRM.fromJson(jsonMap);
            break;
          case "info":
            break;
          default:
            break;
        }
      } catch (_) {
        // Skip malformed entries and continue parsing the rest
      }
    }

    return VersesResultRM(
      foot: parsedFoot,
      head: parsedHead,
      verses: parsedVerses,
    );
  }

  static Map<String, dynamic>? parseResponseJson(String rawResponseLine) {
    try {
      return jsonDecode(rawResponseLine) as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }
}
