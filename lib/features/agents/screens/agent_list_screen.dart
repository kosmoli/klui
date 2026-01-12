import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/theme/klui_text_styles.dart';
import '../../../core/theme/klui_theme_extension.dart';
import '../../../core/models/agent.dart';
import '../../../shared/widgets/agent_card.dart';
import '../../../shared/widgets/retro_drawer.dart';
import '../../../shared/widgets/retro_menu_button.dart';

/// Screen displaying list of Agents with Neo-Brutalist design
class AgentListScreen extends ConsumerStatefulWidget {
  const AgentListScreen({super.key});

  @override
  ConsumerState<AgentListScreen> createState() => _AgentListScreenState();
}

class _AgentListScreenState extends ConsumerState<AgentListScreen> {
  @override
  Widget build(BuildContext context) {
    final agentsAsync = ref.watch(agentListProvider);
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      drawer: const RetroDrawer(),
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        toolbarHeight: 48, // Reduced from default 56
        leading: const RetroMenuButton(),
        iconTheme: IconThemeData(color: colors.textPrimary),
        title: Text(
          context.l10n.agent_list_title,
          style: KluiTextStyles.headlineSmall.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          // Back to Chat button
          IconButton(
            onPressed: () => context.go('/chat'),
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Back to Chat',
            style: IconButton.styleFrom(
              backgroundColor: colors.userBubble.withOpacity(0.1),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: agentsAsync.when(
        data: (agents) {
          if (agents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ExcludeSemantics(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colors.surfaceVariant,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(12),
                        ),
                        border: Border.all(
                          color: colors.border,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.smart_toy_outlined,
                        size: 64,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.l10n.agent_list_no_agents,
                    style: KluiTextStyles.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.agent_list_create_first,
                    style: KluiTextStyles.bodyMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(
              top: 16,
              bottom: 80,
            ),
            itemCount: agents.length,
            itemBuilder: (context, index) {
              final agent = agents[index];
              return AgentCard(
                agent: agent,
                onTap: () => context.go('/agents/${agent.id}'),
                onEdit: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.agent_edit_coming_soon(agent.name)),
                      backgroundColor: colors.surfaceVariant,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                onDelete: () {
                  _showDeleteDialog(context, agent, ref);
                },
              );
            },
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colors.userBubble),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.error.withOpacity(0.1),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(12),
                  ),
                  border: Border.all(
                    color: colors.error.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: colors.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.agent_list_error_loading,
                style: KluiTextStyles.headlineSmall,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                ),
                child: Text(
                  error.toString(),
                  style: KluiTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(agentListProvider);
                  Future.delayed(const Duration(milliseconds: 100));
                },
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.agent_list_retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.userBubble,
                  foregroundColor: colors.userText,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Stack(
        children: [
          // Create Agent Button
          Semantics(
            label: context.l10n.agent_list_create_button,
            button: true,
            hint: context.l10n.agent_list_create_button,
            child: FloatingActionButton.extended(
              onPressed: () => context.go('/agents/create'),
              icon: const Icon(Icons.add),
              label: Text(context.l10n.agent_list_create_button),
              backgroundColor: colors.userBubble,
              foregroundColor: colors.userText,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Agent agent, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(context).extension<KluiCustomColors>()!;

        return AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          context.l10n.agent_delete_confirm_title(agent.name),
          style: KluiTextStyles.headlineSmall,
        ),
        content: Text(
          context.l10n.agent_delete_confirm_message,
          style: KluiTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              context.l10n.agent_cancel_button,
              style: KluiTextStyles.button.copyWith(
                color: colors.textPrimary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              try {
                await ref.read(deleteAgentProvider(agent.id).future);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.l10n.agent_delete_success(agent.name),
                        style: const TextStyle(color: Colors.black),
                      ),
                      backgroundColor: colors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  ref.invalidate(agentListProvider);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.agent_delete_failed(agent.name, e.toString())),
                      backgroundColor: colors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(
              context.l10n.agent_delete_button,
              style: KluiTextStyles.button,
            ),
          ),
        ],
      );
      },
    );
  }
}
