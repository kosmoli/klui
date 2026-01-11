// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProviderConfig {

 String get id; String get name;@JsonKey(name: 'provider_type') String get providerType;@JsonKey(name: 'provider_category') String get providerCategory;@JsonKey(name: 'base_url') String? get baseUrl;@JsonKey(name: 'api_key') String? get apiKey;@JsonKey(name: 'access_key') String? get accessKey; String? get region;@JsonKey(name: 'updated_at') DateTime? get updatedAt;@JsonKey(name: 'organization_id') String? get organizationId;@JsonKey(name: 'api_key_enc') String? get apiKeyEnc;@JsonKey(name: 'access_key_enc') String? get accessKeyEnc;
/// Create a copy of ProviderConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderConfigCopyWith<ProviderConfig> get copyWith => _$ProviderConfigCopyWithImpl<ProviderConfig>(this as ProviderConfig, _$identity);

  /// Serializes this ProviderConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.providerType, providerType) || other.providerType == providerType)&&(identical(other.providerCategory, providerCategory) || other.providerCategory == providerCategory)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.apiKey, apiKey) || other.apiKey == apiKey)&&(identical(other.accessKey, accessKey) || other.accessKey == accessKey)&&(identical(other.region, region) || other.region == region)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.apiKeyEnc, apiKeyEnc) || other.apiKeyEnc == apiKeyEnc)&&(identical(other.accessKeyEnc, accessKeyEnc) || other.accessKeyEnc == accessKeyEnc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,providerType,providerCategory,baseUrl,apiKey,accessKey,region,updatedAt,organizationId,apiKeyEnc,accessKeyEnc);

@override
String toString() {
  return 'ProviderConfig(id: $id, name: $name, providerType: $providerType, providerCategory: $providerCategory, baseUrl: $baseUrl, apiKey: $apiKey, accessKey: $accessKey, region: $region, updatedAt: $updatedAt, organizationId: $organizationId, apiKeyEnc: $apiKeyEnc, accessKeyEnc: $accessKeyEnc)';
}


}

