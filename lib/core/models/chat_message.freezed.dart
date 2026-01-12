// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatMessage {

 String get id; MessageType get type; String get content; Map<String, dynamic>? get metadata;// Tool call specific fields
@JsonKey(name: 'tool_name') String? get toolName;@JsonKey(name: 'tool_input') Map<String, dynamic>? get toolInput;@JsonKey(name: 'tool_call_id') String? get toolCallId;@JsonKey(name: 'is_tool_error') bool? get isToolError;
/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessageCopyWith<ChatMessage> get copyWith => _$ChatMessageCopyWithImpl<ChatMessage>(this as ChatMessage, _$identity);

  /// Serializes this ChatMessage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.toolName, toolName) || other.toolName == toolName)&&const DeepCollectionEquality().equals(other.toolInput, toolInput)&&(identical(other.toolCallId, toolCallId) || other.toolCallId == toolCallId)&&(identical(other.isToolError, isToolError) || other.isToolError == isToolError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,content,const DeepCollectionEquality().hash(metadata),toolName,const DeepCollectionEquality().hash(toolInput),toolCallId,isToolError);

@override
String toString() {
  return 'ChatMessage(id: $id, type: $type, content: $content, metadata: $metadata, toolName: $toolName, toolInput: $toolInput, toolCallId: $toolCallId, isToolError: $isToolError)';
}


}

/// @nodoc
abstract mixin class $ChatMessageCopyWith<$Res>  {
  factory $ChatMessageCopyWith(ChatMessage value, $Res Function(ChatMessage) _then) = _$ChatMessageCopyWithImpl;
@useResult
$Res call({
 String id, MessageType type, String content, Map<String, dynamic>? metadata,@JsonKey(name: 'tool_name') String? toolName,@JsonKey(name: 'tool_input') Map<String, dynamic>? toolInput,@JsonKey(name: 'tool_call_id') String? toolCallId,@JsonKey(name: 'is_tool_error') bool? isToolError
});




}
/// @nodoc
class _$ChatMessageCopyWithImpl<$Res>
    implements $ChatMessageCopyWith<$Res> {
  _$ChatMessageCopyWithImpl(this._self, this._then);

  final ChatMessage _self;
  final $Res Function(ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? content = null,Object? metadata = freezed,Object? toolName = freezed,Object? toolInput = freezed,Object? toolCallId = freezed,Object? isToolError = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,toolName: freezed == toolName ? _self.toolName : toolName // ignore: cast_nullable_to_non_nullable
as String?,toolInput: freezed == toolInput ? _self.toolInput : toolInput // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,toolCallId: freezed == toolCallId ? _self.toolCallId : toolCallId // ignore: cast_nullable_to_non_nullable
as String?,isToolError: freezed == isToolError ? _self.isToolError : isToolError // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessage].
extension ChatMessagePatterns on ChatMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessage value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessage value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  MessageType type,  String content,  Map<String, dynamic>? metadata, @JsonKey(name: 'tool_name')  String? toolName, @JsonKey(name: 'tool_input')  Map<String, dynamic>? toolInput, @JsonKey(name: 'tool_call_id')  String? toolCallId, @JsonKey(name: 'is_tool_error')  bool? isToolError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.type,_that.content,_that.metadata,_that.toolName,_that.toolInput,_that.toolCallId,_that.isToolError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  MessageType type,  String content,  Map<String, dynamic>? metadata, @JsonKey(name: 'tool_name')  String? toolName, @JsonKey(name: 'tool_input')  Map<String, dynamic>? toolInput, @JsonKey(name: 'tool_call_id')  String? toolCallId, @JsonKey(name: 'is_tool_error')  bool? isToolError)  $default,) {final _that = this;
switch (_that) {
case _ChatMessage():
return $default(_that.id,_that.type,_that.content,_that.metadata,_that.toolName,_that.toolInput,_that.toolCallId,_that.isToolError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  MessageType type,  String content,  Map<String, dynamic>? metadata, @JsonKey(name: 'tool_name')  String? toolName, @JsonKey(name: 'tool_input')  Map<String, dynamic>? toolInput, @JsonKey(name: 'tool_call_id')  String? toolCallId, @JsonKey(name: 'is_tool_error')  bool? isToolError)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessage() when $default != null:
return $default(_that.id,_that.type,_that.content,_that.metadata,_that.toolName,_that.toolInput,_that.toolCallId,_that.isToolError);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ChatMessage extends ChatMessage {
  const _ChatMessage({required this.id, required this.type, required this.content, final  Map<String, dynamic>? metadata, @JsonKey(name: 'tool_name') this.toolName, @JsonKey(name: 'tool_input') final  Map<String, dynamic>? toolInput, @JsonKey(name: 'tool_call_id') this.toolCallId, @JsonKey(name: 'is_tool_error') this.isToolError}): _metadata = metadata,_toolInput = toolInput,super._();
  factory _ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);

@override final  String id;
@override final  MessageType type;
@override final  String content;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

// Tool call specific fields
@override@JsonKey(name: 'tool_name') final  String? toolName;
 final  Map<String, dynamic>? _toolInput;
@override@JsonKey(name: 'tool_input') Map<String, dynamic>? get toolInput {
  final value = _toolInput;
  if (value == null) return null;
  if (_toolInput is EqualUnmodifiableMapView) return _toolInput;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey(name: 'tool_call_id') final  String? toolCallId;
@override@JsonKey(name: 'is_tool_error') final  bool? isToolError;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessageCopyWith<_ChatMessage> get copyWith => __$ChatMessageCopyWithImpl<_ChatMessage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatMessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessage&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.content, content) || other.content == content)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.toolName, toolName) || other.toolName == toolName)&&const DeepCollectionEquality().equals(other._toolInput, _toolInput)&&(identical(other.toolCallId, toolCallId) || other.toolCallId == toolCallId)&&(identical(other.isToolError, isToolError) || other.isToolError == isToolError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,content,const DeepCollectionEquality().hash(_metadata),toolName,const DeepCollectionEquality().hash(_toolInput),toolCallId,isToolError);

