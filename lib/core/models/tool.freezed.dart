// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tool.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Tool {

 String get id; String get name; String? get description;@JsonKey(name: 'tool_type') ToolType? get toolType;@JsonKey(name: 'source_type') String? get sourceType;@JsonKey(name: 'source_code') String? get sourceCode;@JsonKey(name: 'json_schema') Map<String, dynamic>? get jsonSchema;@JsonKey(name: 'args_json_schema') Map<String, dynamic>? get argsJsonSchema;@JsonKey(name: 'default_requires_approval') bool? get defaultRequiresApproval;@JsonKey(name: 'enable_parallel_execution') bool? get enableParallelExecution; List<String>? get tags;
/// Create a copy of Tool
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ToolCopyWith<Tool> get copyWith => _$ToolCopyWithImpl<Tool>(this as Tool, _$identity);

  /// Serializes this Tool to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tool&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.toolType, toolType) || other.toolType == toolType)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.sourceCode, sourceCode) || other.sourceCode == sourceCode)&&const DeepCollectionEquality().equals(other.jsonSchema, jsonSchema)&&const DeepCollectionEquality().equals(other.argsJsonSchema, argsJsonSchema)&&(identical(other.defaultRequiresApproval, defaultRequiresApproval) || other.defaultRequiresApproval == defaultRequiresApproval)&&(identical(other.enableParallelExecution, enableParallelExecution) || other.enableParallelExecution == enableParallelExecution)&&const DeepCollectionEquality().equals(other.tags, tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,toolType,sourceType,sourceCode,const DeepCollectionEquality().hash(jsonSchema),const DeepCollectionEquality().hash(argsJsonSchema),defaultRequiresApproval,enableParallelExecution,const DeepCollectionEquality().hash(tags));

@override
String toString() {
  return 'Tool(id: $id, name: $name, description: $description, toolType: $toolType, sourceType: $sourceType, sourceCode: $sourceCode, jsonSchema: $jsonSchema, argsJsonSchema: $argsJsonSchema, defaultRequiresApproval: $defaultRequiresApproval, enableParallelExecution: $enableParallelExecution, tags: $tags)';
}


}

