import 'dart:async';
import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/api_client.dart';
import '../models/chat_message.dart';
import '../utils/chat_storage.dart';
import 'api_providers.dart';

part 'chat_providers.g.dart';

/// Chat state for a specific agent
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isStreaming;
  final bool canAbort;
  final String? error;
  final Map<String, dynamic>? usage;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isStreaming = false,
    this.canAbort = false,
    this.error,
    this.usage,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isStreaming,
    bool? canAbort,
    String? error,
    Map<String, dynamic>? usage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isStreaming: isStreaming ?? this.isStreaming,
      canAbort: canAbort ?? this.canAbort,
      error: error,
      usage: usage ?? this.usage,
    );
  }
}

/// Chat state holder using Notifier for Riverpod 3.x
@riverpod
class ChatStateHolder extends _$ChatStateHolder {
  late ApiClient _client;
  late String _agentId;
  StreamSubscription<String>? _streamSubscription;

  @override
  ChatState build(String agentId) {
    _client = ref.watch(apiClientProvider);
    _agentId = agentId;
    ref.onDispose(() {
      _streamSubscription?.cancel();
    });

    // Load saved messages on build
    _loadMessages();

    return const ChatState();
  }

  /// Abort the current streaming operation
  Future<void> abortMessage() async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;

    final abortMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.status,
      content: 'Operation stopped',
    );

    state = state.copyWith(
      messages: [...state.messages, abortMessage],
      isStreaming: false,
      canAbort: false,
    );

    await _saveMessages();
  }

  /// Send a message and stream the response
  Future<void> sendMessage(String content) async {
    // Add user message immediately
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.user,
      content: content,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isStreaming: true,
      canAbort: true,
      error: null,
    );

    try {
      // Prepare request
      final requestBody = {
        'messages': [
          {'role': 'user', 'content': content}
        ],
        'stream': true,
        'stream_tokens': false,
        'max_steps': 10,
      };

      print('[ChatController] Sending message to agent $_agentId');
      print('[ChatController] Request: ${jsonEncode(requestBody)}');

      // Start streaming - use /stream endpoint for SSE
      final stream = _client.streamPost(
        '/agents/$_agentId/messages/stream',
        body: requestBody,
      );

      // Create stream subscription for cancellation support
      _streamSubscription = stream.listen(
        (line) {
          if (line.isEmpty) return;

          // SSE format: "data: {...}"
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();
            if (data.isEmpty || data == '[DONE]') return;

            try {
              final json = jsonDecode(data);
              _handleSSEEvent(json);
            } catch (e) {
              print('[ChatController] Failed to parse SSE data: $e');
              print('[ChatController] Data: $data');
            }
          }
        },
        onDone: () {
          print('[ChatController] Stream completed');
          state = state.copyWith(
            isStreaming: false,
            canAbort: false,
          );
          _saveMessages();
        },
        onError: (e) {
          print('[ChatController] Stream error: $e');
          state = state.copyWith(
            isStreaming: false,
            canAbort: false,
            error: e.toString(),
          );
          _saveMessages();
        },
      );

      await _streamSubscription!.asFuture();
    } catch (e) {
      print('[ChatController] Error sending message: $e');
      state = state.copyWith(
        isStreaming: false,
        canAbort: false,
        error: e.toString(),
      );
      await _saveMessages();
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
      case 'error_message':
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
    final messages = [...state.messages];
    final existingIndex = messages.indexWhere((m) => m.id == message.id);

    if (existingIndex >= 0) {
      // Update existing message (streaming)
      messages[existingIndex] = message;
    } else {
      // Add new message
      messages.add(message);
    }

    state = state.copyWith(messages: messages);
  }

  void _handleReasoningMessage(Map<String, dynamic> json) {
    final message = ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.reasoning,
      content: json['reasoning'] ?? '',
      metadata: {'source': json['source']},
    );

    state = state.copyWith(messages: [...state.messages, message]);
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

    state = state.copyWith(messages: [...state.messages, message]);
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

    state = state.copyWith(messages: [...state.messages, message]);
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

    state = state.copyWith(messages: [...state.messages, message]);
  }

  void _handleUsageStatistics(Map<String, dynamic> json) {
    state = state.copyWith(usage: json['usage']);
  }

  void _handleErrorMessage(Map<String, dynamic> json) {
    // Extract error from various possible formats
    String errorMessage = 'Unknown error';

    if (json.containsKey('error')) {
      final error = json['error'];
      if (error is Map) {
        errorMessage = error['detail'] ?? error['message'] ?? error['type'] ?? 'Unknown error';
      } else if (error is String) {
        errorMessage = error;
      }
    } else if (json.containsKey('message')) {
      errorMessage = json['message'];
    }

    print('[ChatController] Error message: $errorMessage');

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.error,
      content: errorMessage,
    );

    state = state.copyWith(
      messages: [...state.messages, message],
      error: errorMessage,
    );
  }

  /// Clear all messages
  void clearMessages() {
    state = const ChatState();
    ChatStorage.clearMessages(_agentId);
  }

  /// Load messages from localStorage
  Future<void> _loadMessages() async {
    try {
      final messages = await ChatStorage.loadMessages(_agentId);
      if (messages.isNotEmpty) {
        state = state.copyWith(messages: messages);
        print('[ChatController] Loaded ${messages.length} saved messages');
      }
    } catch (e) {
      print('[ChatController] Error loading messages: $e');
    }
  }

  /// Save messages to localStorage
  Future<void> _saveMessages() async {
    try {
      await ChatStorage.saveMessages(_agentId, state.messages);
    } catch (e) {
      print('[ChatController] Error saving messages: $e');
    }
  }
}
