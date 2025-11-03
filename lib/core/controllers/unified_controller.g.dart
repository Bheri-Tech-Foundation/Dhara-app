// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unified_controller.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UnifiedStateCWProxy {
  UnifiedState searchResults(List<UnifiedSearchResult> searchResults);

  UnifiedState isLoading(bool isLoading);

  UnifiedState isStreaming(bool isStreaming);

  UnifiedState error(String? error);

  UnifiedState currentQuery(String currentQuery);

  UnifiedState searchCounter(int searchCounter);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UnifiedState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UnifiedState(...).copyWith(id: 12, name: "My name")
  /// ````
  UnifiedState call({
    List<UnifiedSearchResult> searchResults,
    bool isLoading,
    bool isStreaming,
    String? error,
    String currentQuery,
    int searchCounter,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUnifiedState.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUnifiedState.copyWith.fieldName(...)`
class _$UnifiedStateCWProxyImpl implements _$UnifiedStateCWProxy {
  const _$UnifiedStateCWProxyImpl(this._value);

  final UnifiedState _value;

  @override
  UnifiedState searchResults(List<UnifiedSearchResult> searchResults) =>
      this(searchResults: searchResults);

  @override
  UnifiedState isLoading(bool isLoading) => this(isLoading: isLoading);

  @override
  UnifiedState isStreaming(bool isStreaming) => this(isStreaming: isStreaming);

  @override
  UnifiedState error(String? error) => this(error: error);

  @override
  UnifiedState currentQuery(String currentQuery) =>
      this(currentQuery: currentQuery);

  @override
  UnifiedState searchCounter(int searchCounter) =>
      this(searchCounter: searchCounter);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UnifiedState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UnifiedState(...).copyWith(id: 12, name: "My name")
  /// ````
  UnifiedState call({
    Object? searchResults = const $CopyWithPlaceholder(),
    Object? isLoading = const $CopyWithPlaceholder(),
    Object? isStreaming = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? currentQuery = const $CopyWithPlaceholder(),
    Object? searchCounter = const $CopyWithPlaceholder(),
  }) {
    return UnifiedState(
      searchResults:
          searchResults == const $CopyWithPlaceholder()
              ? _value.searchResults
              // ignore: cast_nullable_to_non_nullable
              : searchResults as List<UnifiedSearchResult>,
      isLoading:
          isLoading == const $CopyWithPlaceholder()
              ? _value.isLoading
              // ignore: cast_nullable_to_non_nullable
              : isLoading as bool,
      isStreaming:
          isStreaming == const $CopyWithPlaceholder()
              ? _value.isStreaming
              // ignore: cast_nullable_to_non_nullable
              : isStreaming as bool,
      error:
          error == const $CopyWithPlaceholder()
              ? _value.error
              // ignore: cast_nullable_to_non_nullable
              : error as String?,
      currentQuery:
          currentQuery == const $CopyWithPlaceholder()
              ? _value.currentQuery
              // ignore: cast_nullable_to_non_nullable
              : currentQuery as String,
      searchCounter:
          searchCounter == const $CopyWithPlaceholder()
              ? _value.searchCounter
              // ignore: cast_nullable_to_non_nullable
              : searchCounter as int,
    );
  }
}

extension $UnifiedStateCopyWith on UnifiedState {
  /// Returns a callable class that can be used as follows: `instanceOfUnifiedState.copyWith(...)` or like so:`instanceOfUnifiedState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UnifiedStateCWProxy get copyWith => _$UnifiedStateCWProxyImpl(this);
}