/// @nodoc
abstract mixin class $ToolCopyWith<$Res>  {
  factory $ToolCopyWith(Tool value, $Res Function(Tool) _then) = _$ToolCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description,@JsonKey(name: 'tool_type') ToolType? toolType,@JsonKey(name: 'source_type') String? sourceType,@JsonKey(name: 'source_code') String? sourceCode,@JsonKey(name: 'json_schema') Map<String, dynamic>? jsonSchema,@JsonKey(name: 'args_json_schema') Map<String, dynamic>? argsJsonSchema,@JsonKey(name: 'default_requires_approval') bool? defaultRequiresApproval,@JsonKey(name: 'enable_parallel_execution') bool? enableParallelExecution, List<String>? tags
});




}
/// @nodoc
class _$ToolCopyWithImpl<$Res>
    implements $ToolCopyWith<$Res> {
  _$ToolCopyWithImpl(this._self, this._then);

  final Tool _self;
  final $Res Function(Tool) _then;

/// Create a copy of Tool
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? toolType = freezed,Object? sourceType = freezed,Object? sourceCode = freezed,Object? jsonSchema = freezed,Object? argsJsonSchema = freezed,Object? defaultRequiresApproval = freezed,Object? enableParallelExecution = freezed,Object? tags = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,toolType: freezed == toolType ? _self.toolType : toolType // ignore: cast_nullable_to_non_nullable
as ToolType?,sourceType: freezed == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String?,sourceCode: freezed == sourceCode ? _self.sourceCode : sourceCode // ignore: cast_nullable_to_non_nullable
as String?,jsonSchema: freezed == jsonSchema ? _self.jsonSchema : jsonSchema // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,argsJsonSchema: freezed == argsJsonSchema ? _self.argsJsonSchema : argsJsonSchema // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,defaultRequiresApproval: freezed == defaultRequiresApproval ? _self.defaultRequiresApproval : defaultRequiresApproval // ignore: cast_nullable_to_non_nullable
as bool?,enableParallelExecution: freezed == enableParallelExecution ? _self.enableParallelExecution : enableParallelExecution // ignore: cast_nullable_to_non_nullable
as bool?,tags: freezed == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [Tool].
extension ToolPatterns on Tool {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Tool value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Tool() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Tool value)  $default,){
final _that = this;
switch (_that) {
case _Tool():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Tool value)?  $default,){
final _that = this;
switch (_that) {
case _Tool() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description, @JsonKey(name: 'tool_type')  ToolType? toolType, @JsonKey(name: 'source_type')  String? sourceType, @JsonKey(name: 'source_code')  String? sourceCode, @JsonKey(name: 'json_schema')  Map<String, dynamic>? jsonSchema, @JsonKey(name: 'args_json_schema')  Map<String, dynamic>? argsJsonSchema, @JsonKey(name: 'default_requires_approval')  bool? defaultRequiresApproval, @JsonKey(name: 'enable_parallel_execution')  bool? enableParallelExecution,  List<String>? tags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tool() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.toolType,_that.sourceType,_that.sourceCode,_that.jsonSchema,_that.argsJsonSchema,_that.defaultRequiresApproval,_that.enableParallelExecution,_that.tags);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description, @JsonKey(name: 'tool_type')  ToolType? toolType, @JsonKey(name: 'source_type')  String? sourceType, @JsonKey(name: 'source_code')  String? sourceCode, @JsonKey(name: 'json_schema')  Map<String, dynamic>? jsonSchema, @JsonKey(name: 'args_json_schema')  Map<String, dynamic>? argsJsonSchema, @JsonKey(name: 'default_requires_approval')  bool? defaultRequiresApproval, @JsonKey(name: 'enable_parallel_execution')  bool? enableParallelExecution,  List<String>? tags)  $default,) {final _that = this;
switch (_that) {
case _Tool():
return $default(_that.id,_that.name,_that.description,_that.toolType,_that.sourceType,_that.sourceCode,_that.jsonSchema,_that.argsJsonSchema,_that.defaultRequiresApproval,_that.enableParallelExecution,_that.tags);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description, @JsonKey(name: 'tool_type')  ToolType? toolType, @JsonKey(name: 'source_type')  String? sourceType, @JsonKey(name: 'source_code')  String? sourceCode, @JsonKey(name: 'json_schema')  Map<String, dynamic>? jsonSchema, @JsonKey(name: 'args_json_schema')  Map<String, dynamic>? argsJsonSchema, @JsonKey(name: 'default_requires_approval')  bool? defaultRequiresApproval, @JsonKey(name: 'enable_parallel_execution')  bool? enableParallelExecution,  List<String>? tags)?  $default,) {final _that = this;
switch (_that) {
case _Tool() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.toolType,_that.sourceType,_that.sourceCode,_that.jsonSchema,_that.argsJsonSchema,_that.defaultRequiresApproval,_that.enableParallelExecution,_that.tags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Tool extends Tool {
  const _Tool({required this.id, required this.name, this.description, @JsonKey(name: 'tool_type') this.toolType, @JsonKey(name: 'source_type') this.sourceType, @JsonKey(name: 'source_code') this.sourceCode, @JsonKey(name: 'json_schema') final  Map<String, dynamic>? jsonSchema, @JsonKey(name: 'args_json_schema') final  Map<String, dynamic>? argsJsonSchema, @JsonKey(name: 'default_requires_approval') this.defaultRequiresApproval, @JsonKey(name: 'enable_parallel_execution') this.enableParallelExecution, final  List<String>? tags}): _jsonSchema = jsonSchema,_argsJsonSchema = argsJsonSchema,_tags = tags,super._();
  factory _Tool.fromJson(Map<String, dynamic> json) => _$ToolFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override@JsonKey(name: 'tool_type') final  ToolType? toolType;
@override@JsonKey(name: 'source_type') final  String? sourceType;
@override@JsonKey(name: 'source_code') final  String? sourceCode;
 final  Map<String, dynamic>? _jsonSchema;
@override@JsonKey(name: 'json_schema') Map<String, dynamic>? get jsonSchema {
  final value = _jsonSchema;
  if (value == null) return null;
  if (_jsonSchema is EqualUnmodifiableMapView) return _jsonSchema;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _argsJsonSchema;
@override@JsonKey(name: 'args_json_schema') Map<String, dynamic>? get argsJsonSchema {
  final value = _argsJsonSchema;
  if (value == null) return null;
  if (_argsJsonSchema is EqualUnmodifiableMapView) return _argsJsonSchema;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'default_requires_approval') final  bool? defaultRequiresApproval;
@override@JsonKey(name: 'enable_parallel_execution') final  bool? enableParallelExecution;
 final  List<String>? _tags;
@override List<String>? get tags {
  final value = _tags;
  if (value == null) return null;
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of Tool
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ToolCopyWith<_Tool> get copyWith => __$ToolCopyWithImpl<_Tool>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ToolToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tool&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.toolType, toolType) || other.toolType == toolType)&&(identical(other.sourceType, sourceType) || other.sourceType == sourceType)&&(identical(other.sourceCode, sourceCode) || other.sourceCode == sourceCode)&&const DeepCollectionEquality().equals(other._jsonSchema, _jsonSchema)&&const DeepCollectionEquality().equals(other._argsJsonSchema, _argsJsonSchema)&&(identical(other.defaultRequiresApproval, defaultRequiresApproval) || other.defaultRequiresApproval == defaultRequiresApproval)&&(identical(other.enableParallelExecution, enableParallelExecution) || other.enableParallelExecution == enableParallelExecution)&&const DeepCollectionEquality().equals(other._tags, _tags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,toolType,sourceType,sourceCode,const DeepCollectionEquality().hash(_jsonSchema),const DeepCollectionEquality().hash(_argsJsonSchema),defaultRequiresApproval,enableParallelExecution,const DeepCollectionEquality().hash(_tags));

@override
String toString() {
  return 'Tool(id: $id, name: $name, description: $description, toolType: $toolType, sourceType: $sourceType, sourceCode: $sourceCode, jsonSchema: $jsonSchema, argsJsonSchema: $argsJsonSchema, defaultRequiresApproval: $defaultRequiresApproval, enableParallelExecution: $enableParallelExecution, tags: $tags)';
}


}

/// @nodoc
abstract mixin class _$ToolCopyWith<$Res> implements $ToolCopyWith<$Res> {
  factory _$ToolCopyWith(_Tool value, $Res Function(_Tool) _then) = __$ToolCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description,@JsonKey(name: 'tool_type') ToolType? toolType,@JsonKey(name: 'source_type') String? sourceType,@JsonKey(name: 'source_code') String? sourceCode,@JsonKey(name: 'json_schema') Map<String, dynamic>? jsonSchema,@JsonKey(name: 'args_json_schema') Map<String, dynamic>? argsJsonSchema,@JsonKey(name: 'default_requires_approval') bool? defaultRequiresApproval,@JsonKey(name: 'enable_parallel_execution') bool? enableParallelExecution, List<String>? tags
});




}
/// @nodoc
class __$ToolCopyWithImpl<$Res>
    implements _$ToolCopyWith<$Res> {
  __$ToolCopyWithImpl(this._self, this._then);

  final _Tool _self;
  final $Res Function(_Tool) _then;

/// Create a copy of Tool
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? toolType = freezed,Object? sourceType = freezed,Object? sourceCode = freezed,Object? jsonSchema = freezed,Object? argsJsonSchema = freezed,Object? defaultRequiresApproval = freezed,Object? enableParallelExecution = freezed,Object? tags = freezed,}) {
  return _then(_Tool(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,toolType: freezed == toolType ? _self.toolType : toolType // ignore: cast_nullable_to_non_nullable
as ToolType?,sourceType: freezed == sourceType ? _self.sourceType : sourceType // ignore: cast_nullable_to_non_nullable
as String?,sourceCode: freezed == sourceCode ? _self.sourceCode : sourceCode // ignore: cast_nullable_to_non_nullable
as String?,jsonSchema: freezed == jsonSchema ? _self._jsonSchema : jsonSchema // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,argsJsonSchema: freezed == argsJsonSchema ? _self._argsJsonSchema : argsJsonSchema // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,defaultRequiresApproval: freezed == defaultRequiresApproval ? _self.defaultRequiresApproval : defaultRequiresApproval // ignore: cast_nullable_to_non_nullable
as bool?,enableParallelExecution: freezed == enableParallelExecution ? _self.enableParallelExecution : enableParallelExecution // ignore: cast_nullable_to_non_nullable
as bool?,tags: freezed == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
