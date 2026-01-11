/// Simple Agent model (without Freezed due to Web compilation issues)
class Agent {
  final String id;
  final String name;
  final String? description;
  final String? model;
  final String? embedding;
  final String? agentType;
  final DateTime? createdAt;
  final DateTime? modifiedAt;
  final Map<String, dynamic>? config;
  final Map<String, dynamic>? llmConfig;
  final Map<String, dynamic>? embeddingConfig;
  final Map<String, dynamic>? modelSettings;
  final List<String>? tools;
  final List<String>? tags;
  final Map<String, dynamic>? metadata;
  final String? systemPrompt;

  const Agent({
    required this.id,
    required this.name,
    this.description,
    this.model,
    this.embedding,
    this.agentType,
    this.createdAt,
    this.modifiedAt,
    this.config,
    this.llmConfig,
    this.embeddingConfig,
    this.modelSettings,
    this.tools,
    this.tags,
    this.metadata,
    this.systemPrompt,
  });

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

  /// Convert Agent to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (model != null) 'model': model,
      if (agentType != null) 'agent_type': agentType,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (modifiedAt != null) 'modified_at': modifiedAt!.toIso8601String(),
      if (config != null) 'config': config,
      if (llmConfig != null) 'llm_config': llmConfig,
      if (embeddingConfig != null) 'embedding_config': embeddingConfig,
      if (tools != null) 'tools': tools,
      if (systemPrompt != null) 'system_prompt': systemPrompt,
    };
  }

  /// Copy with method
  Agent copyWith({
    String? id,
    String? name,
    String? description,
    String? model,
    String? embedding,
    String? agentType,
    DateTime? createdAt,
    DateTime? modifiedAt,
    Map<String, dynamic>? config,
    Map<String, dynamic>? llmConfig,
    Map<String, dynamic>? embeddingConfig,
    Map<String, dynamic>? modelSettings,
    List<String>? tools,
    List<String>? tags,
    Map<String, dynamic>? metadata,
    String? systemPrompt,
  }) {
    return Agent(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      model: model ?? this.model,
      embedding: embedding ?? this.embedding,
      agentType: agentType ?? this.agentType,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      config: config ?? this.config,
      llmConfig: llmConfig ?? this.llmConfig,
      embeddingConfig: embeddingConfig ?? this.embeddingConfig,
      modelSettings: modelSettings ?? this.modelSettings,
      tools: tools ?? this.tools,
      tags: tags ?? this.tags,
      metadata: metadata ?? this.metadata,
      systemPrompt: systemPrompt ?? this.systemPrompt,
    );
  }

  @override
  String toString() {
    return 'Agent(id: $id, name: $name, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Agent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
