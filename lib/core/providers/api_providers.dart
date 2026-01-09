import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/api_client.dart';
import '../models/agent.dart';
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
