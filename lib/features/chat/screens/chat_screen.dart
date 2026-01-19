import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/klui_text_styles.dart';
import '../../../../core/theme/klui_theme_extension.dart';
import '../../../../core/providers/chat_providers.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/models/chat_message.dart';
import '../../../../core/models/agent.dart';
import '../../../shared/widgets/retro_drawer.dart';
import '../../../shared/widgets/retro_menu_button.dart';
import '../widgets/bubbles/user_message_bubble.dart';
import '../widgets/bubbles/assistant_message_bubble.dart';
import '../widgets/bubbles/error_bubble.dart';
import '../widgets/bubbles/reasoning_bubble.dart';
import '../widgets/tool_call_card.dart';
import '../widgets/context_size_indicator.dart';
import '../widgets/memory_view_dialog.dart';
import '../widgets/chat_search_bar.dart';
import '../services/chat_export_service.dart';
import '../widgets/tools_manage_dialog.dart';

/// Chat Screen - Real-time chat with Agent
class ChatScreen extends ConsumerStatefulWidget {
  /// Optional initial agent ID from URL query parameter
  /// If provided, will override the saved selection
  final String? initialAgentId;

  const ChatScreen({
    super.key,
    this.initialAgentId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _keyboardFocusNode = FocusNode();

  // Search state
  String _searchQuery = '';
  int? _highlightedIndex;

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _highlightedIndex = null;
    });
  }

  void _onResultSelected(int index) {
    setState(() {
      _highlightedIndex = index;
    });
    _scrollToIndex(index);
  }

  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;

    // Calculate position for the item at index (reverse list)
    final messages = ref.read(chatStateHolderProvider(ref.read(selectedAgentIdProvider))).messages;
    if (index >= messages.length) return;

    // In reverse ListView, item index in display = messages.length - 1 - actual index
    final displayIndex = messages.length - 1 - index;
    final itemPosition = displayIndex * 80.0; // Approximate item height

    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          itemPosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  bool _isMessageMatched(ChatMessage message) {
    if (_searchQuery.isEmpty) return false;
    final lowerQuery = _searchQuery.toLowerCase();
    return message.content.toLowerCase().contains(lowerQuery) ||
        (message.toolName?.toLowerCase().contains(lowerQuery) ?? false);
  }

  @override
  void initState() {
    super.initState();
    // If an initial agent ID was provided via query param, save it
    if (widget.initialAgentId != null && widget.initialAgentId!.isNotEmpty) {
      ref.read(selectedAgentIdProvider.notifier).setSelectedAgentId(widget.initialAgentId!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _abortMessage(String agentId) {
    ref.read(chatStateHolderProvider(agentId).notifier).abortMessage();
  }

  void _onMessageEdit(int messageIndex, String newContent) async {
    final agentId = ref.read(selectedAgentIdProvider);
    if (agentId.isEmpty) return;
    
    await ref.read(chatStateHolderProvider(agentId).notifier).editAndResend(messageIndex, newContent);
  }

  void _sendMessage(String agentId) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Check if agent is selected
    if (agentId.isEmpty) {
      final colors = Theme.of(context).extension<KluiCustomColors>()!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.chat_error_no_agent),
          backgroundColor: colors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref.read(chatStateHolderProvider(agentId).notifier).sendMessage(text);
    _controller.clear();
    _focusNode.unfocus();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    // Read agent ID from provider - this will update when provider changes
    final agentId = ref.watch(selectedAgentIdProvider);
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    final chatState = ref.watch(chatStateHolderProvider(agentId));
    final messages = chatState.messages;
    final isStreaming = chatState.isStreaming;
    final canAbort = chatState.canAbort;

    // Auto-scroll when new messages arrive (only if not searching)
    if (messages.isNotEmpty && _searchQuery.isEmpty) {
      _scrollToBottom();
    }

    // Get all agents and current agent
    final agentsAsync = ref.watch(agentListProvider);

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape &&
            canAbort) {
          _abortMessage(agentId);
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        drawer: const RetroDrawer(),
        appBar: AppBar(
          backgroundColor: colors.surface,
          elevation: 0,
          leading: const RetroMenuButton(),
          titleSpacing: 0,
          title: Row(
            children: [
              // Agent Selector - compact inline
              _AgentSelector(
                agentsAsync: agentsAsync,
                currentAgentId: agentId,
              ),
              // Streaming indicator - subtle
              if (isStreaming) ...[
                const SizedBox(width: 12),
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.userBubble),
                  ),
                ),
              ],
            ],
          ),
          toolbarHeight: 48,
          iconTheme: IconThemeData(color: colors.textPrimary),
          actions: [
            // Abort button - only show when streaming, replaces others
            if (canAbort)
              Semantics(
                label: context.l10n.chat_abort_button,
                button: true,
                hint: context.l10n.chat_abort_button_hint,
                child: IconButton(
                  onPressed: () => _abortMessage(agentId),
                  icon: const Icon(Icons.stop, size: 20),
                  tooltip: context.l10n.chat_abort_button,
                  style: IconButton.styleFrom(
                    backgroundColor: colors.error.withOpacity(0.15),
                    foregroundColor: colors.error,
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              )
            else
              // More options menu - consolidated actions
              _ChatActionsMenu(
                agentId: agentId,
                agentsAsync: agentsAsync,
                messages: messages,
                hasUsage: chatState.usage != null,
                usage: chatState.usage,
              ),
            const SizedBox(width: 4),
          ],
        ),
      body: Column(
        children: [
          // Search bar (shown when there are messages)
          if (messages.isNotEmpty && messages.length > 3)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ChatSearchBar(
                allMessages: messages,
                onSearchChanged: _onSearchChanged,
                onResultSelected: _onResultSelected,
              ),
            ),

          // Message List
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState(context, colors, false)
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final messageIndex = messages.length - 1 - index;
                      final message = messages[messageIndex];
                      final isHighlighted = _highlightedIndex == messageIndex;
                      final isMatched = _isMessageMatched(message);
                      return _MessageTile(
                        key: ValueKey(message.id),
                        message: message,
                        isHighlighted: isHighlighted,
                        isMatched: isMatched && _searchQuery.isNotEmpty,
                        onEdit: message.type == MessageType.user ? _onMessageEdit : null,
                        messageIndex: messageIndex,
                      );
                    },
                  ),
          ),

          // Input Area
          _ChatInputArea(
            controller: _controller,
            focusNode: _focusNode,
            isStreaming: isStreaming,
            agentId: agentId,
            onSend: () => _sendMessage(agentId),
          ),
        ],
      ),
    ));
  }

  Widget _buildEmptyState(BuildContext context, KluiCustomColors colors, bool isSearchResult) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.border,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: colors.userBubble,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.chat_empty_title,
            style: KluiTextStyles.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.chat_empty_subtitle,
            style: KluiTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Message Tile - Routes to appropriate widget based on type
