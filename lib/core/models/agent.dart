import 'package:freezed_annotation/freezed_annotation.dart';

part 'agent.freezed.dart';

/// Agent model
@freezed
abstract class Agent with _$Agent {
  const Agent._();

  const factory Agent({
    required String id,
    required String name,
    String? description,
    String? model,
    String? embedding,
    @JsonKey(name: 'agent_type') String? agentType,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'modified_at') DateTime? modifiedAt,
    Map<String, dynamic>? config,
    @JsonKey(name: 'llm_config') Map<String, dynamic>? llmConfig,
    @JsonKey(name: 'embedding_config') Map<String, dynamic>? embeddingConfig,
    @JsonKey(name: 'model_settings') Map<String, dynamic>? modelSettings,
    List<String>? tools,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'system') String? systemPrompt,
  }) = _Agent;

  /// Create Agent from JSON
  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      model: json['model'] as String?,
      embedding: json['embedding'] as String?,
      agentType: json['agent_type'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      modifiedAt: json['modified_at'] != null
          ? DateTime.parse(json['modified_at'] as String)
          : null,
      config: json['config'] as Map<String, dynamic>?,
      llmConfig: json['llm_config'] as Map<String, dynamic>?,
      embeddingConfig: json['embedding_config'] as Map<String, dynamic>?,
      modelSettings: json['model_settings'] as Map<String, dynamic>?,
      tools: json['tools'] != null
          ? (json['tools'] as List).map((e) {
              // If tool is a string, use it directly
              if (e is String) return e;
              // If tool is an object, extract the name field
              if (e is Map) {
                return (e as Map)['name']?.toString() ?? e.toString();
              }
              // Fallback to toString
              return e.toString();
            }).toList()
          : null,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      systemPrompt: json['system'] as String?,
    );
  }
}
