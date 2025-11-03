// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quicksearch_controller.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$QuickSearchStateCWProxy {
  QuickSearchState currentSearchType(SearchType currentSearchType);

  QuickSearchState isLoading(bool isLoading);

  QuickSearchState error(String? error);

  QuickSearchState searchQuery(String searchQuery);

  QuickSearchState showClearButton(bool showClearButton);

  QuickSearchState wordDefineResult(DictWordDefinitionsRM? wordDefineResult);

  QuickSearchState verseResults(List<VerseRM> verseResults);

  QuickSearchState bookResults(List<BookChunkRM> bookResults);

  QuickSearchState searchCounter(int searchCounter);

  QuickSearchState typeChangeCounter(int typeChangeCounter);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `QuickSearchState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// QuickSearchState(...).copyWith(id: 12, name: "My name")
  /// ````
  QuickSearchState call({
    SearchType currentSearchType,
    bool isLoading,
    String? error,
    String searchQuery,
    bool showClearButton,
    DictWordDefinitionsRM? wordDefineResult,
    List<VerseRM> verseResults,
    List<BookChunkRM> bookResults,
    int searchCounter,
    int typeChangeCounter,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfQuickSearchState.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfQuickSearchState.copyWith.fieldName(...)`
class _$QuickSearchStateCWProxyImpl implements _$QuickSearchStateCWProxy {
  const _$QuickSearchStateCWProxyImpl(this._value);

  final QuickSearchState _value;

  @override
  QuickSearchState currentSearchType(SearchType currentSearchType) =>
      this(currentSearchType: currentSearchType);

  @override
  QuickSearchState isLoading(bool isLoading) => this(isLoading: isLoading);

  @override
  QuickSearchState error(String? error) => this(error: error);

  @override
  QuickSearchState searchQuery(String searchQuery) =>
      this(searchQuery: searchQuery);

  @override
  QuickSearchState showClearButton(bool showClearButton) =>
      this(showClearButton: showClearButton);

  @override
  QuickSearchState wordDefineResult(DictWordDefinitionsRM? wordDefineResult) =>
      this(wordDefineResult: wordDefineResult);

  @override
  QuickSearchState verseResults(List<VerseRM> verseResults) =>
      this(verseResults: verseResults);

  @override
  QuickSearchState bookResults(List<BookChunkRM> bookResults) =>
      this(bookResults: bookResults);

  @override
  QuickSearchState searchCounter(int searchCounter) =>
      this(searchCounter: searchCounter);

  @override
  QuickSearchState typeChangeCounter(int typeChangeCounter) =>
      this(typeChangeCounter: typeChangeCounter);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `QuickSearchState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// QuickSearchState(...).copyWith(id: 12, name: "My name")
  /// ````
  QuickSearchState call({
    Object? currentSearchType = const $CopyWithPlaceholder(),
    Object? isLoading = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? searchQuery = const $CopyWithPlaceholder(),
    Object? showClearButton = const $CopyWithPlaceholder(),
    Object? wordDefineResult = const $CopyWithPlaceholder(),
    Object? verseResults = const $CopyWithPlaceholder(),
    Object? bookResults = const $CopyWithPlaceholder(),
    Object? searchCounter = const $CopyWithPlaceholder(),
    Object? typeChangeCounter = const $CopyWithPlaceholder(),
  }) {
    return QuickSearchState(
      currentSearchType:
          currentSearchType == const $CopyWithPlaceholder()
              ? _value.currentSearchType
              // ignore: cast_nullable_to_non_nullable
              : currentSearchType as SearchType,
      isLoading:
          isLoading == const $CopyWithPlaceholder()
              ? _value.isLoading
              // ignore: cast_nullable_to_non_nullable
              : isLoading as bool,
      error:
          error == const $CopyWithPlaceholder()
              ? _value.error
              // ignore: cast_nullable_to_non_nullable
              : error as String?,
      searchQuery:
          searchQuery == const $CopyWithPlaceholder()
              ? _value.searchQuery
              // ignore: cast_nullable_to_non_nullable
              : searchQuery as String,
      showClearButton:
          showClearButton == const $CopyWithPlaceholder()
              ? _value.showClearButton
              // ignore: cast_nullable_to_non_nullable
              : showClearButton as bool,
      wordDefineResult:
          wordDefineResult == const $CopyWithPlaceholder()
              ? _value.wordDefineResult
              // ignore: cast_nullable_to_non_nullable
              : wordDefineResult as DictWordDefinitionsRM?,
      verseResults:
          verseResults == const $CopyWithPlaceholder()
              ? _value.verseResults
              // ignore: cast_nullable_to_non_nullable
              : verseResults as List<VerseRM>,
      bookResults:
          bookResults == const $CopyWithPlaceholder()
              ? _value.bookResults
              // ignore: cast_nullable_to_non_nullable
              : bookResults as List<BookChunkRM>,
      searchCounter:
          searchCounter == const $CopyWithPlaceholder()
              ? _value.searchCounter
              // ignore: cast_nullable_to_non_nullable
              : searchCounter as int,
      typeChangeCounter:
          typeChangeCounter == const $CopyWithPlaceholder()
              ? _value.typeChangeCounter
              // ignore: cast_nullable_to_non_nullable
              : typeChangeCounter as int,
    );
  }
}

extension $QuickSearchStateCopyWith on QuickSearchState {
  /// Returns a callable class that can be used as follows: `instanceOfQuickSearchState.copyWith(...)` or like so:`instanceOfQuickSearchState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$QuickSearchStateCWProxy get copyWith => _$QuickSearchStateCWProxyImpl(this);
}
