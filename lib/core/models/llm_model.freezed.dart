// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'llm_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LLMModel {

 String get handle; String get name;@JsonKey(name: 'display_name') String get displayName;@JsonKey(name: 'provider_type') String get providerType;@JsonKey(name: 'provider_name') String get providerName; String get model;@JsonKey(name: 'model_endpoint_type') String get modelEndpointType;@JsonKey(name: 'model_endpoint') String get modelEndpoint;@JsonKey(name: 'model_type') String get modelType;@JsonKey(name: 'context_window') int get contextWindow;@JsonKey(name: 'put_inner_thoughts_in_kwargs') bool get putInnerThoughtsInKwargs; double get temperature;@JsonKey(name: 'max_tokens') int get maxTokens;
/// Create a copy of LLMModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LLMModelCopyWith<LLMModel> get copyWith => _$LLMModelCopyWithImpl<LLMModel>(this as LLMModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LLMModel&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.providerType, providerType) || other.providerType == providerType)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&(identical(other.model, model) || other.model == model)&&(identical(other.modelEndpointType, modelEndpointType) || other.modelEndpointType == modelEndpointType)&&(identical(other.modelEndpoint, modelEndpoint) || other.modelEndpoint == modelEndpoint)&&(identical(other.modelType, modelType) || other.modelType == modelType)&&(identical(other.contextWindow, contextWindow) || other.contextWindow == contextWindow)&&(identical(other.putInnerThoughtsInKwargs, putInnerThoughtsInKwargs) || other.putInnerThoughtsInKwargs == putInnerThoughtsInKwargs)&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.maxTokens, maxTokens) || other.maxTokens == maxTokens));
}


@override
int get hashCode => Object.hash(runtimeType,handle,name,displayName,providerType,providerName,model,modelEndpointType,modelEndpoint,modelType,contextWindow,putInnerThoughtsInKwargs,temperature,maxTokens);

@override
String toString() {
  return 'LLMModel(handle: $handle, name: $name, displayName: $displayName, providerType: $providerType, providerName: $providerName, model: $model, modelEndpointType: $modelEndpointType, modelEndpoint: $modelEndpoint, modelType: $modelType, contextWindow: $contextWindow, putInnerThoughtsInKwargs: $putInnerThoughtsInKwargs, temperature: $temperature, maxTokens: $maxTokens)';
}


}

