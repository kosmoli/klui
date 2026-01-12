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

/// Chat Screen - Real-time chat with Agent
class ChatScreen extends ConsumerStatefulWidget {
  final String agentId;

  const ChatScreen({
    super.key,
    required this.agentId,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _keyboardFocusNode = FocusNode();

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

  void _abortMessage() {
    ref.read(chatStateHolderProvider(widget.agentId).notifier).abortMessage();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Check if agent is selected
    if (widget.agentId.isEmpty) {
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

    ref.read(chatStateHolderProvider(widget.agentId).notifier).sendMessage(text);
    _controller.clear();
    _focusNode.unfocus();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    final chatState = ref.watch(chatStateHolderProvider(widget.agentId));
    final messages = chatState.messages;
    final isStreaming = chatState.isStreaming;
    final canAbort = chatState.canAbort;

    // Auto-scroll when new messages arrive
    if (messages.isNotEmpty) {
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
          _abortMessage();
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        drawer: const RetroDrawer(),
        appBar: AppBar(
          backgroundColor: colors.surface,
          elevation: 0,
          leading: const RetroMenuButton(),
          title: Row(
            children: [
              Text(
                context.l10n.nav_chat,
                style: KluiTextStyles.headlineSmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isStreaming) ...[
                const SizedBox(width: 12),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colors.userBubble),
                  ),
                ),
              ],
              if (canAbort) ...[
                const SizedBox(width: 8),
                Text(
                  context.l10n.chat_abort_esc_hint,
                  style: KluiTextStyles.labelSmall.copyWith(
                    color: colors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
          toolbarHeight: 48,
          iconTheme: IconThemeData(color: colors.textPrimary),
          actions: [
            // Agent Selector
            _AgentSelector(
              agentsAsync: agentsAsync,
            currentAgentId: widget.agentId,
          ),
          if (canAbort)
            Semantics(
              label: context.l10n.chat_abort_button,
              button: true,
              hint: context.l10n.chat_abort_button_hint,
              child: IconButton(
                onPressed: _abortMessage,
                icon: const Icon(Icons.stop),
                tooltip: context.l10n.chat_abort_button,
                style: IconButton.styleFrom(
                  backgroundColor: colors.error.withOpacity(0.1),
                  foregroundColor: colors.error,
                ),
              ),
            ),
          IconButton(
            onPressed: () {
              ref.read(chatStateHolderProvider(widget.agentId).notifier).clearMessages();
            },
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear chat',
            color: colors.textPrimary,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState(context, colors)
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      return _MessageTile(message: message);
                    },
                  ),
          ),

          // Input Area
          _ChatInputArea(
            controller: _controller,
            focusNode: _focusNode,
            isStreaming: isStreaming,
            agentId: widget.agentId,
            onSend: _sendMessage,
          ),
        ],
      ),
    ));
  }

  Widget _buildEmptyState(BuildContext context, KluiCustomColors colors) {
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

/// Agent Selector Widget - Shows current agent and allows switching
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
        // Find current agent in the list
        Agent? currentAgent;
        try {
          currentAgent = agents.firstWhere((a) => a.id == currentAgentId);
        } catch (e) {
          currentAgent = null;
        }

        final currentAgentName = currentAgent?.name ?? 'Select Agent';

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Semantics(
            label: context.l10n.agent_selector_label(currentAgentName),
            button: true,
            hint: context.l10n.agent_selector_hint,
            child: InkWell(
              onTap: agents.isEmpty
                  ? null
                  : () => _showAgentMenu(context, agents),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.border),
                  borderRadius: BorderRadius.circular(8),
                  color: colors.surfaceVariant.withOpacity(0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.smart_toy_outlined,
                      size: 18,
                      color: colors.userBubble,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentAgentName,
                      style: KluiTextStyles.labelMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (agents.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 20,
                        color: colors.textSecondary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(colors.userBubble),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showAgentMenu(
    BuildContext context,
    List<Agent> agents,
  ) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(80, 48, 0, 0),
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
        context.go('/chat?agentId=$value');
      }
    });
  }
}
