// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cubit_states.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GoogleLoginCubitStateCWProxy {
  GoogleLoginCubitState purpose(String? purpose);

  GoogleLoginCubitState isInitialized(bool isInitialized);

  GoogleLoginCubitState state(int state);

  GoogleLoginCubitState isLoading(bool isLoading);

  GoogleLoginCubitState isInProgress(bool? isInProgress);

  GoogleLoginCubitState idToken(String? idToken);

  GoogleLoginCubitState result(GoogleLoginArgsResult? result);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GoogleLoginCubitState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GoogleLoginCubitState(...).copyWith(id: 12, name: "My name")
  /// ````
  GoogleLoginCubitState call({
    String? purpose,
    bool isInitialized,
    int state,
    bool isLoading,
    bool? isInProgress,
    String? idToken,
    GoogleLoginArgsResult? result,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfGoogleLoginCubitState.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfGoogleLoginCubitState.copyWith.fieldName(...)`
class _$GoogleLoginCubitStateCWProxyImpl
    implements _$GoogleLoginCubitStateCWProxy {
  const _$GoogleLoginCubitStateCWProxyImpl(this._value);

  final GoogleLoginCubitState _value;

  @override
  GoogleLoginCubitState purpose(String? purpose) => this(purpose: purpose);

  @override
  GoogleLoginCubitState isInitialized(bool isInitialized) =>
      this(isInitialized: isInitialized);

  @override
  GoogleLoginCubitState state(int state) => this(state: state);

  @override
  GoogleLoginCubitState isLoading(bool isLoading) => this(isLoading: isLoading);

  @override
  GoogleLoginCubitState isInProgress(bool? isInProgress) =>
      this(isInProgress: isInProgress);

  @override
  GoogleLoginCubitState idToken(String? idToken) => this(idToken: idToken);

  @override
  GoogleLoginCubitState result(GoogleLoginArgsResult? result) =>
      this(result: result);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `GoogleLoginCubitState(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// GoogleLoginCubitState(...).copyWith(id: 12, name: "My name")
  /// ````
  GoogleLoginCubitState call({
    Object? purpose = const $CopyWithPlaceholder(),
    Object? isInitialized = const $CopyWithPlaceholder(),
    Object? state = const $CopyWithPlaceholder(),
    Object? isLoading = const $CopyWithPlaceholder(),
    Object? isInProgress = const $CopyWithPlaceholder(),
    Object? idToken = const $CopyWithPlaceholder(),
    Object? result = const $CopyWithPlaceholder(),
  }) {
    return GoogleLoginCubitState(
      purpose:
          purpose == const $CopyWithPlaceholder()
              ? _value.purpose
              // ignore: cast_nullable_to_non_nullable
              : purpose as String?,
      isInitialized:
          isInitialized == const $CopyWithPlaceholder()
              ? _value.isInitialized
              // ignore: cast_nullable_to_non_nullable
              : isInitialized as bool,
      state:
          state == const $CopyWithPlaceholder()
              ? _value.state
              // ignore: cast_nullable_to_non_nullable
              : state as int,
      isLoading:
          isLoading == const $CopyWithPlaceholder()
              ? _value.isLoading
              // ignore: cast_nullable_to_non_nullable
              : isLoading as bool,
      isInProgress:
          isInProgress == const $CopyWithPlaceholder()
              ? _value.isInProgress
              // ignore: cast_nullable_to_non_nullable
              : isInProgress as bool?,
      idToken:
          idToken == const $CopyWithPlaceholder()
              ? _value.idToken
              // ignore: cast_nullable_to_non_nullable
              : idToken as String?,
      result:
          result == const $CopyWithPlaceholder()
              ? _value.result
              // ignore: cast_nullable_to_non_nullable
              : result as GoogleLoginArgsResult?,
    );
  }
}

extension $GoogleLoginCubitStateCopyWith on GoogleLoginCubitState {
  /// Returns a callable class that can be used as follows: `instanceOfGoogleLoginCubitState.copyWith(...)` or like so:`instanceOfGoogleLoginCubitState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GoogleLoginCubitStateCWProxy get copyWith =>
      _$GoogleLoginCubitStateCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleLoginCubitState _$GoogleLoginCubitStateFromJson(
  Map<String, dynamic> json,
) => GoogleLoginCubitState(
  purpose: json['purpose'] as String?,
  isInitialized: json['isInitialized'] as bool? ?? false,
  state: (json['state'] as num?)?.toInt() ?? GoogleLoginModal.STATE_DEFAULT,
  isLoading: json['isLoading'] as bool? ?? false,
  isInProgress: json['isInProgress'] as bool?,
  idToken: json['idToken'] as String?,
  result:
      json['result'] == null
          ? null
          : GoogleLoginArgsResult.fromJson(
            json['result'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$GoogleLoginCubitStateToJson(
  GoogleLoginCubitState instance,
) => <String, dynamic>{
  'purpose': instance.purpose,
  'isInitialized': instance.isInitialized,
  'state': instance.state,
  'isLoading': instance.isLoading,
  'isInProgress': instance.isInProgress,
  'idToken': instance.idToken,
  'result': instance.result,
};
