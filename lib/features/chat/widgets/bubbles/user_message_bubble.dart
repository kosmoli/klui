import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klui/core/theme/klui_text_styles.dart';
import 'package:klui/core/theme/klui_theme_extension.dart';
import 'package:klui/core/models/chat_message.dart';
import 'package:klui/core/extensions/context_extensions.dart';

/// User message bubble - right-aligned, blue background
class UserMessageBubble extends ConsumerWidget {
  const UserMessageBubble({
    super.key,
    required this.message,
    this.messageIndex,
    this.onEdit,
  });

  final ChatMessage message;
  final int? messageIndex;
  final Function(int, String)? onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                message.content,
                style: KluiTextStyles.userMessage,
              ),
            ),
            if (onEdit != null && messageIndex != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showEditDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: colors.userText.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final controller = TextEditingController(text: message.content);
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Edit Message', style: KluiTextStyles.headlineSmall),
        content: TextField(
          controller: controller,
          maxLines: 5,
          style: KluiTextStyles.bodyMedium,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.userBubble),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.common_button_cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final newText = controller.text.trim();
              if (newText.isNotEmpty && newText != message.content && messageIndex != null) {
                onEdit?.call(messageIndex!, newText);
              }
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.userBubble,
              foregroundColor: colors.userText,
            ),
            child: const Text('Save & Resend'),
          ),
        ],
      ),
    );
  }
}
