// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit_states.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SearchHistoryCubitStateCWProxy {
  SearchHistoryCubitState isLoading(bool? isLoading);

  SearchHistoryCubitState isInitialized(bool? isInitialized);

  SearchHistoryCubitState result(SearchHistoryArgsResult? result);

  SearchHistoryCubitState retryCounter(int? retryCounter);

  SearchHistoryCubitState toastCounter(int? toastCounter);

  SearchHistoryCubitState isEmpty(bool? isEmpty);

  SearchHistoryCubitState message(String? message);

  SearchHistoryCubitState isInProgress(bool? isInProgress);

  SearchHistoryCubitState isForVerse(bool isForVerse);

  SearchHistoryCubitState searchHistoryList(List<String>? searchHistoryList);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SearchHistoryCubitState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SearchHistoryCubitState(...).copyWith(id: 12, name: "My name")
  /// ````
  SearchHistoryCubitState call({
    bool? isLoading,
    bool? isInitialized,
    SearchHistoryArgsResult? result,
    int? retryCounter,
    int? toastCounter,
    bool? isEmpty,
    String? message,
    bool? isInProgress,
    bool isForVerse,
    List<String>? searchHistoryList,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSearchHistoryCubitState.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSearchHistoryCubitState.copyWith.fieldName(...)`
class _$SearchHistoryCubitStateCWProxyImpl
    implements _$SearchHistoryCubitStateCWProxy {
  const _$SearchHistoryCubitStateCWProxyImpl(this._value);

  final SearchHistoryCubitState _value;

  @override
  SearchHistoryCubitState isLoading(bool? isLoading) =>
      this(isLoading: isLoading);

  @override
  SearchHistoryCubitState isInitialized(bool? isInitialized) =>
      this(isInitialized: isInitialized);

  @override
  SearchHistoryCubitState result(SearchHistoryArgsResult? result) =>
      this(result: result);

  @override
  SearchHistoryCubitState retryCounter(int? retryCounter) =>
      this(retryCounter: retryCounter);

  @override
  SearchHistoryCubitState toastCounter(int? toastCounter) =>
      this(toastCounter: toastCounter);

  @override
  SearchHistoryCubitState isEmpty(bool? isEmpty) => this(isEmpty: isEmpty);

  @override
  SearchHistoryCubitState message(String? message) => this(message: message);

  @override
  SearchHistoryCubitState isInProgress(bool? isInProgress) =>
      this(isInProgress: isInProgress);

  @override
  SearchHistoryCubitState isForVerse(bool isForVerse) =>
      this(isForVerse: isForVerse);

  @override
  SearchHistoryCubitState searchHistoryList(List<String>? searchHistoryList) =>
      this(searchHistoryList: searchHistoryList);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SearchHistoryCubitState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SearchHistoryCubitState(...).copyWith(id: 12, name: "My name")
  /// ````
  SearchHistoryCubitState call({
    Object? isLoading = const $CopyWithPlaceholder(),
    Object? isInitialized = const $CopyWithPlaceholder(),
    Object? result = const $CopyWithPlaceholder(),
    Object? retryCounter = const $CopyWithPlaceholder(),
    Object? toastCounter = const $CopyWithPlaceholder(),
    Object? isEmpty = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? isInProgress = const $CopyWithPlaceholder(),
    Object? isForVerse = const $CopyWithPlaceholder(),
    Object? searchHistoryList = const $CopyWithPlaceholder(),
  }) {
    return SearchHistoryCubitState(
      isLoading:
          isLoading == const $CopyWithPlaceholder()
              ? _value.isLoading
              // ignore: cast_nullable_to_non_nullable
              : isLoading as bool?,
      isInitialized:
          isInitialized == const $CopyWithPlaceholder()
              ? _value.isInitialized
              // ignore: cast_nullable_to_non_nullable
              : isInitialized as bool?,
      result:
          result == const $CopyWithPlaceholder()
              ? _value.result
              // ignore: cast_nullable_to_non_nullable
              : result as SearchHistoryArgsResult?,
      retryCounter:
          retryCounter == const $CopyWithPlaceholder()
              ? _value.retryCounter
              // ignore: cast_nullable_to_non_nullable
              : retryCounter as int?,
      toastCounter:
          toastCounter == const $CopyWithPlaceholder()
              ? _value.toastCounter
              // ignore: cast_nullable_to_non_nullable
              : toastCounter as int?,
      isEmpty:
          isEmpty == const $CopyWithPlaceholder()
              ? _value.isEmpty
              // ignore: cast_nullable_to_non_nullable
              : isEmpty as bool?,
      message:
          message == const $CopyWithPlaceholder()
              ? _value.message
              // ignore: cast_nullable_to_non_nullable
              : message as String?,
      isInProgress:
          isInProgress == const $CopyWithPlaceholder()
              ? _value.isInProgress
              // ignore: cast_nullable_to_non_nullable
              : isInProgress as bool?,
      isForVerse:
          isForVerse == const $CopyWithPlaceholder()
              ? _value.isForVerse
              // ignore: cast_nullable_to_non_nullable
              : isForVerse as bool,
      searchHistoryList:
          searchHistoryList == const $CopyWithPlaceholder()
              ? _value.searchHistoryList
              // ignore: cast_nullable_to_non_nullable
              : searchHistoryList as List<String>?,
    );
  }
}

extension $SearchHistoryCubitStateCopyWith on SearchHistoryCubitState {
  /// Returns a callable class that can be used as follows: `instanceOfSearchHistoryCubitState.copyWith(...)` or like so:`instanceOfSearchHistoryCubitState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SearchHistoryCubitStateCWProxy get copyWith =>
      _$SearchHistoryCubitStateCWProxyImpl(this);
}
