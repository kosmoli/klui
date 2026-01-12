import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/api_client.dart';
import '../models/chat_message.dart';
import 'api_providers.dart';

/// Chat state for a specific agent
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isStreaming;
  final String? error;
  final Map<String, dynamic>? usage;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isStreaming = false,
    this.error,
    this.usage,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isStreaming,
    String? error,
    Map<String, dynamic>? usage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
      error: error,
      usage: usage ?? this.usage,
    );
  }
}

/// Chat controller for managing chat state
class ChatController {
  final ApiClient _client;
  final String agentId;
  ChatState _state = const ChatState();

  ChatController(this._client, this.agentId);

  ChatState get state => _state;
  final _stateController = StreamController<ChatState>.broadcast();

  Stream<ChatState> get stateStream => _stateController.stream;

  void _updateState(ChatState newState) {
    _state = newState;
    _stateController.add(_state);
  }

  /// Send a message and stream the response
  Future<void> sendMessage(String content) async {
    // Add user message immediately
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.user,
      content: content,
    );

    _updateState(_state.copyWith(
      messages: [..._state.messages, userMessage],
      isStreaming: true,
      error: null,
    ));

    try {
      // Prepare request
      final requestBody = {
        'messages': [
          {'role': 'user', 'content': content}
        ],
        'streaming': true,
        'stream_tokens': false,
        'max_steps': 10,
      };

      print('[ChatController] Sending message to agent $agentId');
      print('[ChatController] Request: ${jsonEncode(requestBody)}');

      // Start streaming
      final stream = _client.streamPost(
        '/agents/$agentId/messages',
        body: requestBody,
      );

      // Parse SSE stream
      await for (final line in stream) {
        if (line.isEmpty) continue;

        // SSE format: "data: {...}"
        if (line.startsWith('data: ')) {
          final data = line.substring(6).trim();
          if (data.isEmpty || data == '[DONE]') continue;

          try {
            final json = jsonDecode(data);
            _handleSSEEvent(json);
          } catch (e) {
            print('[ChatController] Failed to parse SSE data: $e');
            print('[ChatController] Data: $data');
          }
        }
      }

      // Stream completed
      _updateState(_state.copyWith(isStreaming: false));
    } catch (e) {
      print('[ChatController] Error sending message: $e');
      _updateState(_state.copyWith(
        isStreaming: false,
        error: e.toString(),
      ));
    }
  }

  /// Handle SSE events from the server
  void _handleSSEEvent(Map<String, dynamic> json) {
    final messageType = json['message_type'];
    print('[ChatController] Received event: $messageType');

    switch (messageType) {
      case 'user_message':
        _handleUserMessage(json);
        break;

      case 'assistant_message':
        _handleAssistantMessage(json);
        break;

      case 'reasoning_message':
        _handleReasoningMessage(json);
        break;

      case 'tool_call_message':
        _handleToolCallMessage(json);
        break;

      case 'tool_return_message':
        _handleToolReturnMessage(json);
        break;

      case 'approval_request_message':
        _handleApprovalRequestMessage(json);
        break;

      case 'usage_statistics':
        _handleUsageStatistics(json);
        break;

      case 'stop_reason':
        // Stream ending
        print('[ChatController] Stream stopped: ${json['stop_reason']}');
        break;

      case 'ping':
        // Keepalive, ignore
        break;

      case 'error':
        _handleErrorMessage(json);
        break;

      default:
        print('[ChatController] Unknown message type: $messageType');
    }
  }

  void _handleUserMessage(Map<String, dynamic> json) {
    // User messages are already added, so we can skip or update
    print('[ChatController] User message: ${json['content']}');
  }

  void _handleAssistantMessage(Map<String, dynamic> json) {
    final message = ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.assistant,
      content: json['content'] ?? '',
    );

    // Add or update message
    final messages = [..._state.messages];
    final existingIndex = messages.indexWhere((m) => m.id == message.id);

    if (existingIndex >= 0) {
      // Update existing message (streaming)
      messages[existingIndex] = message;
    } else {
      // Add new message
      messages.add(message);
    }

    _updateState(_state.copyWith(messages: messages));
  }

  void _handleReasoningMessage(Map<String, dynamic> json) {
    final message = ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.reasoning,
      content: json['reasoning'] ?? '',
      metadata: {'source': json['source']},
    );

    _updateState(_state.copyWith(messages: [..._state.messages, message]));
  }

  void _handleToolCallMessage(Map<String, dynamic> json) {
    final toolCall = json['tool_call'];
    if (toolCall == null) return;

    final message = ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.toolCall,
      content: '',
      toolName: toolCall['name'],
      toolInput: toolCall['arguments'],
      toolCallId: toolCall['tool_call_id'],
      metadata: {'phase': 'ready'},
    );

    _updateState(_state.copyWith(messages: [..._state.messages, message]));
  }

  void _handleToolReturnMessage(Map<String, dynamic> json) {
    final message = ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.toolReturn,
      content: json['tool_return'] ?? '',
      toolName: json['tool_call_id'],
      metadata: {
        'phase': 'finished',
        'isOk': json['status'] == 'success',
      },
    );

    _updateState(_state.copyWith(messages: [..._state.messages, message]));
  }

  void _handleApprovalRequestMessage(Map<String, dynamic> json) {
    final toolCall = json['tool_call'];
    if (toolCall == null) return;

    final message = ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.toolCall,
      content: '',
      toolName: toolCall['name'],
      toolInput: toolCall['arguments'],
      toolCallId: toolCall['tool_call_id'],
      metadata: {'phase': 'ready'},
    );

    _updateState(_state.copyWith(messages: [..._state.messages, message]));
  }

  void _handleUsageStatistics(Map<String, dynamic> json) {
    _updateState(_state.copyWith(usage: json['usage']));
  }

  void _handleErrorMessage(Map<String, dynamic> json) {
    final error = json['error'];
    final errorMessage = error is Map
        ? error['detail'] ?? error['type'] ?? 'Unknown error'
        : 'Unknown error';

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.error,
      content: errorMessage,
    );

    _updateState(_state.copyWith(
      messages: [..._state.messages, message],
      error: errorMessage,
    ));
  }

  /// Clear all messages
  void clearMessages() {
    _updateState(const ChatState());
  }

  void dispose() {
    _stateController.close();
  }
}

/// Provider for chat controller
final chatControllerProvider = Provider.family<ChatController, String>(
  (ref, agentId) {
    final client = ref.watch(apiClientProvider);
    final controller = ChatController(client, agentId);
    ref.onDispose(() {
      controller.dispose();
    });
    return controller;
  },
);

/// Provider for chat state (convenience)
final chatStateProvider = Provider.family<ChatState, String>(
  (ref, agentId) {
    return ref.watch(chatControllerProvider(agentId)).state;
  },
);

/// Provider for messages list (convenience)
final chatMessagesProvider = Provider.family<List<ChatMessage>, String>(
  (ref, agentId) {
    return ref.watch(chatStateProvider(agentId)).messages;
  },
);

/// Provider for loading state
final chatIsLoadingProvider = Provider.family<bool, String>(
  (ref, agentId) {
    return ref.watch(chatStateProvider(agentId)).isLoading;
  },
);

/// Provider for streaming state
final chatIsStreamingProvider = Provider.family<bool, String>(
  (ref, agentId) {
    return ref.watch(chatStateProvider(agentId)).isStreaming;
  },
);
