import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';

/// Storage service for chat message persistence
/// Uses SharedPreferences (localStorage on web)
class ChatStorage {
  static const String _keyPrefix = 'chat_messages_';

  /// Save messages for a specific agent
  static Future<void> saveMessages(String agentId, List<ChatMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$agentId';

      // Convert messages to JSON
      final List<Map<String, dynamic>> jsonList = messages.map((m) => m.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await prefs.setString(key, jsonString);
      print('[ChatStorage] Saved ${messages.length} messages for agent $agentId');
    } catch (e) {
      print('[ChatStorage] Error saving messages: $e');
    }
  }

  /// Load messages for a specific agent
  static Future<List<ChatMessage>> loadMessages(String agentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$agentId';
      final jsonString = prefs.getString(key);

      if (jsonString == null) {
        print('[ChatStorage] No saved messages for agent $agentId');
        return [];
      }

      final List<dynamic> decoded = jsonDecode(jsonString);
      final messages = decoded.map((json) => ChatMessage.fromJson(json as Map<String, dynamic>)).toList();

      print('[ChatStorage] Loaded ${messages.length} messages for agent $agentId');
      return messages;
    } catch (e) {
      print('[ChatStorage] Error loading messages: $e');
      return [];
    }
  }

  /// Clear messages for a specific agent
  static Future<void> clearMessages(String agentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyPrefix$agentId';
      await prefs.remove(key);
      print('[ChatStorage] Cleared messages for agent $agentId');
    } catch (e) {
      print('[ChatStorage] Error clearing messages: $e');
    }
  }

  /// Clear all chat messages across all agents
  static Future<void> clearAllMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix));

      for (final key in keys) {
        await prefs.remove(key);
      }

      print('[ChatStorage] Cleared messages for ${keys.length} agents');
    } catch (e) {
      print('[ChatStorage] Error clearing all messages: $e');
    }
  }
}
