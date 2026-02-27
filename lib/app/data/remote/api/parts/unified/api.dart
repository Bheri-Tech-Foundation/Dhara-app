import 'package:dharak_flutter/app/data/remote/api/parts/unified/api_point_simple.dart';
import 'package:dharak_flutter/app/types/unified/unified_search_response.dart';

class UnifiedSearchApiRepo {
  final UnifiedSearchApiPointSimple _apiPoint = UnifiedSearchApiPointSimple();

  /// Perform unified search and return combined results
  Future<UnifiedSearchResult> search(String query) async {
    try {
      final result = await _apiPoint.processUnifiedSearch(query);
      
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// Get streaming results for real-time updates
  Stream<UnifiedSearchResponse> searchStream(String query) {
    return _apiPoint.unifiedSearch(query);
  }
}
