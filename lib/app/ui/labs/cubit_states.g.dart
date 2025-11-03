// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit_states.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LabsCubitStateCWProxy {
  LabsCubitState isLoading(bool? isLoading);

  LabsCubitState isInitialized(bool? isInitialized);

  LabsCubitState isEmpty(bool? isEmpty);

  LabsCubitState message(String? message);

  LabsCubitState pageState(int pageState);

  LabsCubitState idToken(String? idToken);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LabsCubitState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LabsCubitState(...).copyWith(id: 12, name: "My name")
  /// ````
  LabsCubitState call({
    bool? isLoading,
    bool? isInitialized,
    bool? isEmpty,
    String? message,
    int pageState,
    String? idToken,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLabsCubitState.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLabsCubitState.copyWith.fieldName(...)`
class _$LabsCubitStateCWProxyImpl implements _$LabsCubitStateCWProxy {
  const _$LabsCubitStateCWProxyImpl(this._value);

  final LabsCubitState _value;

  @override
  LabsCubitState isLoading(bool? isLoading) => this(isLoading: isLoading);

  @override
  LabsCubitState isInitialized(bool? isInitialized) =>
      this(isInitialized: isInitialized);

  @override
  LabsCubitState isEmpty(bool? isEmpty) => this(isEmpty: isEmpty);

  @override
  LabsCubitState message(String? message) => this(message: message);

  @override
  LabsCubitState pageState(int pageState) => this(pageState: pageState);

  @override
  LabsCubitState idToken(String? idToken) => this(idToken: idToken);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LabsCubitState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LabsCubitState(...).copyWith(id: 12, name: "My name")
  /// ````
  LabsCubitState call({
    Object? isLoading = const $CopyWithPlaceholder(),
    Object? isInitialized = const $CopyWithPlaceholder(),
    Object? isEmpty = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? pageState = const $CopyWithPlaceholder(),
    Object? idToken = const $CopyWithPlaceholder(),
  }) {
    return LabsCubitState(
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
      pageState:
          pageState == const $CopyWithPlaceholder()
              ? _value.pageState
              // ignore: cast_nullable_to_non_nullable
              : pageState as int,
      idToken:
          idToken == const $CopyWithPlaceholder()
              ? _value.idToken
              // ignore: cast_nullable_to_non_nullable
              : idToken as String?,
    );
  }
}

extension $LabsCubitStateCopyWith on LabsCubitState {
  /// Returns a callable class that can be used as follows: `instanceOfLabsCubitState.copyWith(...)` or like so:`instanceOfLabsCubitState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LabsCubitStateCWProxy get copyWith => _$LabsCubitStateCWProxyImpl(this);
}
