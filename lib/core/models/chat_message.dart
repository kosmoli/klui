import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';

/// Chat message types from Letta backend
enum MessageType {
  user,
  assistant,
  toolCall,
  toolReturn,
  reasoning,
  error,
  status,
}

/// Chat message model
@freezed
abstract class ChatMessage with _$ChatMessage {
  const ChatMessage._();

  const factory ChatMessage({
    required String id,
    required MessageType type,
    required String content,
    Map<String, dynamic>? metadata,
    // Tool call specific fields
    @JsonKey(name: 'tool_name') String? toolName,
    @JsonKey(name: 'tool_input') Map<String, dynamic>? toolInput,
    @JsonKey(name: 'tool_call_id') String? toolCallId,
    @JsonKey(name: 'is_tool_error') bool? isToolError,
  }) = _ChatMessage;

  /// Create example messages for demo
  static List<ChatMessage> demoMessages() => [
    // User message
    ChatMessage(
      id: 'msg_1',
      type: MessageType.user,
      content: 'Help me understand how tools work in this system',
    ),

    // Assistant message
    ChatMessage(
      id: 'msg_2',
      type: MessageType.assistant,
      content: '''I'll demonstrate the tool system for you. Let me run a simple command to show you how it works.

The system has several built-in tools:
- **Bash**: Execute shell commands
- **Write**: Create or modify files
- **Read**: Read file contents
- **Web Search**: Search the internet

Let me run a simple `ls` command to list files:''',
    ),

    // Tool call - ls command
    ChatMessage(
      id: 'msg_3',
      type: MessageType.toolCall,
      content: '',
      toolName: 'Bash',
      toolInput: {'command': 'ls -la'},
      metadata: {'phase': 'ready'},
    ),

    // Tool return - ls result
    ChatMessage(
      id: 'msg_4',
      type: MessageType.toolReturn,
      content: '''total 48
drwxr-xr-x  12 user  staff   384 Jan 11 10:00 .
drwxr-xr-x   5 user  staff   160 Jan 11 09:00 ..
-rw-r--r--   1 user  staff  2048 Jan 11 10:00 README.md
drwxr-xr-x   3 user  staff    96 Jan 11 09:30 lib
-rw-r--r--   1 user  staff   512 Jan 11 10:00 pubspec.yaml''',
      toolName: 'Bash',
      metadata: {'phase': 'finished', 'isOk': true},
    ),

    // Tool call - write file (needs approval)
    ChatMessage(
      id: 'msg_5',
      type: MessageType.toolCall,
      content: '',
      toolName: 'Write',
      toolInput: {
        'file_path': 'example.txt',
        'content': 'Hello, World!\nThis is a test file.'
      },
      metadata: {'phase': 'ready'},
    ),

    // Error message
    ChatMessage(
      id: 'msg_6',
      type: MessageType.error,
      content: 'Failed to execute command: Permission denied',
    ),

    // Reasoning message
    ChatMessage(
      id: 'msg_7',
      type: MessageType.reasoning,
      content: '''The user wants to understand how the tool system works. I should:
1. Explain the available tools
2. Demonstrate a simple example
3. Show how tool approval works
4. Display the results clearly''',
    ),

    // Another tool call - web search
    ChatMessage(
      id: 'msg_8',
      type: MessageType.toolCall,
      content: '',
      toolName: 'Web Search',
      toolInput: {'query': 'Flutter widget tree optimization'},
      metadata: {'phase': 'running'},
    ),

    // Code block result example
    ChatMessage(
      id: 'msg_9',
      type: MessageType.toolReturn,
      content: '''```dart
// Example Flutter widget
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Hello, World!'),
    );
  }
}
```''',
      toolName: 'Write',
      metadata: {'phase': 'finished', 'isOk': true},
    ),
  ];
}
