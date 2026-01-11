// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'embedding_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EmbeddingModel {

 String get handle; String get name;@JsonKey(name: 'display_name') String get displayName;@JsonKey(name: 'provider_type') String get providerType;@JsonKey(name: 'provider_name') String get providerName;@JsonKey(name: 'embedding_model') String get embeddingModel;@JsonKey(name: 'embedding_endpoint_type') String get embeddingEndpointType;@JsonKey(name: 'embedding_endpoint') String get embeddingEndpoint;@JsonKey(name: 'embedding_dim') int get embeddingDim;@JsonKey(name: 'embedding_chunk_size') int get embeddingChunkSize;@JsonKey(name: 'batch_size') int get batchSize;
/// Create a copy of EmbeddingModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmbeddingModelCopyWith<EmbeddingModel> get copyWith => _$EmbeddingModelCopyWithImpl<EmbeddingModel>(this as EmbeddingModel, _$identity);

  /// Serializes this EmbeddingModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmbeddingModel&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.providerType, providerType) || other.providerType == providerType)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&(identical(other.embeddingModel, embeddingModel) || other.embeddingModel == embeddingModel)&&(identical(other.embeddingEndpointType, embeddingEndpointType) || other.embeddingEndpointType == embeddingEndpointType)&&(identical(other.embeddingEndpoint, embeddingEndpoint) || other.embeddingEndpoint == embeddingEndpoint)&&(identical(other.embeddingDim, embeddingDim) || other.embeddingDim == embeddingDim)&&(identical(other.embeddingChunkSize, embeddingChunkSize) || other.embeddingChunkSize == embeddingChunkSize)&&(identical(other.batchSize, batchSize) || other.batchSize == batchSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,handle,name,displayName,providerType,providerName,embeddingModel,embeddingEndpointType,embeddingEndpoint,embeddingDim,embeddingChunkSize,batchSize);

@override
String toString() {
  return 'EmbeddingModel(handle: $handle, name: $name, displayName: $displayName, providerType: $providerType, providerName: $providerName, embeddingModel: $embeddingModel, embeddingEndpointType: $embeddingEndpointType, embeddingEndpoint: $embeddingEndpoint, embeddingDim: $embeddingDim, embeddingChunkSize: $embeddingChunkSize, batchSize: $batchSize)';
}


}

