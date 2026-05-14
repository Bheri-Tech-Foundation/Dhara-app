import 'dart:async';
import 'package:dharak_flutter/app/data/services/developer_mode_service.dart';
import 'package:dharak_flutter/app/types/dhara_insights/dhara_insight_chunk.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dio/dio.dart';

class DharaInsightsService extends Disposable {
  static final DharaInsightsService _instance = DharaInsightsService._internal();
  static DharaInsightsService get instance => _instance;

  DharaInsightsService._internal() {
    _dio = Modular.get<Dio>();
  }

  late final Dio _dio;

  final BehaviorSubject<List<DharaInsightChunkRM>> _currentChunks = BehaviorSubject.seeded([]);
  Stream<List<DharaInsightChunkRM>> get currentChunks => _currentChunks.stream;

  final BehaviorSubject<bool> _isLoading = BehaviorSubject.seeded(false);
  Stream<bool> get isLoadingStream => _isLoading.stream;
  bool get isLoading => _isLoading.value;

  final BehaviorSubject<String?> _error = BehaviorSubject.seeded(null);
  Stream<String?> get errorStream => _error.stream;

  Future<List<DharaInsightChunkRM>> searchDharaInsights(String query) async {
    try {
      _isLoading.add(true);
      _error.add(null);

      final baseUrl = DeveloperModeService.instance.getEffectiveApiUrl();

      final response = await _dio.get(
        '$baseUrl/chunk/multivec_dhara/',
        queryParameters: {'inp_str': query},
        options: Options(
          headers: {'accept': '*/*'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final result = DharaInsightsResultRM.fromJson(response.data);

        if (result.success && result.data.isNotEmpty) {
          _currentChunks.add(result.data);
          _isLoading.add(false);
          return result.data;
        }
      }

      _currentChunks.add([]);
      _isLoading.add(false);
      return [];
    } catch (e) {
      _error.add('Failed to fetch Dhara Insights: $e');
      _isLoading.add(false);
      return [];
    }
  }

  void clearResults() {
    _currentChunks.add([]);
    _error.add(null);
  }

  @override
  void dispose() {
    _currentChunks.close();
    _isLoading.close();
    _error.close();
  }
}
