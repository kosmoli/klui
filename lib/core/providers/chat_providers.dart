import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/api_client.dart';
import '../models/chat_message.dart';
import '../utils/chat_storage.dart';
import '../utils/logger.dart';
import 'api_providers.dart';

part 'chat_providers.g.dart';

final _log = KluiLogger('ChatController');

/// Simple in-memory storage for selected agent ID
/// This survives navigation between screens while the app is running
String _selectedAgentId = '';

/// Get the current selected agent ID
String getSelectedAgentId() => _selectedAgentId;

/// Set the selected agent ID (called from main.dart on init)
void setSelectedAgentId(String agentId) {
  _selectedAgentId = agentId;
  _log.info('Set selected agent ID: $agentId');
}

/// Initialize selected agent ID from localStorage
/// Returns the saved agent ID, or empty string if none saved
String initSelectedAgentId() {
  try {
    final savedId = html.window.localStorage['selected_agent_id'];
    if (savedId != null && savedId.isNotEmpty) {
      _selectedAgentId = savedId;
      _log.info('Loaded selected agent ID from localStorage: $savedId');
      return savedId;
    }
  } catch (e) {
    _log.warning('Failed to load selected agent ID from localStorage: $e');
  }
  return '';
}

/// Global provider to persist the currently selected agent ID
/// This survives navigation between screens
@riverpod
class SelectedAgentId extends _$SelectedAgentId {
  @override
  String build() {
    return _selectedAgentId;
  }

  void setSelectedAgentId(String agentId) {
    _selectedAgentId = agentId;
    state = agentId;
    _log.info('Selected agent ID: $agentId');

    // Also save to localStorage for persistence across sessions
    try {
      html.window.localStorage['selected_agent_id'] = agentId;
    } catch (e) {
      _log.warning('Failed to save to localStorage: $e');
    }
  }

