import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/agent.dart';
import '../../../shared/widgets/agent_card.dart';
import '../../../shared/widgets/main_navigation.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.agent_list_title),
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
                      padding: const EdgeInsets.all(AppTheme.spacing24),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariantColor,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(AppTheme.radiusLarge),
                        ),
                        border: Border.all(
                          color: AppTheme.borderColor,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.smart_toy_outlined,
                        size: 64,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing24),
                  Text(
                    context.l10n.agent_list_no_agents,
                    style: AppTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    context.l10n.agent_list_create_first,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(
              top: AppTheme.spacing16,
              bottom: AppTheme.spacing80,
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
                      backgroundColor: AppTheme.surfaceVariantColor,
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
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing24),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppTheme.radiusLarge),
                  ),
                  border: Border.all(
                    color: AppTheme.errorColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),
              Text(
                context.l10n.agent_list_error_loading,
                style: AppTheme.headlineSmall,
              ),
              const SizedBox(height: AppTheme.spacing8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing32,
                ),
                child: Text(
                  error.toString(),
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(agentListProvider);
                  Future.delayed(const Duration(milliseconds: 100));
                },
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.agent_list_retry),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Semantics(
        label: context.l10n.agent_list_create_button,
        button: true,
        hint: context.l10n.agent_list_create_button,
        child: FloatingActionButton.extended(
          onPressed: () => context.go('/agents/create'),
          icon: const Icon(Icons.add),
          label: Text(context.l10n.agent_list_create_button),
        ),
      ),
      bottomNavigationBar: MainNavigation(currentPath: '/agents'),
    );
  }

  void _showDeleteDialog(BuildContext context, Agent agent, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.agent_delete_confirm_title(agent.name)),
        content: Text(context.l10n.agent_delete_confirm_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.agent_cancel_button),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              try {
                await ref.read(deleteAgentProvider(agent.id).future);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.agent_delete_success(agent.name)),
                      backgroundColor: AppTheme.primaryColor,
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
                      backgroundColor: AppTheme.errorColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: Text(context.l10n.agent_delete_button),
          ),
        ],
      ),
    );
  }
}
