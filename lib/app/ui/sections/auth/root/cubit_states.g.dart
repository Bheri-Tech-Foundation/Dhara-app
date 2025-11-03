// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit_states.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AuthRootCubitStateCWProxy {
  AuthRootCubitState isLoading(bool? isLoading);

  AuthRootCubitState isInitialized(bool? isInitialized);

  AuthRootCubitState result(AuthRootArgsResult? result);

  AuthRootCubitState retryCounter(int? retryCounter);

  AuthRootCubitState toastCounter(int? toastCounter);

  AuthRootCubitState isEmpty(bool? isEmpty);

  AuthRootCubitState message(String? message);

  AuthRootCubitState state(int state);

  AuthRootCubitState purpose(int purpose);

  AuthRootCubitState isAuthorized(bool isAuthorized);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AuthRootCubitState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AuthRootCubitState(...).copyWith(id: 12, name: "My name")
  /// ````
  AuthRootCubitState call({
    bool? isLoading,
    bool? isInitialized,
    AuthRootArgsResult? result,
    int? retryCounter,
    int? toastCounter,
    bool? isEmpty,
    String? message,
    int state,
    int purpose,
    bool isAuthorized,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAuthRootCubitState.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAuthRootCubitState.copyWith.fieldName(...)`
class _$AuthRootCubitStateCWProxyImpl implements _$AuthRootCubitStateCWProxy {
  const _$AuthRootCubitStateCWProxyImpl(this._value);

  final AuthRootCubitState _value;

  @override
  AuthRootCubitState isLoading(bool? isLoading) => this(isLoading: isLoading);

  @override
  AuthRootCubitState isInitialized(bool? isInitialized) =>
      this(isInitialized: isInitialized);

  @override
  AuthRootCubitState result(AuthRootArgsResult? result) => this(result: result);

  @override
  AuthRootCubitState retryCounter(int? retryCounter) =>
      this(retryCounter: retryCounter);

  @override
  AuthRootCubitState toastCounter(int? toastCounter) =>
      this(toastCounter: toastCounter);

  @override
  AuthRootCubitState isEmpty(bool? isEmpty) => this(isEmpty: isEmpty);

  @override
  AuthRootCubitState message(String? message) => this(message: message);

  @override
  AuthRootCubitState state(int state) => this(state: state);

  @override
  AuthRootCubitState purpose(int purpose) => this(purpose: purpose);

  @override
  AuthRootCubitState isAuthorized(bool isAuthorized) =>
      this(isAuthorized: isAuthorized);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AuthRootCubitState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AuthRootCubitState(...).copyWith(id: 12, name: "My name")
  /// ````
  AuthRootCubitState call({
    Object? isLoading = const $CopyWithPlaceholder(),
    Object? isInitialized = const $CopyWithPlaceholder(),
    Object? result = const $CopyWithPlaceholder(),
    Object? retryCounter = const $CopyWithPlaceholder(),
    Object? toastCounter = const $CopyWithPlaceholder(),
    Object? isEmpty = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? purpose = const $CopyWithPlaceholder(),
    Object? isAuthorized = const $CopyWithPlaceholder(),
  }) {
    return AuthRootCubitState(
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
              : result as AuthRootArgsResult?,
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
      state:
          state == const $CopyWithPlaceholder()
              ? _value.state
              // ignore: cast_nullable_to_non_nullable
              : state as int,
      purpose:
          purpose == const $CopyWithPlaceholder()
              ? _value.purpose
              // ignore: cast_nullable_to_non_nullable
              : purpose as int,
      isAuthorized:
          isAuthorized == const $CopyWithPlaceholder()
              ? _value.isAuthorized
              // ignore: cast_nullable_to_non_nullable
              : isAuthorized as bool,
    );
  }
}

extension $AuthRootCubitStateCopyWith on AuthRootCubitState {
  /// Returns a callable class that can be used as follows: `instanceOfAuthRootCubitState.copyWith(...)` or like so:`instanceOfAuthRootCubitState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AuthRootCubitStateCWProxy get copyWith =>
      _$AuthRootCubitStateCWProxyImpl(this);
}