class _MessageTile extends StatelessWidget {
  const _MessageTile({
    required this.message,
    this.isHighlighted = false,
    this.isMatched = false,
    this.onEdit,
    this.messageIndex,
    super.key,
  });

  final ChatMessage message;
  final bool isHighlighted;
  final bool isMatched;
  final Function(int, String)? onEdit;
  final int? messageIndex;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Container(
      decoration: isHighlighted
          ? BoxDecoration(
              color: colors.userBubble.withOpacity(0.15),
              border: Border(
                left: BorderSide(color: colors.userBubble, width: 3),
              ),
            )
          : isMatched
              ? BoxDecoration(
                  color: colors.surfaceVariant.withOpacity(0.3),
                )
              : null,
      child: _buildMessageContent(context, colors),
    );
  }

  Widget _buildMessageContent(BuildContext context, KluiCustomColors colors) {
    switch (message.type) {
      case MessageType.user:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: UserMessageBubble(
            message: message,
            messageIndex: messageIndex,
            onEdit: message.type == MessageType.user ? onEdit : null,
          ),
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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ReasoningBubble(message: message),
        );

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

/// Chat Input Area
class _ChatInputArea extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isStreaming;
  final String agentId;
  final VoidCallback onSend;

  const _ChatInputArea({
    required this.controller,
    required this.focusNode,
    required this.isStreaming,
    required this.agentId,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    final hasAgent = agentId.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: KluiTextStyles.assistantMessage,
              decoration: InputDecoration(
                hintText: hasAgent
                    ? context.l10n.chat_input_hint
                    : context.l10n.chat_input_disabled_no_agent,
                hintStyle: TextStyle(color: colors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colors.userBubble),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: colors.textDisabled.withOpacity(0.5)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                isDense: true,
              ),
              onSubmitted: (_) => onSend(),
              enabled: hasAgent && !isStreaming,
              maxLines: null,
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: (!hasAgent || isStreaming) ? null : onSend,
            icon: const Icon(Icons.send),
            color: (!hasAgent || isStreaming)
                ? colors.textDisabled
                : colors.userBubble,
            style: IconButton.styleFrom(
              backgroundColor: colors.userBubble.withOpacity(0.1),
              minimumSize: const Size(40, 40),
              padding: const EdgeInsets.all(8),
            ),
            tooltip: context.l10n.chat_send_tooltip,
          ),
        ],
      ),
    );
  }
}