/// @nodoc
abstract mixin class $LLMModelCopyWith<$Res>  {
  factory $LLMModelCopyWith(LLMModel value, $Res Function(LLMModel) _then) = _$LLMModelCopyWithImpl;
@useResult
$Res call({
 String handle, String name,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'provider_type') String providerType,@JsonKey(name: 'provider_name') String providerName, String model,@JsonKey(name: 'model_endpoint_type') String modelEndpointType,@JsonKey(name: 'model_endpoint') String modelEndpoint,@JsonKey(name: 'model_type') String modelType,@JsonKey(name: 'context_window') int contextWindow,@JsonKey(name: 'put_inner_thoughts_in_kwargs') bool putInnerThoughtsInKwargs, double temperature,@JsonKey(name: 'max_tokens') int maxTokens
});




}
/// @nodoc
class _$LLMModelCopyWithImpl<$Res>
    implements $LLMModelCopyWith<$Res> {
  _$LLMModelCopyWithImpl(this._self, this._then);

  final LLMModel _self;
  final $Res Function(LLMModel) _then;

/// Create a copy of LLMModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? handle = null,Object? name = null,Object? displayName = null,Object? providerType = null,Object? providerName = null,Object? model = null,Object? modelEndpointType = null,Object? modelEndpoint = null,Object? modelType = null,Object? contextWindow = null,Object? putInnerThoughtsInKwargs = null,Object? temperature = null,Object? maxTokens = null,}) {
  return _then(_self.copyWith(
handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,providerType: null == providerType ? _self.providerType : providerType // ignore: cast_nullable_to_non_nullable
as String,providerName: null == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,modelEndpointType: null == modelEndpointType ? _self.modelEndpointType : modelEndpointType // ignore: cast_nullable_to_non_nullable
as String,modelEndpoint: null == modelEndpoint ? _self.modelEndpoint : modelEndpoint // ignore: cast_nullable_to_non_nullable
as String,modelType: null == modelType ? _self.modelType : modelType // ignore: cast_nullable_to_non_nullable
as String,contextWindow: null == contextWindow ? _self.contextWindow : contextWindow // ignore: cast_nullable_to_non_nullable
as int,putInnerThoughtsInKwargs: null == putInnerThoughtsInKwargs ? _self.putInnerThoughtsInKwargs : putInnerThoughtsInKwargs // ignore: cast_nullable_to_non_nullable
as bool,temperature: null == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double,maxTokens: null == maxTokens ? _self.maxTokens : maxTokens // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [LLMModel].
extension LLMModelPatterns on LLMModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LLMModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LLMModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LLMModel value)  $default,){
final _that = this;
switch (_that) {
case _LLMModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LLMModel value)?  $default,){
final _that = this;
switch (_that) {
case _LLMModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String handle,  String name, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'provider_type')  String providerType, @JsonKey(name: 'provider_name')  String providerName,  String model, @JsonKey(name: 'model_endpoint_type')  String modelEndpointType, @JsonKey(name: 'model_endpoint')  String modelEndpoint, @JsonKey(name: 'model_type')  String modelType, @JsonKey(name: 'context_window')  int contextWindow, @JsonKey(name: 'put_inner_thoughts_in_kwargs')  bool putInnerThoughtsInKwargs,  double temperature, @JsonKey(name: 'max_tokens')  int maxTokens)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LLMModel() when $default != null:
return $default(_that.handle,_that.name,_that.displayName,_that.providerType,_that.providerName,_that.model,_that.modelEndpointType,_that.modelEndpoint,_that.modelType,_that.contextWindow,_that.putInnerThoughtsInKwargs,_that.temperature,_that.maxTokens);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String handle,  String name, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'provider_type')  String providerType, @JsonKey(name: 'provider_name')  String providerName,  String model, @JsonKey(name: 'model_endpoint_type')  String modelEndpointType, @JsonKey(name: 'model_endpoint')  String modelEndpoint, @JsonKey(name: 'model_type')  String modelType, @JsonKey(name: 'context_window')  int contextWindow, @JsonKey(name: 'put_inner_thoughts_in_kwargs')  bool putInnerThoughtsInKwargs,  double temperature, @JsonKey(name: 'max_tokens')  int maxTokens)  $default,) {final _that = this;
switch (_that) {
case _LLMModel():
return $default(_that.handle,_that.name,_that.displayName,_that.providerType,_that.providerName,_that.model,_that.modelEndpointType,_that.modelEndpoint,_that.modelType,_that.contextWindow,_that.putInnerThoughtsInKwargs,_that.temperature,_that.maxTokens);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String handle,  String name, @JsonKey(name: 'display_name')  String displayName, @JsonKey(name: 'provider_type')  String providerType, @JsonKey(name: 'provider_name')  String providerName,  String model, @JsonKey(name: 'model_endpoint_type')  String modelEndpointType, @JsonKey(name: 'model_endpoint')  String modelEndpoint, @JsonKey(name: 'model_type')  String modelType, @JsonKey(name: 'context_window')  int contextWindow, @JsonKey(name: 'put_inner_thoughts_in_kwargs')  bool putInnerThoughtsInKwargs,  double temperature, @JsonKey(name: 'max_tokens')  int maxTokens)?  $default,) {final _that = this;
switch (_that) {
case _LLMModel() when $default != null:
return $default(_that.handle,_that.name,_that.displayName,_that.providerType,_that.providerName,_that.model,_that.modelEndpointType,_that.modelEndpoint,_that.modelType,_that.contextWindow,_that.putInnerThoughtsInKwargs,_that.temperature,_that.maxTokens);case _:
  return null;

}
}

}

/// @nodoc


class _LLMModel extends LLMModel {
  const _LLMModel({required this.handle, required this.name, @JsonKey(name: 'display_name') required this.displayName, @JsonKey(name: 'provider_type') required this.providerType, @JsonKey(name: 'provider_name') required this.providerName, required this.model, @JsonKey(name: 'model_endpoint_type') required this.modelEndpointType, @JsonKey(name: 'model_endpoint') required this.modelEndpoint, @JsonKey(name: 'model_type') required this.modelType, @JsonKey(name: 'context_window') required this.contextWindow, @JsonKey(name: 'put_inner_thoughts_in_kwargs') required this.putInnerThoughtsInKwargs, required this.temperature, @JsonKey(name: 'max_tokens') required this.maxTokens}): super._();
  

@override final  String handle;
@override final  String name;
@override@JsonKey(name: 'display_name') final  String displayName;
@override@JsonKey(name: 'provider_type') final  String providerType;
@override@JsonKey(name: 'provider_name') final  String providerName;
@override final  String model;
@override@JsonKey(name: 'model_endpoint_type') final  String modelEndpointType;
@override@JsonKey(name: 'model_endpoint') final  String modelEndpoint;
@override@JsonKey(name: 'model_type') final  String modelType;
@override@JsonKey(name: 'context_window') final  int contextWindow;
@override@JsonKey(name: 'put_inner_thoughts_in_kwargs') final  bool putInnerThoughtsInKwargs;
@override final  double temperature;
@override@JsonKey(name: 'max_tokens') final  int maxTokens;

/// Create a copy of LLMModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LLMModelCopyWith<_LLMModel> get copyWith => __$LLMModelCopyWithImpl<_LLMModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LLMModel&&(identical(other.handle, handle) || other.handle == handle)&&(identical(other.name, name) || other.name == name)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.providerType, providerType) || other.providerType == providerType)&&(identical(other.providerName, providerName) || other.providerName == providerName)&&(identical(other.model, model) || other.model == model)&&(identical(other.modelEndpointType, modelEndpointType) || other.modelEndpointType == modelEndpointType)&&(identical(other.modelEndpoint, modelEndpoint) || other.modelEndpoint == modelEndpoint)&&(identical(other.modelType, modelType) || other.modelType == modelType)&&(identical(other.contextWindow, contextWindow) || other.contextWindow == contextWindow)&&(identical(other.putInnerThoughtsInKwargs, putInnerThoughtsInKwargs) || other.putInnerThoughtsInKwargs == putInnerThoughtsInKwargs)&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.maxTokens, maxTokens) || other.maxTokens == maxTokens));
}


