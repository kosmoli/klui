import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/api_client.dart';
import '../models/agent.dart';
import '../models/create_agent_request.dart';
import '../models/create_provider_request.dart';
import '../models/provider.dart' as models;
import '../models/llm_model.dart';
import '../models/embedding_model.dart';

part 'api_providers.g.dart';

/// Provider for API Client
@riverpod
ApiClient apiClient(Ref ref) {
  final client = ApiClient();
  ref.onDispose(() => client.close());
  return client;
}

/// Provider for Agent List
@riverpod
Future<List<Agent>> agentList(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/agents/');

  if (response.statusCode == 200) {
    // Parse JSON response
    final List<dynamic> jsonData = [];
    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        jsonData.addAll(decoded);
      }
    } catch (e) {
      // If parsing fails, return empty list
      return [];
    }

    return jsonData
        .map((json) => Agent.fromJson(json as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception('Failed to load agents: ${response.statusCode}');
  }
}

/// Provider for single Agent
@riverpod
Future<Agent> agent(Ref ref, String id) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/agents/$id');

  if (response.statusCode == 200) {
    // Parse JSON response
    final dynamic decoded = jsonDecode(response.body);
    return Agent.fromJson(decoded as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load agent: ${response.statusCode}');
  }
}

/// Provider for deleting an Agent
@riverpod
Future<void> deleteAgent(Ref ref, String id) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.delete('/agents/$id');

  if (response.statusCode != 200 && response.statusCode != 204) {
    throw Exception('Failed to delete agent: ${response.statusCode}');
  }
}

/// Provider for Provider List
@riverpod
Future<List<models.ProviderConfig>> providerList(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/providers/');

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = [];
    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        jsonData.addAll(decoded);
      }
    } catch (e) {
      return [];
    }

    return jsonData
        .map((json) => models.ProviderConfig.fromJson(json as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception('Failed to load providers: ${response.statusCode}');
  }
}

/// Provider for single Provider
@riverpod
Future<models.ProviderConfig> provider(Ref ref, String id) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/providers/$id');

  if (response.statusCode == 200) {
    final dynamic decoded = jsonDecode(response.body);
    return models.ProviderConfig.fromJson(decoded as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load provider: ${response.statusCode}');
  }
}

/// Provider for LLM Models List (all models)
@riverpod
Future<List<LLMModel>> llmModelList(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/models/');

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = [];
    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        jsonData.addAll(decoded);
      }
    } catch (e) {
      return [];
    }

    return jsonData
        .map((json) => LLMModel.fromJson(json as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception('Failed to load LLM models: ${response.statusCode}');
  }
}

/// Provider for LLM Models List filtered by provider name
/// This provider dynamically loads models for a specific provider
@riverpod
Future<List<LLMModel>> llmModelListByProvider(Ref ref, String providerName) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get(
    '/models/',
    queryParameters: {'provider_name': providerName},
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = [];
    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        jsonData.addAll(decoded);
      }
    } catch (e) {
      return [];
    }

    return jsonData
        .map((json) => LLMModel.fromJson(json as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception('Failed to load LLM models for provider $providerName: ${response.statusCode}');
  }
}

/// Provider for Embedding Models List
@riverpod
Future<List<EmbeddingModel>> embeddingModelList(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/models/embedding');

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = [];
    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        jsonData.addAll(decoded);
      }
    } catch (e) {
      return [];
    }

    return jsonData
        .map((json) => EmbeddingModel.fromJson(json as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception('Failed to load embedding models: ${response.statusCode}');
  }
}

/// Provider for Base Category LLM Models (memory providers, non-BYOK)
/// These are the default providers created from environment variables
@riverpod
Future<List<LLMModel>> baseLLMModelList(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get(
    '/models/',
    queryParameters: {'provider_category': 'base'},
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = [];
    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        jsonData.addAll(decoded);
      }
    } catch (e) {
      return [];
    }

    return jsonData
        .map((json) => LLMModel.fromJson(json as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception('Failed to load base LLM models: ${response.statusCode}');
  }
}

/// Provider for BYOK Category LLM Models (database providers, user-created)
/// These are custom providers created via API
@riverpod
Future<List<LLMModel>> byokLLMModelList(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get(
    '/models/',
    queryParameters: {'provider_category': 'byok'},
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = [];
    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is List) {
        jsonData.addAll(decoded);
      }
    } catch (e) {
      return [];
    }

    return jsonData
        .map((json) => LLMModel.fromJson(json as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception('Failed to load BYOK LLM models: ${response.statusCode}');
  }
}

/// Provider for creating an Agent
/// Automatically uses simple format for non-BYOK mode
/// and full config format for BYOK mode
@riverpod
Future<Agent> createAgent(Ref ref, CreateAgentRequest request) async {
  final client = ref.watch(apiClientProvider);

  // Convert request to JSON based on BYOK mode
  final requestBody = request.toJson();

  // Debug logging
  print('[createAgent] BYOK mode: ${request.isBYOK}');
  print('[createAgent] Request body: ${jsonEncode(requestBody)}');

  final response = await client.post(
    '/agents/',
    body: jsonEncode(requestBody),
  );

  print('[createAgent] Response status: ${response.statusCode}');
  print('[createAgent] Response body: ${response.body}');

  if (response.statusCode == 200 || response.statusCode == 201) {
    final dynamic decoded = jsonDecode(response.body);
    return Agent.fromJson(decoded as Map<String, dynamic>);
  } else {
    // Parse error response for more details
    String errorMessage = 'Failed to create agent: ${response.statusCode}';
    try {
      final errorData = jsonDecode(response.body);
      if (errorData is Map && errorData.containsKey('detail')) {
        errorMessage = 'Error: ${errorData['detail']}';
      }
    } catch (_) {
      // If parsing fails, use default message
    }
    throw Exception(errorMessage);
  }
}

/// Provider for creating a Provider
@riverpod
Future<models.ProviderConfig> createProvider(
  Ref ref,
  CreateProviderRequest request,
) async {
  final client = ref.watch(apiClientProvider);

  final requestBody = request.toJson();

  // Debug logging
  print('[createProvider] Request body: ${jsonEncode(requestBody)}');

  final response = await client.post(
    '/providers/',
    body: jsonEncode(requestBody),
  );

  print('[createProvider] Response status: ${response.statusCode}');
  print('[createProvider] Response body: ${response.body}');

  if (response.statusCode == 200 || response.statusCode == 201) {
    final dynamic decoded = jsonDecode(response.body);
    return models.ProviderConfig.fromJson(decoded as Map<String, dynamic>);
  } else {
    // Parse error response for more details
    String errorMessage = 'Failed to create provider: ${response.statusCode}';
    try {
      final errorData = jsonDecode(response.body);
      if (errorData is Map && errorData.containsKey('detail')) {
        errorMessage = 'Error: ${errorData['detail']}';
      }
    } catch (_) {
      // If parsing fails, use default message
    }
    throw Exception(errorMessage);
  }
}

/// Provider for deleting a Provider
@riverpod
Future<void> deleteProvider(Ref ref, String id) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.delete('/providers/$id');

  if (response.statusCode != 200 && response.statusCode != 204) {
    String errorMessage = 'Failed to delete provider: ${response.statusCode}';
    try {
      final errorData = jsonDecode(response.body);
      if (errorData is Map && errorData.containsKey('detail')) {
        errorMessage = 'Error: ${errorData['detail']}';
      }
    } catch (_) {
      // If parsing fails, use default message
    }
    throw Exception(errorMessage);
  }
}