@override
String toString() {
  return 'ChatMessage(id: $id, type: $type, content: $content, metadata: $metadata, toolName: $toolName, toolInput: $toolInput, toolCallId: $toolCallId, isToolError: $isToolError)';
}


}

/// @nodoc
abstract mixin class _$ChatMessageCopyWith<$Res> implements $ChatMessageCopyWith<$Res> {
  factory _$ChatMessageCopyWith(_ChatMessage value, $Res Function(_ChatMessage) _then) = __$ChatMessageCopyWithImpl;
@override @useResult
$Res call({
 String id, MessageType type, String content, Map<String, dynamic>? metadata,@JsonKey(name: 'tool_name') String? toolName,@JsonKey(name: 'tool_input') Map<String, dynamic>? toolInput,@JsonKey(name: 'tool_call_id') String? toolCallId,@JsonKey(name: 'is_tool_error') bool? isToolError
});




}
/// @nodoc
class __$ChatMessageCopyWithImpl<$Res>
    implements _$ChatMessageCopyWith<$Res> {
  __$ChatMessageCopyWithImpl(this._self, this._then);

  final _ChatMessage _self;
  final $Res Function(_ChatMessage) _then;

/// Create a copy of ChatMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? content = null,Object? metadata = freezed,Object? toolName = freezed,Object? toolInput = freezed,Object? toolCallId = freezed,Object? isToolError = freezed,}) {
  return _then(_ChatMessage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MessageType,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,toolName: freezed == toolName ? _self.toolName : toolName // ignore: cast_nullable_to_non_nullable
as String?,toolInput: freezed == toolInput ? _self._toolInput : toolInput // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,toolCallId: freezed == toolCallId ? _self.toolCallId : toolCallId // ignore: cast_nullable_to_non_nullable
as String?,isToolError: freezed == isToolError ? _self.isToolError : isToolError // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