  void clearSelectedAgentId() {
    _selectedAgentId = '';
    state = '';
    _log.info('Cleared selected agent ID');

    try {
      html.window.localStorage.remove('selected_agent_id');
    } catch (e) {
      _log.warning('Failed to clear from localStorage: $e');
    }
  }
}

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

    _log.debug('ChatStateHolder initialized for agent: $agentId');
    return const ChatState();
  }

  /// Abort the current streaming operation
  Future<void> abortMessage() async {
    _log.info('Aborting message for agent $_agentId');
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
    await _sendMessageWithRetry(content, maxRetries: 3);
  }

  /// Send message with retry logic for transient errors
  Future<void> _sendMessageWithRetry(String content, {required int maxRetries}) async {
    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        await _sendMessageInternal(content);
        return; // Success, exit retry loop
      } catch (e) {
        final isLastAttempt = attempt == maxRetries;
        final isTransient = _isTransientError(e);

        _log.warning('Attempt ${attempt + 1}/${maxRetries + 1} failed: $e');
        _log.debug('Is transient: $isTransient, Last attempt: $isLastAttempt');

        if (isLastAttempt || !isTransient) {
          // Either out of retries or non-transient error
          rethrow;
        }

        // Exponential backoff: 2^attempt seconds (1s, 2s, 4s)
        final delaySeconds = Duration(seconds: 1 << attempt);
        _log.info('Waiting ${delaySeconds.inSeconds}s before retry...');
        await Future.delayed(delaySeconds);

        // Show retry status to user
        final retryMessage = ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: MessageType.status,
          content: 'Retrying... (Attempt ${attempt + 2}/${maxRetries + 1})',
        );
        state = state.copyWith(
          messages: [...state.messages, retryMessage],
        );
      }
    }
  }

  /// Internal message sending logic
  Future<void> _sendMessageInternal(String content) async {
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

      _log.info('Sending message to agent $_agentId');
      _log.debug('Request: ${jsonEncode(requestBody)}');

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
              _log.error('Failed to parse SSE data: $e');
              _log.debug('Data: $data');
            }
          }
        },
        onDone: () {
          _log.info('Stream completed');
          state = state.copyWith(
            isStreaming: false,
            canAbort: false,
          );
          _saveMessages();
        },
        onError: (e) {
          _log.error('Stream error: $e');
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
      _log.error('Error sending message: $e');
      state = state.copyWith(
        isStreaming: false,
        canAbort: false,
        error: e.toString(),
      );
      await _saveMessages();
      rethrow; // Rethrow for retry logic
    }
  }

  /// Handle SSE events from the server
  void _handleSSEEvent(Map<String, dynamic> json) {
    final messageType = json['message_type'];
    _log.debug('Received event: $messageType');

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
        // Stream ending - stop streaming state
        _log.info('Stream stopped: ${json['stop_reason']}');
        state = state.copyWith(
          isStreaming: false,
          canAbort: false,
        );
        _saveMessages();
        break;

      case 'ping':
        // Keepalive, ignore
        break;

      case 'error':
      case 'error_message':
        _handleErrorMessage(json);
        break;

      default:
        _log.warning('Unknown message type: $messageType');
    }
  }

  void _handleUserMessage(Map<String, dynamic> json) {
    // User messages are already added, so we can skip or update
    _log.debug('User message: ${json['content']}');
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
    if (toolCall == null) {
      _log.warning('Tool call message missing tool_call field: $json');
      return;
    }

    _log.debug('Tool call: ${toolCall['name']}, args: ${toolCall['arguments']}');

    final message = ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.toolCall,
      content: '',
      toolName: toolCall['name'] as String?,
      toolInput: toolCall['arguments'] as Map<String, dynamic>?,
      toolCallId: toolCall['tool_call_id'] as String?,
      metadata: {'phase': 'ready'},
    );

    state = state.copyWith(messages: [...state.messages, message]);
  }

  void _handleToolReturnMessage(Map<String, dynamic> json) {
    _log.debug('Tool return: status=${json['status']}, return=${json['tool_return']}');

    final message = ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: MessageType.toolReturn,
      content: json['tool_return']?.toString() ?? '',
      toolName: json['tool_call_id'] as String?, // This is the ID, not name - will be matched with tool_call message
      toolCallId: json['tool_call_id'] as String?,
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

    _log.error('Error message: $errorMessage');

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
  Future<void> clearMessages() async {
    _log.info('Clearing messages for agent $_agentId');

    // Clear local state and storage first
    state = const ChatState();
    await ChatStorage.clearMessages(_agentId);

    // Clear backend agent context
    try {
      final response = await _client.patch(
        '/agents/$_agentId/reset-messages',
        body: {
          'add_default_initial_messages': false,
        },
      );

      if (response.statusCode == 200) {
        _log.info('Backend messages reset successfully');
      } else {
        _log.warning('Backend reset failed with status ${response.statusCode}');
      }
    } catch (e) {
      _log.error('Failed to reset backend messages: $e');
      // Don't rethrow - local clear is still successful
    }
  }

  /// Load messages from localStorage
  Future<void> _loadMessages() async {
    try {
      final messages = await ChatStorage.loadMessages(_agentId);
      if (messages.isNotEmpty) {
        state = state.copyWith(messages: messages);
        _log.info('Loaded ${messages.length} saved messages');
      }
    } catch (e) {
      _log.error('Error loading messages: $e');
    }
  }

  /// Save messages to localStorage
  Future<void> _saveMessages() async {
    try {
      await ChatStorage.saveMessages(_agentId, state.messages);
    } catch (e) {
      _log.error('Error saving messages: $e');
    }
  }

  /// Check if an error is transient (should retry)
  bool _isTransientError(dynamic error) {
    if (error == null) return false;

    final errorMsg = error.toString().toLowerCase();

    // Network-related errors
    if (errorMsg.contains('timeout') ||
        errorMsg.contains('connection') ||
        errorMsg.contains('network') ||
        errorMsg.contains('socket')) {
      return true;
    }

    // API rate limiting
    if (errorMsg.contains('rate limit') ||
        errorMsg.contains('429') ||
        errorMsg.contains('too many requests')) {
      return true;
    }

    // Temporary server errors
    if (errorMsg.contains('503') ||
        errorMsg.contains('502') ||
        errorMsg.contains('504') ||
        errorMsg.contains('service unavailable') ||
        errorMsg.contains('bad gateway')) {
      return true;
    }

    // Connection reset
    if (errorMsg.contains('connection reset') ||
        errorMsg.contains('econnreset')) {
      return true;
    }

    return false;
  }
}