/// @nodoc
abstract mixin class $EmbeddingModelCopyWith<$Res>  {
  factory $EmbeddingModelCopyWith(EmbeddingModel value, $Res Function(EmbeddingModel) _then) = _$EmbeddingModelCopyWithImpl;
@useResult
$Res call({
 String handle, String name,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'provider_type') String providerType,@JsonKey(name: 'provider_name') String providerName,@JsonKey(name: 'embedding_model') String embeddingModel,@JsonKey(name: 'embedding_endpoint_type') String embeddingEndpointType,@JsonKey(name: 'embedding_endpoint') String embeddingEndpoint,@JsonKey(name: 'embedding_dim') int embeddingDim,@JsonKey(name: 'embedding_chunk_size') int embeddingChunkSize,@JsonKey(name: 'batch_size') int batchSize
});




}
/// @nodoc
class _$EmbeddingModelCopyWithImpl<$Res>
    implements $EmbeddingModelCopyWith<$Res> {
  _$EmbeddingModelCopyWithImpl(this._self, this._then);

  final EmbeddingModel _self;
  final $Res Function(EmbeddingModel) _then;

/// Create a copy of EmbeddingModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? handle = null,Object? name = null,Object? displayName = null,Object? providerType = null,Object? providerName = null,Object? embeddingModel = null,Object? embeddingEndpointType = null,Object? embeddingEndpoint = null,Object? embeddingDim = null,Object? embeddingChunkSize = null,Object? batchSize = null,}) {
  return _then(_self.copyWith(
handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,providerType: null == providerType ? _self.providerType : providerType // ignore: cast_nullable_to_non_nullable
as String,providerName: null == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String,embeddingModel: null == embeddingModel ? _self.embeddingModel : embeddingModel // ignore: cast_nullable_to_non_nullable
as String,embeddingEndpointType: null == embeddingEndpointType ? _self.embeddingEndpointType : embeddingEndpointType // ignore: cast_nullable_to_non_nullable
as String,embeddingEndpoint: null == embeddingEndpoint ? _self.embeddingEndpoint : embeddingEndpoint // ignore: cast_nullable_to_non_nullable
as String,embeddingDim: null == embeddingDim ? _self.embeddingDim : embeddingDim // ignore: cast_nullable_to_non_nullable
as int,embeddingChunkSize: null == embeddingChunkSize ? _self.embeddingChunkSize : embeddingChunkSize // ignore: cast_nullable_to_non_nullable
as int,batchSize: null == batchSize ? _self.batchSize : batchSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [EmbeddingModel].
extension EmbeddingModelPatterns on EmbeddingModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmbeddingModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmbeddingModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmbeddingModel value)  $default,){
final _that = this;
switch (_that) {
case _EmbeddingModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmbeddingModel value)?  $default,){
final _that = this;
switch (_that) {
case _EmbeddingModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String handle,  String name, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'provider_type')  String providerType, @JsonKey(name: 'provider_name')  String providerName, @JsonKey(name: 'embedding_model')  String embeddingModel, @JsonKey(name: 'embedding_endpoint_type')  String embeddingEndpointType, @JsonKey(name: 'embedding_endpoint')  String embeddingEndpoint, @JsonKey(name: 'embedding_dim')  int embeddingDim, @JsonKey(name: 'embedding_chunk_size')  int embeddingChunkSize, @JsonKey(name: 'batch_size')  int batchSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmbeddingModel() when $default != null:
return $default(_that.handle,_that.name,_that.displayName,_that.providerType,_that.providerName,_that.embeddingModel,_that.embeddingEndpointType,_that.embeddingEndpoint,_that.embeddingDim,_that.embeddingChunkSize,_that.batchSize);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String handle,  String name, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'provider_type')  String providerType, @JsonKey(name: 'provider_name')  String providerName, @JsonKey(name: 'embedding_model')  String embeddingModel, @JsonKey(name: 'embedding_endpoint_type')  String embeddingEndpointType, @JsonKey(name: 'embedding_endpoint')  String embeddingEndpoint, @JsonKey(name: 'embedding_dim')  int embeddingDim, @JsonKey(name: 'embedding_chunk_size')  int embeddingChunkSize, @JsonKey(name: 'batch_size')  int batchSize)  $default,) {final _that = this;
switch (_that) {
case _EmbeddingModel():
return $default(_that.handle,_that.name,_that.displayName,_that.providerType,_that.providerName,_that.embeddingModel,_that.embeddingEndpointType,_that.embeddingEndpoint,_that.embeddingDim,_that.embeddingChunkSize,_that.batchSize);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String handle,  String name, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'provider_type')  String providerType, @JsonKey(name: 'provider_name')  String providerName, @JsonKey(name: 'embedding_model')  String embeddingModel, @JsonKey(name: 'embedding_endpoint_type')  String embeddingEndpointType, @JsonKey(name: 'embedding_endpoint')  String embeddingEndpoint, @JsonKey(name: 'embedding_dim')  int embeddingDim, @JsonKey(name: 'embedding_chunk_size')  int embeddingChunkSize, @JsonKey(name: 'batch_size')  int batchSize)?  $default,) {final _that = this;
switch (_that) {
case _EmbeddingModel() when $default != null:
return $default(_that.handle,_that.name,_that.displayName,_that.providerType,_that.providerName,_that.embeddingModel,_that.embeddingEndpointType,_that.embeddingEndpoint,_that.embeddingDim,_that.embeddingChunkSize,_that.batchSize);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EmbeddingModel extends EmbeddingModel {
  const _EmbeddingModel({required this.handle, required this.name, @JsonKey(name: 'display_name') required this.displayName, @JsonKey(name: 'provider_type') required this.providerType, @JsonKey(name: 'provider_name') required this.providerName, @JsonKey(name: 'embedding_model') required this.embeddingModel, @JsonKey(name: 'embedding_endpoint_type') required this.embeddingEndpointType, @JsonKey(name: 'embedding_endpoint') required this.embeddingEndpoint, @JsonKey(name: 'embedding_dim') required this.embeddingDim, @JsonKey(name: 'embedding_chunk_size') required this.embeddingChunkSize, @JsonKey(name: 'batch_size') required this.batchSize}): super._();
  factory _EmbeddingModel.fromJson(Map<String, dynamic> json) => _$EmbeddingModelFromJson(json);

@override final  String handle;
@override final  String name;
@override@JsonKey(name: 'display_name') final  String displayName;
@override@JsonKey(name: 'provider_type') final  String providerType;
@override@JsonKey(name: 'provider_name') final  String providerName;
@override@JsonKey(name: 'embedding_model') final  String embeddingModel;
@override@JsonKey(name: 'embedding_endpoint_type') final  String embeddingEndpointType;
@override@JsonKey(name: 'embedding_endpoint') final  String embeddingEndpoint;
@override@JsonKey(name: 'embedding_dim') final  int embeddingDim;
@override@JsonKey(name: 'embedding_chunk_size') final  int embeddingChunkSize;
@override@JsonKey(name: 'batch_size') final  int batchSize;

/// Create a copy of EmbeddingModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmbeddingModelCopyWith<_EmbeddingModel> get copyWith => __$EmbeddingModelCopyWithImpl<_EmbeddingModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EmbeddingModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmbeddingModel&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.providerType, providerType) || other.providerType == providerType)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&(identical(other.embeddingModel, embeddingModel) || other.embeddingModel == embeddingModel)&&(identical(other.embeddingEndpointType, embeddingEndpointType) || other.embeddingEndpointType == embeddingEndpointType)&&(identical(other.embeddingEndpoint, embeddingEndpoint) || other.embeddingEndpoint == embeddingEndpoint)&&(identical(other.embeddingDim, embeddingDim) || other.embeddingDim == embeddingDim)&&(identical(other.embeddingChunkSize, embeddingChunkSize) || other.embeddingChunkSize == embeddingChunkSize)&&(identical(other.batchSize, batchSize) || other.batchSize == batchSize));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,handle,name,displayName,providerType,providerName,embeddingModel,embeddingEndpointType,embeddingEndpoint,embeddingDim,embeddingChunkSize,batchSize);

@override
String toString() {
  return 'EmbeddingModel(handle: $handle, name: $name, displayName: $displayName, providerType: $providerType, providerName: $providerName, embeddingModel: $embeddingModel, embeddingEndpointType: $embeddingEndpointType, embeddingEndpoint: $embeddingEndpoint, embeddingDim: $embeddingDim, embeddingChunkSize: $embeddingChunkSize, batchSize: $batchSize)';
}


}

/// @nodoc
abstract mixin class _$EmbeddingModelCopyWith<$Res> implements $EmbeddingModelCopyWith<$Res> {
  factory _$EmbeddingModelCopyWith(_EmbeddingModel value, $Res Function(_EmbeddingModel) _then) = __$EmbeddingModelCopyWithImpl;
@override @useResult
$Res call({
 String handle, String name,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'provider_type') String providerType,@JsonKey(name: 'provider_name') String providerName,@JsonKey(name: 'embedding_model') String embeddingModel,@JsonKey(name: 'embedding_endpoint_type') String embeddingEndpointType,@JsonKey(name: 'embedding_endpoint') String embeddingEndpoint,@JsonKey(name: 'embedding_dim') int embeddingDim,@JsonKey(name: 'embedding_chunk_size') int embeddingChunkSize,@JsonKey(name: 'batch_size') int batchSize
});




}
/// @nodoc
class __$EmbeddingModelCopyWithImpl<$Res>
    implements _$EmbeddingModelCopyWith<$Res> {
  __$EmbeddingModelCopyWithImpl(this._self, this._then);

  final _EmbeddingModel _self;
  final $Res Function(_EmbeddingModel) _then;

/// Create a copy of EmbeddingModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? handle = null,Object? name = null,Object? displayName = null,Object? providerType = null,Object? providerName = null,Object? embeddingModel = null,Object? embeddingEndpointType = null,Object? embeddingEndpoint = null,Object? embeddingDim = null,Object? embeddingChunkSize = null,Object? batchSize = null,}) {
  return _then(_EmbeddingModel(
handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,providerType: null == providerType ? _self.providerType : providerType // ignore: cast_nullable_to_non_nullable
as String,providerName: null == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String,embeddingModel: null == embeddingModel ? _self.embeddingModel : embeddingModel // ignore: cast_nullable_to_non_nullable
as String,embeddingEndpointType: null == embeddingEndpointType ? _self.embeddingEndpointType : embeddingEndpointType // ignore: cast_nullable_to_non_nullable
as String,embeddingEndpoint: null == embeddingEndpoint ? _self.embeddingEndpoint : embeddingEndpoint // ignore: cast_nullable_to_non_nullable
as String,embeddingDim: null == embeddingDim ? _self.embeddingDim : embeddingDim // ignore: cast_nullable_to_non_nullable
as int,embeddingChunkSize: null == embeddingChunkSize ? _self.embeddingChunkSize : embeddingChunkSize // ignore: cast_nullable_to_non_nullable
as int,batchSize: null == batchSize ? _self.batchSize : batchSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
