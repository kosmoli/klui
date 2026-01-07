/// Simple Agent model (without Freezed due to Web compilation issues)
class Agent {
  final String id;
  final String name;
  final String? description;
  final String? agentType;
  final DateTime? createdAt;
  final DateTime? modifiedAt;
  final Map<String, dynamic>? config;
  final List<String>? tools;
  final String? systemPrompt;

  const Agent({
    required this.id,
    required this.name,
    this.description,
    this.agentType,
    this.createdAt,
    this.modifiedAt,
    this.config,
    this.tools,
    this.systemPrompt,
  });

  /// Create Agent from JSON
  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      agentType: json['agent_type'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      modifiedAt: json['modified_at'] != null
          ? DateTime.parse(json['modified_at'] as String)
          : null,
      config: json['config'] as Map<String, dynamic>?,
      tools: json['tools'] != null
          ? List<String>.from(json['tools'] as List)
          : null,
      systemPrompt: json['system_prompt'] as String?,
    );
  }

  /// Convert Agent to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (agentType != null) 'agent_type': agentType,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (modifiedAt != null) 'modified_at': modifiedAt!.toIso8601String(),
      if (config != null) 'config': config,
      if (tools != null) 'tools': tools,
      if (systemPrompt != null) 'system_prompt': systemPrompt,
    };
  }

  /// Copy with method
  Agent copyWith({
    String? id,
    String? name,
    String? description,
    String? agentType,
    DateTime? createdAt,
    DateTime? modifiedAt,
    Map<String, dynamic>? config,
    List<String>? tools,
    String? systemPrompt,
  }) {
    return Agent(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      agentType: agentType ?? this.agentType,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      config: config ?? this.config,
      tools: tools ?? this.tools,
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
