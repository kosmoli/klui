import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:klui/core/theme/klui_text_styles.dart';
import 'package:klui/core/theme/klui_theme_extension.dart';
import 'package:klui/core/models/chat_message.dart';

/// Assistant message bubble - left-aligned, supports Markdown
class AssistantMessageBubble extends StatelessWidget {
  const AssistantMessageBubble({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.only(right: 48, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colors.assistantBubble,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border, width: 1),
        ),
        child: MarkdownBody(
          data: message.content,
          styleSheet: MarkdownStyleSheet(
            p: KluiTextStyles.assistantMessage,
            h1: KluiTextStyles.assistantMessage.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
            h2: KluiTextStyles.assistantMessage.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            h3: KluiTextStyles.assistantMessage.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            code: KluiTextStyles.codeBlock.copyWith(
              fontSize: 13,
              color: colors.toolSearch,
              backgroundColor: colors.background,
            ),
            codeblockDecoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.border, width: 1),
            ),
            codeblockPadding: const EdgeInsets.all(12),
            blockSpacing: 8,
            listBullet: KluiTextStyles.assistantMessage.copyWith(
              color: colors.userBubble,
            ),
            blockquote: KluiTextStyles.assistantMessage.copyWith(
              fontStyle: FontStyle.italic,
              color: colors.reasoning,
            ),
            a: KluiTextStyles.assistantMessage.copyWith(
              color: colors.userBubble,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }
}
