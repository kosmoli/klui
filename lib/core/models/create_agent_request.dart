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

  /// Get the correct handle for LLM model based on provider type and base URL
  ///
  /// Letta backend has special handling for OpenAI-compatible APIs:
  /// - If provider_type is "openai" and base_url is NOT "https://api.openai.com/v1"
  ///   → Must use "openai-proxy" as handle prefix
  /// - Otherwise, use the provider's normal handle
  ///
  /// See: /root/work/letta/letta/schemas/providers/openai.py:153-157
  String _getCorrectLLMHandle() {
    // OpenAI-compatible API with custom base URL
    if (llmModel.providerType == 'openai' &&
        llmModel.modelEndpoint != 'https://api.openai.com/v1') {
      // Extract model name from handle (format: "provider-name/model-name")
      final modelName = llmModel.handle.contains('/')
          ? llmModel.handle.split('/').last
          : llmModel.model;
      return 'openai-proxy/$modelName';
    }

    // For all other cases, use the original handle
    return llmModel.handle;
  }

  /// Get the correct handle for embedding model based on provider type and base URL
  String _getCorrectEmbeddingHandle() {
    // OpenAI-compatible API with custom base URL
    if (embeddingModel.providerType == 'openai' &&
        embeddingModel.modelEndpoint != 'https://api.openai.com/v1') {
      // Extract model name from handle
      final modelName = embeddingModel.handle.contains('/')
          ? embeddingModel.handle.split('/').last
          : embeddingModel.model;
      return 'openai-proxy/$modelName';
    }

    // For all other cases, use the original handle
    return embeddingModel.handle;
  }

  /// Convert to simple format (non-BYOK mode)
  /// Example: {"name": "...", "model": "openai-proxy/claude-sonnet-4-5-20250929", "embedding": "openai-proxy/text-embedding-3-small", "system": "..."}
  Map<String, dynamic> toSimpleJson() {
    final json = <String, dynamic>{
      'name': name,
      'model': _getCorrectLLMHandle(),  // Use transformed handle for OpenAI-compatible APIs
      'embedding': _getCorrectEmbeddingHandle(),  // Use transformed handle for OpenAI-compatible APIs
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