/// Compact Agent Selector - Minimal design for AppBar
class _AgentSelector extends ConsumerWidget {
  final AsyncValue<List<Agent>> agentsAsync;
  final String currentAgentId;

  const _AgentSelector({
    required this.agentsAsync,
    required this.currentAgentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return agentsAsync.when(
      data: (agents) {
        Agent? currentAgent;
        try {
          currentAgent = agents.firstWhere((a) => a.id == currentAgentId);
        } catch (e) {
          currentAgent = null;
        }

        final currentAgentName = currentAgent?.name ?? 'Select';
        // Truncate name if too long
        final displayName = currentAgentName.length > 15
            ? '${currentAgentName.substring(0, 12)}...'
            : currentAgentName;

        return Semantics(
          label: context.l10n.agent_selector_label(currentAgentName),
          button: true,
          hint: context.l10n.agent_selector_hint,
          child: InkWell(
            onTap: agents.isEmpty
                ? null
                : () => _showAgentMenu(context, ref, agents),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: colors.border, width: 1),
                borderRadius: BorderRadius.circular(6),
                color: colors.surfaceVariant.withOpacity(0.3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.smart_toy_outlined,
                    size: 16,
                    color: colors.userBubble,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    displayName,
                    style: KluiTextStyles.labelMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  if (agents.isNotEmpty) ...[
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 18,
                      color: colors.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
      loading: () => SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(colors.userBubble),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showAgentMenu(
    BuildContext context,
    WidgetRef ref,
    List<Agent> agents,
  ) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(60, 48, 0, 0),
      items: agents.map((agent) {
        final isSelected = agent.id == currentAgentId;
        return PopupMenuItem<String>(
          value: agent.id,
          child: Semantics(
            selected: isSelected,
            button: true,
            label: context.l10n.agent_selector_item_label(
              agent.name ?? 'Unnamed Agent',
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.smart_toy_outlined,
                    size: 18,
                    color: isSelected
                        ? colors.userBubble
                        : colors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      agent.name ?? 'Unnamed Agent',
                      style: KluiTextStyles.bodyMedium.copyWith(
                        color: isSelected
                            ? colors.userBubble
                            : colors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check,
                      size: 18,
                      color: colors.userBubble,
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        ref.read(selectedAgentIdProvider.notifier).setSelectedAgentId(value);
      }
    });
  }
}

/// Consolidated Chat Actions Menu
class _ChatActionsMenu extends ConsumerWidget {
  final String agentId;
  final AsyncValue<List<Agent>> agentsAsync;
  final List<ChatMessage> messages;
  final bool hasUsage;
  final Map<String, dynamic>? usage;

  const _ChatActionsMenu({
    required this.agentId,
    required this.agentsAsync,
    required this.messages,
    required this.hasUsage,
    required this.usage,
  });

  void _showMenu(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    final l10n = context.l10n;

    // Build menu items list
    final items = <PopupMenuEntry<dynamic>>[
      // Context size (if available)
      if (hasUsage)
        PopupMenuItem(
          enabled: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.storage, size: 18, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.chat_context_size_label,
                        style: KluiTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 2),
                      ContextSizeIndicator(usage: usage),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      if (hasUsage) const PopupMenuDivider(height: 1),

      // Memory
      if (agentId.isNotEmpty)
        PopupMenuItem(
          onTap: () => _showMemoryDialog(context, ref),
          child: Row(
            children: [
              const Icon(Icons.psychology_outlined, size: 18),
              const SizedBox(width: 12),
              Text(l10n.memory_view_title),
            ],
          ),
        ),

      // Tools
      if (agentId.isNotEmpty)
        PopupMenuItem(
          onTap: () => _showToolsDialog(context, ref),
          child: Row(
            children: [
              const Icon(Icons.build_outlined, size: 18),
              const SizedBox(width: 12),
              Text(l10n.tools_title),
            ],
          ),
        ),

      // Export
      if (messages.isNotEmpty)
        PopupMenuItem(
          onTap: () => _showExportMenu(context, ref),
          child: Row(
            children: [
              const Icon(Icons.download, size: 18),
              const SizedBox(width: 12),
              Text(l10n.chat_export_button_tooltip),
            ],
          ),
        ),

      const PopupMenuDivider(height: 1),

      // Clear chat
      PopupMenuItem(
        onTap: () => _clearChat(context, ref),
        child: Row(
          children: [
            Icon(Icons.clear_all, size: 18, color: colors.error),
            const SizedBox(width: 12),
            Text(l10n.chat_clear_button_tooltip, style: TextStyle(color: colors.error)),
          ],
        ),
      ),
    ];

    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(200, 48, 0, 0),
      items: items,
    );
  }

  void _showMemoryDialog(BuildContext context, WidgetRef ref) {
    agentsAsync.whenData((agents) {
      final agent = agents.firstWhere(
        (a) => a.id == agentId,
        orElse: () => Agent(id: agentId, name: 'Unknown'),
      );
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) => MemoryViewDialog(
          agentId: agentId,
          agentName: agent.name ?? 'Unknown',
        ),
      );
    });
  }

  void _showToolsDialog(BuildContext context, WidgetRef ref) {
    agentsAsync.whenData((agents) {
      final agent = agents.firstWhere(
        (a) => a.id == agentId,
        orElse: () => Agent(id: agentId, name: 'Unknown'),
      );
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) => ToolsManageDialog(
          agentId: agentId,
          agentName: agent.name ?? 'Unknown',
        ),
      );
    });
  }

  void _showExportMenu(BuildContext context, WidgetRef ref) {
    Navigator.of(context).pop();

    agentsAsync.whenData((agents) {
      final agent = agents.firstWhere(
        (a) => a.id == agentId,
        orElse: () => Agent(id: agentId, name: 'Unknown'),
      );

      showMenu<String>(
        context: context,
        position: const RelativeRect.fromLTRB(200, 48, 0, 0),
        items: [
          PopupMenuItem<String>(
            value: 'markdown',
            child: Row(
              children: [
                const Icon(Icons.description, size: 18),
                const SizedBox(width: 12),
                Text(context.l10n.chat_export_format_markdown),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'json',
            child: Row(
              children: [
                const Icon(Icons.code, size: 18),
                const SizedBox(width: 12),
                Text(context.l10n.chat_export_format_json),
              ],
            ),
          ),
        ],
      ).then((format) {
        if (format != null) {
          _exportChat(context, agent, messages, format);
        }
      });
    });
  }

  void _exportChat(BuildContext context, Agent agent, List<ChatMessage> messages, String format) {
    try {
      final filename = ChatExportService.generateFilename(
        agentName: agent.name ?? 'chat',
        extension: format == 'markdown' ? '.md' : '.json',
      );

      String content;
      String mimeType;

      if (format == 'markdown') {
        content = ChatExportService.toMarkdown(
          messages: messages,
          agent: agent,
        );
        mimeType = 'text/markdown';
      } else {
        content = ChatExportService.toJson(
          messages: messages,
          agent: agent,
        );
        mimeType = 'application/json';
      }

      ChatExportService.downloadFile(
        content: content,
        filename: filename,
        mimeType: mimeType,
      );

      final colors = Theme.of(context).extension<KluiCustomColors>()!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.chat_export_success),
          backgroundColor: colors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      final colors = Theme.of(context).extension<KluiCustomColors>()!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.l10n.chat_export_failed}: $e'),
          backgroundColor: colors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearChat(BuildContext context, WidgetRef ref) {
    Navigator.of(context).pop();
    ref.read(chatStateHolderProvider(agentId).notifier).clearMessages();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return IconButton(
      onPressed: () => _showMenu(context, ref),
      icon: const Icon(Icons.more_vert, size: 20),
      tooltip: 'More options',
      color: colors.textPrimary,
      padding: const EdgeInsets.all(8),
    );
  }
}
