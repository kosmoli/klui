/// Simple Message model (without Freezed due to Web compilation issues)
class Message {
  final String id;
  final String role;
  final String content;
  final DateTime? createdAt;
  final String? agentId;
  final List<ToolCall>? toolCalls;

  const Message({
    required this.id,
    required this.role,
    required this.content,
    this.createdAt,
    this.agentId,
    this.toolCalls,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      agentId: json['agent_id'] as String?,
      toolCalls: json['tool_calls'] != null
          ? (json['tool_calls'] as List)
                .map((e) => ToolCall.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'content': content,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (agentId != null) 'agent_id': agentId,
      if (toolCalls != null) 'tool_calls': toolCalls,
    };
  }
}

class ToolCall {
  final String id;
  final String name;
  final Map<String, dynamic> arguments;

  const ToolCall({
    required this.id,
    required this.name,
    required this.arguments,
  });

  factory ToolCall.fromJson(Map<String, dynamic> json) {
    return ToolCall(
      id: json['id'] as String,
      name: json['name'] as String,
      arguments: json['arguments'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'arguments': arguments};
  }
}
