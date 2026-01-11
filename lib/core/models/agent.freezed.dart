// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'agent.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Agent {

 String get id; String get name; String? get description; String? get model; String? get embedding;@JsonKey(name: 'agent_type') String? get agentType;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'modified_at') DateTime? get modifiedAt; Map<String, dynamic>? get config;@JsonKey(name: 'llm_config') Map<String, dynamic>? get llmConfig;@JsonKey(name: 'embedding_config') Map<String, dynamic>? get embeddingConfig;@JsonKey(name: 'model_settings') Map<String, dynamic>? get modelSettings; List<String>? get tools; List<String>? get tags; Map<String, dynamic>? get metadata;@JsonKey(name: 'system') String? get systemPrompt;
/// Create a copy of Agent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgentCopyWith<Agent> get copyWith => _$AgentCopyWithImpl<Agent>(this as Agent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Agent&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.model, model) || other.model == model)&&(identical(other.embedding, embedding) || other.embedding == embedding)&&(identical(other.agentType, agentType) || other.agentType == agentType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.modifiedAt, modifiedAt) || other.modifiedAt == modifiedAt)&&const DeepCollectionEquality().equals(other.config, config)&&const DeepCollectionEquality().equals(other.llmConfig, llmConfig)&&const DeepCollectionEquality().equals(other.embeddingConfig, embeddingConfig)&&const DeepCollectionEquality().equals(other.modelSettings, modelSettings)&&const DeepCollectionEquality().equals(other.tools, tools)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.systemPrompt, systemPrompt) || other.systemPrompt == systemPrompt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,model,embedding,agentType,createdAt,modifiedAt,const DeepCollectionEquality().hash(config),const DeepCollectionEquality().hash(llmConfig),const DeepCollectionEquality().hash(embeddingConfig),const DeepCollectionEquality().hash(modelSettings),const DeepCollectionEquality().hash(tools),const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(metadata),systemPrompt);

@override
String toString() {
  return 'Agent(id: $id, name: $name, description: $description, model: $model, embedding: $embedding, agentType: $agentType, createdAt: $createdAt, modifiedAt: $modifiedAt, config: $config, llmConfig: $llmConfig, embeddingConfig: $embeddingConfig, modelSettings: $modelSettings, tools: $tools, tags: $tags, metadata: $metadata, systemPrompt: $systemPrompt)';
}


}

