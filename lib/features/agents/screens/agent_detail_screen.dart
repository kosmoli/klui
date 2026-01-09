import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/agent.dart';

/// Agent Detail Screen with Neo-Brutalist design
///
/// Displays comprehensive information about a single Agent including:
/// - Basic info (name, description, ID)
/// - Model configuration
/// - Tools
/// - Memory settings
/// - Creation/modification timestamps
class AgentDetailScreen extends ConsumerWidget {
  final String agentId;

  const AgentDetailScreen({
    super.key,
    required this.agentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentAsync = ref.watch(agentProvider(agentId));

    return Scaffold(
      appBar: _buildAppBar(context, ref),
      body: agentAsync.when(
        data: (agent) => _buildContent(context, agent),
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: AppTheme.spacing24),
              Text(
                'Failed to load agent',
                style: AppTheme.headlineSmall,
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                error.toString(),
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/agents'),
        tooltip: 'Back to Agents',
      ),
      title: const Text('Agent Details'),
      actions: [
        Tooltip(
          message: 'Edit',
          child: IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: Implement edit
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit feature - Coming soon!'),
                  backgroundColor: AppTheme.surfaceVariantColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
        Tooltip(
          message: 'Delete',
          child: IconButton(
            icon: const Icon(Icons.delete_outlined),
            onPressed: () => _showDeleteDialog(context, ref),
            color: AppTheme.errorColor,
          ),
        ),
        const SizedBox(width: AppTheme.spacing8),
      ],
    );
  }

  Widget _buildContent(BuildContext context, Agent agent) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _HeaderSection(agent: agent),
          const SizedBox(height: AppTheme.spacing24),

          // Basic Info Section
          _SectionCard(
            title: 'Basic Information',
            icon: Icons.info_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  label: 'Agent ID',
                  value: agent.id,
                  valueStyle: AppTheme.monoSmall,
                ),
                const SizedBox(height: AppTheme.spacing12),
                _InfoRow(
                  label: 'Name',
                  value: agent.name,
                ),
                if (agent.description != null) ...[
                  const SizedBox(height: AppTheme.spacing12),
                  _InfoRow(
                    label: 'Description',
                    value: agent.description!,
                    isMultiline: true,
                  ),
                ],
                if (agent.agentType != null) ...[
                  const SizedBox(height: AppTheme.spacing12),
                  _InfoRow(
                    label: 'Agent Type',
                    value: agent.agentType!,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing24),

          // Model Configuration Section
          if (agent.model != null)
            _SectionCard(
              title: 'Model Configuration',
              icon: Icons.psychology_outlined,
              child: _InfoRow(
                label: 'Model',
                value: agent.model!,
                valueStyle: AppTheme.monoSmall,
              ),
            ),
          const SizedBox(height: AppTheme.spacing24),

          // Timestamps Section
          _SectionCard(
            title: 'Timestamps',
            icon: Icons.schedule_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (agent.createdAt != null)
                  _InfoRow(
                    label: 'Created',
                    value: _formatDateTime(agent.createdAt!),
                  ),
                if (agent.createdAt != null && agent.modifiedAt != null)
                  const SizedBox(height: AppTheme.spacing12),
                if (agent.modifiedAt != null)
                  _InfoRow(
                    label: 'Last Modified',
                    value: _formatDateTime(agent.modifiedAt!),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing24),

          // System Prompt Section
          if (agent.systemPrompt != null && agent.systemPrompt!.isNotEmpty)
            _SectionCard(
              title: 'System Prompt',
              icon: Icons.message_outlined,
              child: Text(
                agent.systemPrompt!,
                style: AppTheme.bodyMedium.copyWith(
                  fontFamily: 'JetBrainsMono',
                  color: AppTheme.textSecondaryColor,
                ),
              ),
            ),
          const SizedBox(height: AppTheme.spacing24),

          // Configuration Section
          if (agent.config != null && agent.config!.isNotEmpty)
            _SectionCard(
              title: 'Configuration',
              icon: Icons.settings_outlined,
              child: _ConfigViewer(config: agent.config!),
            ),

          const SizedBox(height: AppTheme.spacing80),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Agent?'),
        content: const Text(
          'This action cannot be undone. Are you sure you want to delete this agent?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              try {
                await ref.read(deleteAgentProvider(agentId).future);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Agent deleted successfully'),
                      backgroundColor: AppTheme.primaryColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  // Invalidate the list to trigger refresh
                  ref.invalidate(agentListProvider);
                  // Navigate back to list
                  context.go('/agents');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete agent: $e'),
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final Agent agent;

  const _HeaderSection({required this.agent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppTheme.radiusLarge),
        ),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Agent Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.all(
                Radius.circular(AppTheme.radiusMedium),
              ),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.smart_toy_outlined,
              color: AppTheme.primaryColor,
              size: 40,
            ),
          ),
          const SizedBox(width: AppTheme.spacing24),

          // Agent Name and Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agent.name,
                  style: AppTheme.displaySmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (agent.description != null) ...[
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    agent.description!,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppTheme.radiusMedium),
        ),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariantColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusMedium),
                topRight: Radius.circular(AppTheme.radiusMedium),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: AppTheme.spacing8),
                Text(
                  title,
                  style: AppTheme.titleLarge,
                ),
              ],
            ),
          ),

          // Section Content
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final bool isMultiline;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueStyle,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelSmall.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacing4),
        Text(
          value,
          style: valueStyle ?? AppTheme.bodyMedium,
          maxLines: isMultiline ? null : 1,
          overflow: isMultiline ? null : TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ConfigViewer extends StatelessWidget {
  final Map<String, dynamic> config;

  const _ConfigViewer({required this.config});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: config.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(
            bottom: AppTheme.spacing12,
          ),
          child: _InfoRow(
            label: entry.key,
            value: entry.value.toString(),
            valueStyle: AppTheme.monoSmall,
            isMultiline: true,
          ),
        );
      }).toList(),
    );
  }
}
