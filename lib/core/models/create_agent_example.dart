import '../models/create_agent_request.dart';
import '../models/llm_model.dart';
import '../models/embedding_model.dart';

/// Example usage of CreateAgentRequest for BYOK and non-BYOK modes

void example() {
  // ============================================
  // Example 1: Non-BYOK Mode (Simple Format)
  // ============================================

  // Select models from base providers
  final baseLLMModel = LLMModel(
    handle: 'llm-1',
    name: 'gpt-4o',
    displayName: 'GPT-4o',
    providerType: 'llm',
    providerName: 'openai',
    model: 'gpt-4o-2024-08-06',
    modelEndpointType: 'openai',
    modelEndpoint: 'https://api.openai.com/v1',
    providerCategory: 'base', // ← base = non-BYOK
    modelType: 'llm',
    contextWindow: 128000,
    putInnerThoughtsInKwargs: false,
    temperature: 0.7,
    maxTokens: 4096,
  );

  final baseEmbeddingModel = EmbeddingModel(
    handle: 'emb-1',
    name: 'text-embedding-3-small',
    displayName: 'Text Embedding 3 Small',
    providerName: 'openai',
    model: 'text-embedding-3-small',
    modelEndpointType: 'openai',
    embeddingEndpoint: 'https://api.openai.com/v1',
    dimension: 1536,
  );

  // Create request in non-BYOK mode
  final nonBYOKRequest = CreateAgentRequest(
    name: 'my-agent',
    description: 'A helpful assistant',
    llmModel: baseLLMModel,
    embeddingModel: baseEmbeddingModel,
    systemPrompt: 'You are a helpful assistant.',
  );

  // Check mode
  print('Is BYOK: ${nonBYOKRequest.isBYOK}'); // false

  // Convert to JSON (simple format)
  print(nonBYOKRequest.toJson());
  // Output:
  // {
  //   "name": "my-agent",
  //   "description": "A helpful assistant",
  //   "model": "openai/gpt-4o-2024-08-06",
  //   "embedding": "openai/text-embedding-3-small",
  //   "system_prompt": "You are a helpful assistant."
  // }

  // ============================================
  // Example 2: BYOK Mode (Full Config Format)
  // ============================================

  // Select models from BYOK providers
  final byokLLMModel = LLMModel(
    handle: 'llm-2',
    name: 'gpt-4o',
    displayName: 'GPT-4o (Custom)',
    providerType: 'llm',
    providerName: 'openai',
    model: 'gpt-4o-2024-08-06',
    modelEndpointType: 'openai',
    modelEndpoint: 'https://custom.openai.proxy/v1',
    providerCategory: 'byok', // ← byok = user-created provider
    modelType: 'llm',
    contextWindow: 128000,
    putInnerThoughtsInKwargs: false,
    temperature: 0.7,
    maxTokens: 4096,
  );

  final byokEmbeddingModel = EmbeddingModel(
    handle: 'emb-2',
    name: 'text-embedding-3-small',
    displayName: 'Text Embedding 3 Small (Custom)',
    providerName: 'openai',
    model: 'text-embedding-3-small',
    modelEndpointType: 'openai',
    embeddingEndpoint: 'https://custom.openai.proxy/v1',
    dimension: 1536,
  );

  // Create request in BYOK mode
  final byokRequest = CreateAgentRequest(
    name: 'my-custom-agent',
    description: 'A custom agent with BYOK provider',
    llmModel: byokLLMModel,
    embeddingModel: byokEmbeddingModel,
    systemPrompt: 'You are a helpful assistant with custom configuration.',
  );

  // Check mode
  print('Is BYOK: ${byokRequest.isBYOK}'); // true

  // Convert to JSON (full config format)
  print(byokRequest.toJson());
  // Output:
  // {
  //   "name": "my-custom-agent",
  //   "description": "A custom agent with BYOK provider",
  //   "llm_config": {
  //     "config": {
  //       "model": "gpt-4o-2024-08-06",
  //       "provider": "openai",
  //       "model_endpoint_type": "openai"
  //     }
  //   },
  //   "embedding_config": {
  //     "config": {
  //       "model": "text-embedding-3-small",
  //       "provider": "openai",
  //       "model_endpoint_type": "openai"
  //     }
  //   },
  //   "system_prompt": "You are a helpful assistant with custom configuration."
  // }
}
