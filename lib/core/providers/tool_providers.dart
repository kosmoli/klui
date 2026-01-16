import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/api_client.dart';
import '../models/tool.dart';
import 'api_providers.dart';

part 'tool_providers.g.dart';

/// Provider for Agent's Tools
@riverpod
Future<List<Tool>> agentTools(Ref ref, String agentId) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/agents/$agentId/tools');

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
        .map((json) => Tool.fromJson(json as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception('Failed to load tools: ${response.statusCode}');
  }
}

/// Provider for All Available Tools
@riverpod
Future<List<Tool>> allTools(Ref ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/tools/');

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
        .map((json) => Tool.fromJson(json as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception('Failed to load tools: ${response.statusCode}');
  }
}

/// Provider for Attaching Tool to Agent
@riverpod
Future<void> attachTool(Ref ref, {required String agentId, required String toolId}) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.patch(
    '/agents/$agentId/tools/attach/$toolId',
    body: '{}',
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to attach tool: ${response.statusCode}');
  }
}

/// Provider for Detaching Tool from Agent
@riverpod
Future<void> detachTool(Ref ref, {required String agentId, required String toolId}) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.patch(
    '/agents/$agentId/tools/detach/$toolId',
    body: '{}',
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to detach tool: ${response.statusCode}');
  }
}
