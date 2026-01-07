import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/api_client.dart';
import '../models/agent.dart';

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
    // TODO: Parse JSON response
    return Agent(id: id, name: 'Agent Name', description: 'Agent Description');
  } else {
    throw Exception('Failed to load agent: ${response.statusCode}');
  }
}
