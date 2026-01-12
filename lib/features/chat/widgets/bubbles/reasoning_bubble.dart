import 'package:flutter/material.dart';
import 'package:klui/core/theme/klui_text_styles.dart';
import 'package:klui/core/theme/klui_theme_extension.dart';
import 'package:klui/core/models/chat_message.dart';

/// Reasoning bubble - collapsible "Thinking..." section
class ReasoningBubble extends StatefulWidget {
  const ReasoningBubble({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  State<ReasoningBubble> createState() => _ReasoningBubbleState();
}

class _ReasoningBubbleState extends State<ReasoningBubble> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Always Visible
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Text('💭', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    'Thinking...',
                    style: KluiTextStyles.reasoning.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // Expand/Collapse Icon
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: colors.reasoning,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content - Expandable
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                widget.message.content,
                style: KluiTextStyles.reasoning,
                maxLines: null,
              ),
            ),
        ],
      ),
    );
  }
}