/// @nodoc
abstract mixin class $AgentCopyWith<$Res>  {
  factory $AgentCopyWith(Agent value, $Res Function(Agent) _then) = _$AgentCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, String? model, String? embedding,@JsonKey(name: 'agent_type') String? agentType,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'modified_at') DateTime? modifiedAt, Map<String, dynamic>? config,@JsonKey(name: 'llm_config') Map<String, dynamic>? llmConfig,@JsonKey(name: 'embedding_config') Map<String, dynamic>? embeddingConfig,@JsonKey(name: 'model_settings') Map<String, dynamic>? modelSettings, List<String>? tools, List<String>? tags, Map<String, dynamic>? metadata,@JsonKey(name: 'system') String? systemPrompt
});




}
/// @nodoc
class _$AgentCopyWithImpl<$Res>
    implements $AgentCopyWith<$Res> {
  _$AgentCopyWithImpl(this._self, this._then);

  final Agent _self;
  final $Res Function(Agent) _then;

/// Create a copy of Agent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? model = freezed,Object? embedding = freezed,Object? agentType = freezed,Object? createdAt = freezed,Object? modifiedAt = freezed,Object? config = freezed,Object? llmConfig = freezed,Object? embeddingConfig = freezed,Object? modelSettings = freezed,Object? tools = freezed,Object? tags = freezed,Object? metadata = freezed,Object? systemPrompt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,embedding: freezed == embedding ? _self.embedding : embedding // ignore: cast_nullable_to_non_nullable
as String?,agentType: freezed == agentType ? _self.agentType : agentType // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,modifiedAt: freezed == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,config: freezed == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,llmConfig: freezed == llmConfig ? _self.llmConfig : llmConfig // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,embeddingConfig: freezed == embeddingConfig ? _self.embeddingConfig : embeddingConfig // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,modelSettings: freezed == modelSettings ? _self.modelSettings : modelSettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,tools: freezed == tools ? _self.tools : tools // ignore: cast_nullable_to_non_nullable
as List<String>?,tags: freezed == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,systemPrompt: freezed == systemPrompt ? _self.systemPrompt : systemPrompt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Agent].
extension AgentPatterns on Agent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Agent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Agent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Agent value)  $default,){
final _that = this;
switch (_that) {
case _Agent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Agent value)?  $default,){
final _that = this;
switch (_that) {
case _Agent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String? model,  String? embedding, @JsonKey(name: 'agent_type')  String? agentType, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'modified_at')  DateTime? modifiedAt,  Map<String, dynamic>? config, @JsonKey(name: 'llm_config')  Map<String, dynamic>? llmConfig, @JsonKey(name: 'embedding_config')  Map<String, dynamic>? embeddingConfig, @JsonKey(name: 'model_settings')  Map<String, dynamic>? modelSettings,  List<String>? tools,  List<String>? tags,  Map<String, dynamic>? metadata, @JsonKey(name: 'system')  String? systemPrompt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Agent() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.model,_that.embedding,_that.agentType,_that.createdAt,_that.modifiedAt,_that.config,_that.llmConfig,_that.embeddingConfig,_that.modelSettings,_that.tools,_that.tags,_that.metadata,_that.systemPrompt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String? model,  String? embedding, @JsonKey(name: 'agent_type')  String? agentType, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'modified_at')  DateTime? modifiedAt,  Map<String, dynamic>? config, @JsonKey(name: 'llm_config')  Map<String, dynamic>? llmConfig, @JsonKey(name: 'embedding_config')  Map<String, dynamic>? embeddingConfig, @JsonKey(name: 'model_settings')  Map<String, dynamic>? modelSettings,  List<String>? tools,  List<String>? tags,  Map<String, dynamic>? metadata, @JsonKey(name: 'system')  String? systemPrompt)  $default,) {final _that = this;
switch (_that) {
case _Agent():
return $default(_that.id,_that.name,_that.description,_that.model,_that.embedding,_that.agentType,_that.createdAt,_that.modifiedAt,_that.config,_that.llmConfig,_that.embeddingConfig,_that.modelSettings,_that.tools,_that.tags,_that.metadata,_that.systemPrompt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  String? model,  String? embedding, @JsonKey(name: 'agent_type')  String? agentType, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'modified_at')  DateTime? modifiedAt,  Map<String, dynamic>? config, @JsonKey(name: 'llm_config')  Map<String, dynamic>? llmConfig, @JsonKey(name: 'embedding_config')  Map<String, dynamic>? embeddingConfig, @JsonKey(name: 'model_settings')  Map<String, dynamic>? modelSettings,  List<String>? tools,  List<String>? tags,  Map<String, dynamic>? metadata, @JsonKey(name: 'system')  String? systemPrompt)?  $default,) {final _that = this;
switch (_that) {
case _Agent() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.model,_that.embedding,_that.agentType,_that.createdAt,_that.modifiedAt,_that.config,_that.llmConfig,_that.embeddingConfig,_that.modelSettings,_that.tools,_that.tags,_that.metadata,_that.systemPrompt);case _:
  return null;

}
}

}

/// @nodoc


class _Agent extends Agent {
  const _Agent({required this.id, required this.name, this.description, this.model, this.embedding, @JsonKey(name: 'agent_type') this.agentType, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'modified_at') this.modifiedAt, final  Map<String, dynamic>? config, @JsonKey(name: 'llm_config') final  Map<String, dynamic>? llmConfig, @JsonKey(name: 'embedding_config') final  Map<String, dynamic>? embeddingConfig, @JsonKey(name: 'model_settings') final  Map<String, dynamic>? modelSettings, final  List<String>? tools, final  List<String>? tags, final  Map<String, dynamic>? metadata, @JsonKey(name: 'system') this.systemPrompt}): _config = config,_llmConfig = llmConfig,_embeddingConfig = embeddingConfig,_modelSettings = modelSettings,_tools = tools,_tags = tags,_metadata = metadata,super._();
  

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  String? model;
@override final  String? embedding;
@override@JsonKey(name: 'agent_type') final  String? agentType;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'modified_at') final  DateTime? modifiedAt;
 final  Map<String, dynamic>? _config;
