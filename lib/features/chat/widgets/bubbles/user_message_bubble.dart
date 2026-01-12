import 'package:flutter/material.dart';
import 'package:klui/core/theme/klui_text_styles.dart';
import 'package:klui/core/theme/klui_theme_extension.dart';
import 'package:klui/core/models/chat_message.dart';

/// User message bubble - right-aligned, blue background
class UserMessageBubble extends StatelessWidget {
  const UserMessageBubble({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.only(left: 48, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: colors.userBubble,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.content,
          style: KluiTextStyles.userMessage,
        ),
      ),
    );
  }
}