@override
int get hashCode => Object.hash(runtimeType,handle,name,displayName,providerType,providerName,model,modelEndpointType,modelEndpoint,modelType,contextWindow,putInnerThoughtsInKwargs,temperature,maxTokens);

@override
String toString() {
  return 'LLMModel(handle: $handle, name: $name, displayName: $displayName, providerType: $providerType, providerName: $providerName, model: $model, modelEndpointType: $modelEndpointType, modelEndpoint: $modelEndpoint, modelType: $modelType, contextWindow: $contextWindow, putInnerThoughtsInKwargs: $putInnerThoughtsInKwargs, temperature: $temperature, maxTokens: $maxTokens)';
}


}

/// @nodoc
abstract mixin class _$LLMModelCopyWith<$Res> implements $LLMModelCopyWith<$Res> {
  factory _$LLMModelCopyWith(_LLMModel value, $Res Function(_LLMModel) _then) = __$LLMModelCopyWithImpl;
@override @useResult
$Res call({
 String handle, String name,@JsonKey(name: 'display_name') String displayName,@JsonKey(name: 'provider_type') String providerType,@JsonKey(name: 'provider_name') String providerName, String model,@JsonKey(name: 'model_endpoint_type') String modelEndpointType,@JsonKey(name: 'model_endpoint') String modelEndpoint,@JsonKey(name: 'model_type') String modelType,@JsonKey(name: 'context_window') int contextWindow,@JsonKey(name: 'put_inner_thoughts_in_kwargs') bool putInnerThoughtsInKwargs, double temperature,@JsonKey(name: 'max_tokens') int maxTokens
});




}
/// @nodoc
class __$LLMModelCopyWithImpl<$Res>
    implements _$LLMModelCopyWith<$Res> {
  __$LLMModelCopyWithImpl(this._self, this._then);

  final _LLMModel _self;
  final $Res Function(_LLMModel) _then;

/// Create a copy of LLMModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? handle = null,Object? name = null,Object? displayName = null,Object? providerType = null,Object? providerName = null,Object? model = null,Object? modelEndpointType = null,Object? modelEndpoint = null,Object? modelType = null,Object? contextWindow = null,Object? putInnerThoughtsInKwargs = null,Object? temperature = null,Object? maxTokens = null,}) {
  return _then(_LLMModel(
handle: null == handle ? _self.handle : handle // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,providerType: null == providerType ? _self.providerType : providerType // ignore: cast_nullable_to_non_nullable
as String,providerName: null == providerName ? _self.providerName : providerName // ignore: cast_nullable_to_non_nullable
as String,model: null == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String,modelEndpointType: null == modelEndpointType ? _self.modelEndpointType : modelEndpointType // ignore: cast_nullable_to_non_nullable
as String,modelEndpoint: null == modelEndpoint ? _self.modelEndpoint : modelEndpoint // ignore: cast_nullable_to_non_nullable
as String,modelType: null == modelType ? _self.modelType : modelType // ignore: cast_nullable_to_non_nullable
as String,contextWindow: null == contextWindow ? _self.contextWindow : contextWindow // ignore: cast_nullable_to_non_nullable
as int,putInnerThoughtsInKwargs: null == putInnerThoughtsInKwargs ? _self.putInnerThoughtsInKwargs : putInnerThoughtsInKwargs // ignore: cast_nullable_to_non_nullable
as bool,temperature: null == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double,maxTokens: null == maxTokens ? _self.maxTokens : maxTokens // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
