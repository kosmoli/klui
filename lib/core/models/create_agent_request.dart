import 'llm_model.dart';

/// Request model for creating an Agent
/// In Memos, models have their handles in the correct format already
class CreateAgentRequest {
  final String name;
  final String? description;
  final LLMModel llmModel;
  final LLMModel embeddingModel;
  final List<String>? tools;
  final String? systemPrompt;

  const CreateAgentRequest({
    required this.name,
    this.description,
    required this.llmModel,
    required this.embeddingModel,
    this.tools,
    this.systemPrompt,
  });

  /// Convert to simple format
  /// Example: {"name": "...", "model": "provider-name/model-name", "embedding": "provider-name/embedding-model", "system": "..."}
  ///
  /// In Memos, the model handle is already in the correct format (e.g., "test-openai/gpt-4o")
  /// No need for special handling like "openai-proxy" prefix
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'model': llmModel.handle,
      'embedding': embeddingModel.handle,
    };

    if (description != null) {
      json['description'] = description;
    }
    if (tools != null && tools!.isNotEmpty) {
      json['tools'] = tools;
    }
    if (systemPrompt != null) {
      json['system'] = systemPrompt;
    }

    return json;
  }

  /// Copy with method
  CreateAgentRequest copyWith({
    String? name,
    String? description,
    LLMModel? llmModel,
    LLMModel? embeddingModel,
    List<String>? tools,
    String? systemPrompt,
  }) {
    return CreateAgentRequest(
      name: name ?? this.name,
      description: description ?? this.description,
      llmModel: llmModel ?? this.llmModel,
      embeddingModel: embeddingModel ?? this.embeddingModel,
      tools: tools ?? this.tools,
      systemPrompt: systemPrompt ?? this.systemPrompt,
    );
  }
}
