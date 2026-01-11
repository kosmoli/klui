// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'test_freezed.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TestUser {

 String get id; String get name; int get age; String? get email; bool get isActive;
/// Create a copy of TestUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TestUserCopyWith<TestUser> get copyWith => _$TestUserCopyWithImpl<TestUser>(this as TestUser, _$identity);

  /// Serializes this TestUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TestUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.age, age) || other.age == age)&&(identical(other.email, email) || other.email == email)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,age,email,isActive);

@override
String toString() {
  return 'TestUser(id: $id, name: $name, age: $age, email: $email, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $TestUserCopyWith<$Res>  {
  factory $TestUserCopyWith(TestUser value, $Res Function(TestUser) _then) = _$TestUserCopyWithImpl;
@useResult
$Res call({
 String id, String name, int age, String? email, bool isActive
});




}
/// @nodoc
class _$TestUserCopyWithImpl<$Res>
    implements $TestUserCopyWith<$Res> {
  _$TestUserCopyWithImpl(this._self, this._then);

  final TestUser _self;
  final $Res Function(TestUser) _then;

/// Create a copy of TestUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? age = null,Object? email = freezed,Object? isActive = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [TestUser].
extension TestUserPatterns on TestUser {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TestUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TestUser() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TestUser value)  $default,){
final _that = this;
switch (_that) {
case _TestUser():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TestUser value)?  $default,){
final _that = this;
switch (_that) {
case _TestUser() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int age,  String? email,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TestUser() when $default != null:
return $default(_that.id,_that.name,_that.age,_that.email,_that.isActive);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int age,  String? email,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _TestUser():
return $default(_that.id,_that.name,_that.age,_that.email,_that.isActive);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int age,  String? email,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _TestUser() when $default != null:
return $default(_that.id,_that.name,_that.age,_that.email,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TestUser implements TestUser {
  const _TestUser({required this.id, required this.name, required this.age, this.email, this.isActive = false});
  factory _TestUser.fromJson(Map<String, dynamic> json) => _$TestUserFromJson(json);

@override final  String id;
@override final  String name;
@override final  int age;
@override final  String? email;
@override@JsonKey() final  bool isActive;

/// Create a copy of TestUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TestUserCopyWith<_TestUser> get copyWith => __$TestUserCopyWithImpl<_TestUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TestUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TestUser&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.age, age) || other.age == age)&&(identical(other.email, email) || other.email == email)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,age,email,isActive);

@override
String toString() {
  return 'TestUser(id: $id, name: $name, age: $age, email: $email, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$TestUserCopyWith<$Res> implements $TestUserCopyWith<$Res> {
  factory _$TestUserCopyWith(_TestUser value, $Res Function(_TestUser) _then) = __$TestUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int age, String? email, bool isActive
});




}
/// @nodoc
class __$TestUserCopyWithImpl<$Res>
    implements _$TestUserCopyWith<$Res> {
  __$TestUserCopyWithImpl(this._self, this._then);

  final _TestUser _self;
  final $Res Function(_TestUser) _then;

/// Create a copy of TestUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? age = null,Object? email = freezed,Object? isActive = null,}) {
  return _then(_TestUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
