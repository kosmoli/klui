import 'llm_model.dart';

/// Request model for creating an Agent
/// Supports two modes: BYOK (full config) and non-BYOK (simple format)
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

  /// Check if this is a BYOK mode request
  bool get isBYOK => llmModel.providerCategory == 'byok';

  /// Convert to simple format (non-BYOK mode)
  /// Example: {"name": "...", "model": "openai-proxy/claude-sonnet-4-5-20250929", "embedding": "openai-proxy/text-embedding-3-small", "system": "..."}
  Map<String, dynamic> toSimpleJson() {
    final json = <String, dynamic>{
      'name': name,
      'model': llmModel.handle,  // Use handle instead of providerName/model
      'embedding': embeddingModel.handle,  // Use handle instead of providerName/model
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

  /// Convert to full config format (BYOK mode)
  /// Example: {"llm_config": {...}, "embedding_config": {...}}
  /// Note: llm_config and embedding_config are flat structures, not nested under 'config'
  Map<String, dynamic> toBYOKJson() {
    final json = <String, dynamic>{
      'name': name,
      'llm_config': {
        'model': llmModel.model,
        'provider_name': llmModel.providerName,
        'provider_category': llmModel.providerCategory,
        'model_endpoint_type': llmModel.modelEndpointType,
        'context_window': llmModel.contextWindow,
      },
      'embedding_config': {
        'provider_name': embeddingModel.providerName,
        'provider_category': embeddingModel.providerCategory,
        'embedding_endpoint_type': embeddingModel.modelEndpointType,
        'embedding_model': embeddingModel.model,
        'embedding_dim': 1536, // Default embedding dimension
      },
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

  /// Convert to JSON based on mode
  Map<String, dynamic> toJson() {
    return isBYOK ? toBYOKJson() : toSimpleJson();
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
