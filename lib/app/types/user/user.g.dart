// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserRM _$UserRMFromJson(Map<String, dynamic> json) => UserRM(
  name: json['name'] as String?,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  email: json['email'] as String?,
  picture: json['picture'] as String?,
);

Map<String, dynamic> _$UserRMToJson(UserRM instance) => <String, dynamic>{
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'name': instance.name,
  'email': instance.email,
  'picture': instance.picture,
};
