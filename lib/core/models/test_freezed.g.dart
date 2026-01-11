// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_freezed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TestUser _$TestUserFromJson(Map<String, dynamic> json) => _TestUser(
  id: json['id'] as String,
  name: json['name'] as String,
  age: (json['age'] as num).toInt(),
  email: json['email'] as String?,
  isActive: json['isActive'] as bool? ?? false,
);

Map<String, dynamic> _$TestUserToJson(_TestUser instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'age': instance.age,
  'email': instance.email,
  'isActive': instance.isActive,
};