@override Map<String, dynamic>? get config {
  final value = _config;
  if (value == null) return null;
  if (_config is EqualUnmodifiableMapView) return _config;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _llmConfig;
@override@JsonKey(name: 'llm_config') Map<String, dynamic>? get llmConfig {
  final value = _llmConfig;
  if (value == null) return null;
  if (_llmConfig is EqualUnmodifiableMapView) return _llmConfig;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _embeddingConfig;
@override@JsonKey(name: 'embedding_config') Map<String, dynamic>? get embeddingConfig {
  final value = _embeddingConfig;
  if (value == null) return null;
  if (_embeddingConfig is EqualUnmodifiableMapView) return _embeddingConfig;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _modelSettings;
@override@JsonKey(name: 'model_settings') Map<String, dynamic>? get modelSettings {
  final value = _modelSettings;
  if (value == null) return null;
  if (_modelSettings is EqualUnmodifiableMapView) return _modelSettings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  List<String>? _tools;
@override List<String>? get tools {
  final value = _tools;
  if (value == null) return null;
  if (_tools is EqualUnmodifiableListView) return _tools;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _tags;
@override List<String>? get tags {
  final value = _tags;
  if (value == null) return null;
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'system') final  String? systemPrompt;

/// Create a copy of Agent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AgentCopyWith<_Agent> get copyWith => __$AgentCopyWithImpl<_Agent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Agent&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.model, model) || other.model == model)&&(identical(other.embedding, embedding) || other.embedding == embedding)&&(identical(other.agentType, agentType) || other.agentType == agentType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.modifiedAt, modifiedAt) || other.modifiedAt == modifiedAt)&&const DeepCollectionEquality().equals(other._config, _config)&&const DeepCollectionEquality().equals(other._llmConfig, _llmConfig)&&const DeepCollectionEquality().equals(other._embeddingConfig, _embeddingConfig)&&const DeepCollectionEquality().equals(other._modelSettings, _modelSettings)&&const DeepCollectionEquality().equals(other._tools, _tools)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.systemPrompt, systemPrompt) || other.systemPrompt == systemPrompt));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,model,embedding,agentType,createdAt,modifiedAt,const DeepCollectionEquality().hash(_config),const DeepCollectionEquality().hash(_llmConfig),const DeepCollectionEquality().hash(_embeddingConfig),const DeepCollectionEquality().hash(_modelSettings),const DeepCollectionEquality().hash(_tools),const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_metadata),systemPrompt);

@override
String toString() {
  return 'Agent(id: $id, name: $name, description: $description, model: $model, embedding: $embedding, agentType: $agentType, createdAt: $createdAt, modifiedAt: $modifiedAt, config: $config, llmConfig: $llmConfig, embeddingConfig: $embeddingConfig, modelSettings: $modelSettings, tools: $tools, tags: $tags, metadata: $metadata, systemPrompt: $systemPrompt)';
}


}

/// @nodoc
abstract mixin class _$AgentCopyWith<$Res> implements $AgentCopyWith<$Res> {
  factory _$AgentCopyWith(_Agent value, $Res Function(_Agent) _then) = __$AgentCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, String? model, String? embedding,@JsonKey(name: 'agent_type') String? agentType,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'modified_at') DateTime? modifiedAt, Map<String, dynamic>? config,@JsonKey(name: 'llm_config') Map<String, dynamic>? llmConfig,@JsonKey(name: 'embedding_config') Map<String, dynamic>? embeddingConfig,@JsonKey(name: 'model_settings') Map<String, dynamic>? modelSettings, List<String>? tools, List<String>? tags, Map<String, dynamic>? metadata,@JsonKey(name: 'system') String? systemPrompt
});




}
/// @nodoc
class __$AgentCopyWithImpl<$Res>
    implements _$AgentCopyWith<$Res> {
  __$AgentCopyWithImpl(this._self, this._then);

  final _Agent _self;
  final $Res Function(_Agent) _then;

/// Create a copy of Agent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? model = freezed,Object? embedding = freezed,Object? agentType = freezed,Object? createdAt = freezed,Object? modifiedAt = freezed,Object? config = freezed,Object? llmConfig = freezed,Object? embeddingConfig = freezed,Object? modelSettings = freezed,Object? tools = freezed,Object? tags = freezed,Object? metadata = freezed,Object? systemPrompt = freezed,}) {
  return _then(_Agent(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,embedding: freezed == embedding ? _self.embedding : embedding // ignore: cast_nullable_to_non_nullable
as String?,agentType: freezed == agentType ? _self.agentType : agentType // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,modifiedAt: freezed == modifiedAt ? _self.modifiedAt : modifiedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,config: freezed == config ? _self._config : config // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,llmConfig: freezed == llmConfig ? _self._llmConfig : llmConfig // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,embeddingConfig: freezed == embeddingConfig ? _self._embeddingConfig : embeddingConfig // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,modelSettings: freezed == modelSettings ? _self._modelSettings : modelSettings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,tools: freezed == tools ? _self._tools : tools // ignore: cast_nullable_to_non_nullable
as List<String>?,tags: freezed == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,systemPrompt: freezed == systemPrompt ? _self.systemPrompt : systemPrompt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
