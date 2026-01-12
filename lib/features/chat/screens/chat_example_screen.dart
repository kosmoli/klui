import 'package:flutter/material.dart';
import 'package:klui/core/theme/klui_colors.dart';
import 'package:klui/core/theme/klui_text_styles.dart';
import 'package:klui/core/models/chat_message.dart';
import 'package:klui/features/chat/widgets/bubbles/user_message_bubble.dart';
import 'package:klui/features/chat/widgets/bubbles/assistant_message_bubble.dart';
import 'package:klui/features/chat/widgets/bubbles/error_bubble.dart';
import 'package:klui/features/chat/widgets/bubbles/reasoning_bubble.dart';
import 'package:klui/features/chat/widgets/tool_call_card.dart';
import 'package:klui/shared/widgets/main_navigation.dart';

/// Chat Example Screen - Demo page showing all message types
class ChatExampleScreen extends StatelessWidget {
  const ChatExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final messages = ChatMessage.demoMessages();

    return Scaffold(
      backgroundColor: KluiColors.background,
      appBar: AppBar(
        title: const Text(
          'Chat UI Example',
          style: TextStyle(
            color: KluiColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: KluiColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: KluiColors.textPrimary),
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                return _MessageTile(message: message);
              },
            ),
          ),
          // Input Area (Demo only)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KluiColors.surface,
              border: Border(
                top: BorderSide(color: KluiColors.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: KluiTextStyles.assistantMessage,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: KluiColors.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: KluiColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: KluiColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: KluiColors.userBubble),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.send, color: KluiColors.userBubble),
                  style: IconButton.styleFrom(
                    backgroundColor: KluiColors.userBubble.withOpacity(0.1),
                    minimumSize: const Size(48, 48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainNavigation(currentPath: '/chat'),
    );
  }
}

/// Message Tile - Routes to appropriate widget based on type
class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    switch (message.type) {
      case MessageType.user:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: UserMessageBubble(message: message),
        );

      case MessageType.assistant:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: AssistantMessageBubble(message: message),
        );

      case MessageType.toolCall:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ToolCallCard(message: message),
        );

      case MessageType.toolReturn:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ToolCallCard(message: message),
        );

      case MessageType.reasoning:
        return ReasoningBubble(message: message);

      case MessageType.error:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ErrorBubble(message: message),
        );

      case MessageType.status:
        return const SizedBox.shrink(); // Status messages not shown in chat
    }
  }
}
