// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => _ChatMessage(
  id: json['id'] as String,
  type: $enumDecode(_$MessageTypeEnumMap, json['type']),
  content: json['content'] as String,
  metadata: json['metadata'] as Map<String, dynamic>?,
  toolName: json['tool_name'] as String?,
  toolInput: json['tool_input'] as Map<String, dynamic>?,
  toolCallId: json['tool_call_id'] as String?,
  isToolError: json['is_tool_error'] as bool?,
);

Map<String, dynamic> _$ChatMessageToJson(_ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'content': instance.content,
      'metadata': instance.metadata,
      'tool_name': instance.toolName,
      'tool_input': instance.toolInput,
      'tool_call_id': instance.toolCallId,
      'is_tool_error': instance.isToolError,
    };

const _$MessageTypeEnumMap = {
  MessageType.user: 'user',
  MessageType.assistant: 'assistant',
  MessageType.toolCall: 'toolCall',
  MessageType.toolReturn: 'toolReturn',
  MessageType.reasoning: 'reasoning',
  MessageType.error: 'error',
  MessageType.status: 'status',
};
