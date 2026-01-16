import 'package:flutter/material.dart';
import 'package:klui/core/extensions/context_extensions.dart';
import 'package:klui/core/theme/klui_text_styles.dart';
import 'package:klui/core/theme/klui_theme_extension.dart';
import 'package:klui/core/models/chat_message.dart';

/// Search result callback
typedef OnResultSelected = void Function(int index);

/// Search bar for searching and navigating through chat messages
class ChatSearchBar extends StatefulWidget {
  final List<ChatMessage> allMessages;
  final ValueChanged<String> onSearchChanged;
  final OnResultSelected? onResultSelected;

  const ChatSearchBar({
    super.key,
    required this.allMessages,
    required this.onSearchChanged,
    this.onResultSelected,
  });

  @override
  State<ChatSearchBar> createState() => _ChatSearchBarState();
}

class _ChatSearchBarState extends State<ChatSearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _isExpanded = false;
  int _currentIndex = -1;
  List<int> _matchedIndices = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    final lowerQuery = query.toLowerCase();
    final matches = <int>[];

    if (lowerQuery.isEmpty) {
      setState(() {
        _matchedIndices = [];
        _currentIndex = -1;
      });
      widget.onSearchChanged('');
      return;
    }

    for (int i = 0; i < widget.allMessages.length; i++) {
      final message = widget.allMessages[i];
      // Search in message content
      if (message.content.toLowerCase().contains(lowerQuery)) {
        matches.add(i);
        continue;
      }
      // Search in tool names
      if (message.toolName?.toLowerCase().contains(lowerQuery) ?? false) {
        matches.add(i);
        continue;
      }
    }

    setState(() {
      _matchedIndices = matches;
      _currentIndex = matches.isNotEmpty ? 0 : -1;
    });

    widget.onSearchChanged(query);

    // Auto-select first match
    if (matches.isNotEmpty) {
      widget.onResultSelected?.call(matches[0]);
    }
  }

  void _goToPrev() {
    if (_matchedIndices.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex - 1 + _matchedIndices.length) % _matchedIndices.length;
    });
    widget.onResultSelected?.call(_matchedIndices[_currentIndex]);
  }

  void _goToNext() {
    if (_matchedIndices.isEmpty) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % _matchedIndices.length;
    });
    widget.onResultSelected?.call(_matchedIndices[_currentIndex]);
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
    final hasResults = _matchedIndices.isNotEmpty;
    final resultText = hasResults
        ? '${_currentIndex + 1}/${_matchedIndices.length}'
        : context.l10n.chat_search_no_results;

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
            // Navigation buttons
            if (hasResults) ...[
              IconButton(
                onPressed: _goToPrev,
                icon: const Icon(Icons.keyboard_arrow_up, size: 18),
                tooltip: 'Previous match',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 28,
                  minHeight: 28,
                ),
              ),
              IconButton(
                onPressed: _goToNext,
                icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                tooltip: 'Next match',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 28,
                  minHeight: 28,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  resultText,
                  style: KluiTextStyles.bodySmall.copyWith(
                    color: colors.userBubble,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 4),
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
        ],
      ),
    );
  }
}
