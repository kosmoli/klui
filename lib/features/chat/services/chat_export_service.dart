import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:klui/core/models/chat_message.dart';
import 'package:klui/core/models/agent.dart';

/// Service for exporting chat conversations
class ChatExportService {
  /// Export chat messages to Markdown format
  static String toMarkdown({
    required List<ChatMessage> messages,
    required Agent agent,
    String? customTitle,
  }) {
    final buffer = StringBuffer();
    final title = customTitle ?? agent.name ?? 'Chat Export';
    final timestamp = DateTime.now().toIso8601String();

    // Header
    buffer.writeln('# $title\n');
    buffer.writeln('**Agent:** ${agent.name ?? "Unknown"}');
    buffer.writeln('**Model:** ${agent.model?.model ?? "Unknown"}');
    buffer.writeln('**Exported:** $timestamp\n');
    buffer.writeln('---\n');

    // Messages
    for (final message in messages) {
      // Skip system/internal messages
      if (message.type == MessageType.status ||
          message.type == MessageType.toolReturn) {
        continue;
      }

      final role = _getRoleName(message.type);
      final timestampMsg = message.createdAt != null
          ? _formatTimestamp(message.createdAt!)
          : '';

      buffer.writeln('### $role ${timestampMsg.isNotEmpty ? "• $timestampMsg" : ""}\n');

      // Handle different message types
      switch (message.type) {
        case MessageType.user:
        case MessageType.assistant:
        case MessageType.error:
          buffer.writeln(message.content.trim());
          buffer.writeln('');
          break;

        case MessageType.toolCall:
          buffer.writeln('**Tool:** ${message.toolName ?? "Unknown"}');
          if (message.toolInput != null) {
            buffer.writeln('**Input:**');
            buffer.writeln('```json');
            buffer.writeln(const JsonEncoder.withIndent('  ').convert(message.toolInput));
            buffer.writeln('```');
          }
          buffer.writeln('');
          break;

        case MessageType.reasoning:
          buffer.writeln('**Reasoning:**');
          buffer.writeln(message.content.trim());
          buffer.writeln('');
          break;

        case MessageType.toolReturn:
        case MessageType.status:
          break;
      }
    }

    return buffer.toString();
  }

  /// Export chat messages to JSON format
  static String toJson({
    required List<ChatMessage> messages,
    required Agent agent,
    String? customTitle,
  }) {
    final exportData = {
      'version': '1.0',
      'title': customTitle ?? agent.name ?? 'Chat Export',
      'exportedAt': DateTime.now().toIso8601String(),
      'agent': {
        'id': agent.id,
        'name': agent.name,
        'model': agent.model?.model,
        'description': agent.description,
      },
      'messages': messages
          .where((m) => m.type != MessageType.status)
          .map((m) => {
                'id': m.id,
                'type': m.type.name,
                'content': m.content,
                'toolName': m.toolName,
                'toolInput': m.toolInput,
                'createdAt': m.createdAt,
                'isEdited': m.isEdited ?? false,
                'editedAt': m.editedAt,
              })
          .toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  /// Download content as a file (Web)
  static void downloadFile({
    required String content,
    required String filename,
    required String mimeType,
  }) {
    // For Web, use anchor download
    final blob = html.Blob([content], 'type': mimeType);
    final url = html.Url.createObjectUrl(blob);
    final anchor = html.AnchorElement()
      ..href = url
      ..download = filename
      ..style.display = 'none';
    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }

  /// Get human-readable role name
  static String _getRoleName(MessageType type) {
    switch (type) {
      case MessageType.user:
        return 'User';
      case MessageType.assistant:
        return 'Assistant';
      case MessageType.toolCall:
        return 'Tool Call';
      case MessageType.toolReturn:
        return 'Tool Result';
      case MessageType.reasoning:
        return 'Reasoning';
      case MessageType.error:
        return 'Error';
      case MessageType.status:
        return 'System';
    }
  }

  /// Format timestamp for display
  static String _formatTimestamp(int milliseconds) {
    final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}:'
        '${date.second.toString().padLeft(2, '0')}';
  }

  /// Generate filename for export
  static String generateFilename({
    required String agentName,
    required String extension,
  }) {
    final date = DateTime.now();
    final dateStr = '${date.year}${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}_${date.hour.toString().padLeft(2, '0')}'
        '${date.minute.toString().padLeft(2, '0')}';
    final sanitizedName = agentName.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
    return '${sanitizedName}_$dateStr$extension';
  }
}

// HTML imports for Web functionality
import 'dart:html' as html;
