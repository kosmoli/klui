import 'package:flutter/material.dart';
import 'package:klui/core/extensions/context_extensions.dart';
import 'package:klui/core/theme/klui_text_styles.dart';
import 'package:klui/core/theme/klui_theme_extension.dart';
import 'package:klui/core/models/chat_message.dart';

/// Search bar for filtering chat messages
class ChatSearchBar extends StatefulWidget {
  final List<ChatMessage> allMessages;
  final ValueChanged<List<ChatMessage>> onResultsChanged;

  const ChatSearchBar({
    super.key,
    required this.allMessages,
    required this.onResultsChanged,
  });

  @override
  State<ChatSearchBar> createState() => _ChatSearchBarState();
}

class _ChatSearchBarState extends State<ChatSearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _isExpanded = false;
  int _resultCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _resultCount = widget.allMessages.length;
      });
      widget.onResultsChanged(widget.allMessages);
      return;
    }

    final lowerQuery = query.toLowerCase();
    final results = widget.allMessages.where((message) {
      // Search in message content
      if (message.content.toLowerCase().contains(lowerQuery)) {
        return true;
      }
      // Search in tool names
      if (message.toolName?.toLowerCase().contains(lowerQuery) ?? false) {
        return true;
      }
      return false;
    }).toList();

    setState(() {
      _resultCount = results.length;
    });
    widget.onResultsChanged(results);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _isExpanded ? 56 : 40,
      child: _isExpanded ? _buildExpandedSearch(colors) : _buildCollapsedSearch(colors),
    );
  }

  Widget _buildCollapsedSearch(KluiCustomColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = true),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Icon(Icons.search, color: colors.textSecondary, size: 18),
            const SizedBox(width: 8),
            Text(
              context.l10n.chat_search_placeholder,
              style: KluiTextStyles.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedSearch(KluiCustomColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: colors.textSecondary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              style: KluiTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: context.l10n.chat_search_placeholder,
                hintStyle: TextStyle(color: colors.textSecondary),
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: _performSearch,
              autofocus: true,
            ),
          ),
          if (_controller.text.isNotEmpty) ...[
            Text(
              context.l10n.chat_search_results(_resultCount),
              style: KluiTextStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            onPressed: () {
              _controller.clear();
              _performSearch('');
              setState(() => _isExpanded = false);
            },
            icon: const Icon(Icons.close, size: 18),
            tooltip: 'Close',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }
}