/// @nodoc
abstract mixin class $ProviderConfigCopyWith<$Res>  {
  factory $ProviderConfigCopyWith(ProviderConfig value, $Res Function(ProviderConfig) _then) = _$ProviderConfigCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(name: 'provider_type') String providerType,@JsonKey(name: 'provider_category') String providerCategory,@JsonKey(name: 'base_url') String? baseUrl,@JsonKey(name: 'api_key') String? apiKey,@JsonKey(name: 'access_key') String? accessKey, String? region,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'organization_id') String? organizationId,@JsonKey(name: 'api_key_enc') String? apiKeyEnc,@JsonKey(name: 'access_key_enc') String? accessKeyEnc
});




}
/// @nodoc
class _$ProviderConfigCopyWithImpl<$Res>
    implements $ProviderConfigCopyWith<$Res> {
  _$ProviderConfigCopyWithImpl(this._self, this._then);

  final ProviderConfig _self;
  final $Res Function(ProviderConfig) _then;

/// Create a copy of ProviderConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? providerType = null,Object? providerCategory = null,Object? baseUrl = freezed,Object? apiKey = freezed,Object? accessKey = freezed,Object? region = freezed,Object? updatedAt = freezed,Object? organizationId = freezed,Object? apiKeyEnc = freezed,Object? accessKeyEnc = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,providerType: null == providerType ? _self.providerType : providerType // ignore: cast_nullable_to_non_nullable
as String,providerCategory: null == providerCategory ? _self.providerCategory : providerCategory // ignore: cast_nullable_to_non_nullable
as String,baseUrl: freezed == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String?,apiKey: freezed == apiKey ? _self.apiKey : apiKey // ignore: cast_nullable_to_non_nullable
as String?,accessKey: freezed == accessKey ? _self.accessKey : accessKey // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,organizationId: freezed == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String?,apiKeyEnc: freezed == apiKeyEnc ? _self.apiKeyEnc : apiKeyEnc // ignore: cast_nullable_to_non_nullable
as String?,accessKeyEnc: freezed == accessKeyEnc ? _self.accessKeyEnc : accessKeyEnc // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderConfig].
extension ProviderConfigPatterns on ProviderConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderConfig value)  $default,){
final _that = this;
switch (_that) {
case _ProviderConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'provider_type')  String providerType, @JsonKey(name: 'provider_category')  String providerCategory, @JsonKey(name: 'base_url')  String? baseUrl, @JsonKey(name: 'api_key')  String? apiKey, @JsonKey(name: 'access_key')  String? accessKey,  String? region, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'organization_id')  String? organizationId, @JsonKey(name: 'api_key_enc')  String? apiKeyEnc, @JsonKey(name: 'access_key_enc')  String? accessKeyEnc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderConfig() when $default != null:
return $default(_that.id,_that.name,_that.providerType,_that.providerCategory,_that.baseUrl,_that.apiKey,_that.accessKey,_that.region,_that.updatedAt,_that.organizationId,_that.apiKeyEnc,_that.accessKeyEnc);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(name: 'provider_type')  String providerType, @JsonKey(name: 'provider_category')  String providerCategory, @JsonKey(name: 'base_url')  String? baseUrl, @JsonKey(name: 'api_key')  String? apiKey, @JsonKey(name: 'access_key')  String? accessKey,  String? region, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'organization_id')  String? organizationId, @JsonKey(name: 'api_key_enc')  String? apiKeyEnc, @JsonKey(name: 'access_key_enc')  String? accessKeyEnc)  $default,) {final _that = this;
switch (_that) {
case _ProviderConfig():
return $default(_that.id,_that.name,_that.providerType,_that.providerCategory,_that.baseUrl,_that.apiKey,_that.accessKey,_that.region,_that.updatedAt,_that.organizationId,_that.apiKeyEnc,_that.accessKeyEnc);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(name: 'provider_type')  String providerType, @JsonKey(name: 'provider_category')  String providerCategory, @JsonKey(name: 'base_url')  String? baseUrl, @JsonKey(name: 'api_key')  String? apiKey, @JsonKey(name: 'access_key')  String? accessKey,  String? region, @JsonKey(name: 'updated_at')  DateTime? updatedAt, @JsonKey(name: 'organization_id')  String? organizationId, @JsonKey(name: 'api_key_enc')  String? apiKeyEnc, @JsonKey(name: 'access_key_enc')  String? accessKeyEnc)?  $default,) {final _that = this;
switch (_that) {
case _ProviderConfig() when $default != null:
return $default(_that.id,_that.name,_that.providerType,_that.providerCategory,_that.baseUrl,_that.apiKey,_that.accessKey,_that.region,_that.updatedAt,_that.organizationId,_that.apiKeyEnc,_that.accessKeyEnc);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProviderConfig extends ProviderConfig {
  const _ProviderConfig({required this.id, required this.name, @JsonKey(name: 'provider_type') required this.providerType, @JsonKey(name: 'provider_category') required this.providerCategory, @JsonKey(name: 'base_url') this.baseUrl, @JsonKey(name: 'api_key') this.apiKey, @JsonKey(name: 'access_key') this.accessKey, this.region, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(name: 'organization_id') this.organizationId, @JsonKey(name: 'api_key_enc') this.apiKeyEnc, @JsonKey(name: 'access_key_enc') this.accessKeyEnc}): super._();
  factory _ProviderConfig.fromJson(Map<String, dynamic> json) => _$ProviderConfigFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(name: 'provider_type') final  String providerType;
@override@JsonKey(name: 'provider_category') final  String providerCategory;
@override@JsonKey(name: 'base_url') final  String? baseUrl;
@override@JsonKey(name: 'api_key') final  String? apiKey;
@override@JsonKey(name: 'access_key') final  String? accessKey;
@override final  String? region;
@override@JsonKey(name: 'updated_at') final  DateTime? updatedAt;
@override@JsonKey(name: 'organization_id') final  String? organizationId;
@override@JsonKey(name: 'api_key_enc') final  String? apiKeyEnc;
@override@JsonKey(name: 'access_key_enc') final  String? accessKeyEnc;

/// Create a copy of ProviderConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderConfigCopyWith<_ProviderConfig> get copyWith => __$ProviderConfigCopyWithImpl<_ProviderConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProviderConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.providerType, providerType) || other.providerType == providerType)&&(identical(other.providerCategory, providerCategory) || other.providerCategory == providerCategory)&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.apiKey, apiKey) || other.apiKey == apiKey)&&(identical(other.accessKey, accessKey) || other.accessKey == accessKey)&&(identical(other.region, region) || other.region == region)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.apiKeyEnc, apiKeyEnc) || other.apiKeyEnc == apiKeyEnc)&&(identical(other.accessKeyEnc, accessKeyEnc) || other.accessKeyEnc == accessKeyEnc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,providerType,providerCategory,baseUrl,apiKey,accessKey,region,updatedAt,organizationId,apiKeyEnc,accessKeyEnc);

@override
String toString() {
  return 'ProviderConfig(id: $id, name: $name, providerType: $providerType, providerCategory: $providerCategory, baseUrl: $baseUrl, apiKey: $apiKey, accessKey: $accessKey, region: $region, updatedAt: $updatedAt, organizationId: $organizationId, apiKeyEnc: $apiKeyEnc, accessKeyEnc: $accessKeyEnc)';
}


}

/// @nodoc
abstract mixin class _$ProviderConfigCopyWith<$Res> implements $ProviderConfigCopyWith<$Res> {
  factory _$ProviderConfigCopyWith(_ProviderConfig value, $Res Function(_ProviderConfig) _then) = __$ProviderConfigCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(name: 'provider_type') String providerType,@JsonKey(name: 'provider_category') String providerCategory,@JsonKey(name: 'base_url') String? baseUrl,@JsonKey(name: 'api_key') String? apiKey,@JsonKey(name: 'access_key') String? accessKey, String? region,@JsonKey(name: 'updated_at') DateTime? updatedAt,@JsonKey(name: 'organization_id') String? organizationId,@JsonKey(name: 'api_key_enc') String? apiKeyEnc,@JsonKey(name: 'access_key_enc') String? accessKeyEnc
});




}
/// @nodoc
class __$ProviderConfigCopyWithImpl<$Res>
    implements _$ProviderConfigCopyWith<$Res> {
  __$ProviderConfigCopyWithImpl(this._self, this._then);

  final _ProviderConfig _self;
  final $Res Function(_ProviderConfig) _then;

/// Create a copy of ProviderConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? providerType = null,Object? providerCategory = null,Object? baseUrl = freezed,Object? apiKey = freezed,Object? accessKey = freezed,Object? region = freezed,Object? updatedAt = freezed,Object? organizationId = freezed,Object? apiKeyEnc = freezed,Object? accessKeyEnc = freezed,}) {
  return _then(_ProviderConfig(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,providerType: null == providerType ? _self.providerType : providerType // ignore: cast_nullable_to_non_nullable
as String,providerCategory: null == providerCategory ? _self.providerCategory : providerCategory // ignore: cast_nullable_to_non_nullable
as String,baseUrl: freezed == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String?,apiKey: freezed == apiKey ? _self.apiKey : apiKey // ignore: cast_nullable_to_non_nullable
as String?,accessKey: freezed == accessKey ? _self.accessKey : accessKey // ignore: cast_nullable_to_non_nullable
as String?,region: freezed == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,organizationId: freezed == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String?,apiKeyEnc: freezed == apiKeyEnc ? _self.apiKeyEnc : apiKeyEnc // ignore: cast_nullable_to_non_nullable
as String?,accessKeyEnc: freezed == accessKeyEnc ? _self.accessKeyEnc : accessKeyEnc // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
