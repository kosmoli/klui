import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/theme/klui_text_styles.dart';
import '../../../../core/theme/klui_theme_extension.dart';
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
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(context, ref),
      floatingActionButton: agentAsync.when(
        data: (agent) => FloatingActionButton.extended(
          onPressed: () => context.go('/chat?agentId=${agent.id}'),
          icon: const Icon(Icons.chat),
          label: Text(context.l10n.agent_detail_start_chat),
          backgroundColor: colors.userBubble,
          foregroundColor: colors.userText,
        ),
        loading: () => null,
        error: (_, __) => null,
      ),
      body: agentAsync.when(
        data: (agent) => _buildContent(context, agent),
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
                context.l10n.agent_detail_failed_to_load,
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
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      iconTheme: IconThemeData(color: colors.textPrimary),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: colors.textPrimary,
        onPressed: () => context.go('/agents'),
        tooltip: context.l10n.agent_detail_back_tooltip,
      ),
      title: Text(
        context.l10n.agent_detail_title,
        style: KluiTextStyles.headlineSmall.copyWith(
          color: colors.textPrimary,
        ),
      ),
      actions: [
        Tooltip(
          message: context.l10n.agent_detail_tooltip_edit,
          child: IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: colors.textPrimary,
            onPressed: () {
              // TODO: Implement edit
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.agent_detail_edit_coming_soon),
                  backgroundColor: colors.surfaceVariant,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
        Tooltip(
          message: context.l10n.agent_detail_tooltip_delete,
          child: IconButton(
            icon: const Icon(Icons.delete_outlined),
            color: colors.error,
            onPressed: () {
              final agentAsyncValue = ref.read(agentProvider(agentId));
              agentAsyncValue.when(
                data: (agent) => _showDeleteDialog(context, ref, agent),
                loading: () => {},
                error: (_, __) => {},
              );
            },
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildContent(BuildContext context, Agent agent) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _HeaderSection(agent: agent),
          const SizedBox(height: 24),

          // Basic Info Section
          _SectionCard(
            title: context.l10n.agent_detail_section_basic,
            icon: Icons.info_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  label: context.l10n.agent_detail_field_id,
                  value: agent.id,
                  valueStyle: KluiTextStyles.technical,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  label: context.l10n.agent_detail_field_name,
                  value: agent.name,
                  valueStyle: KluiTextStyles.bodyMedium,
                ),
                if (agent.description != null) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: context.l10n.agent_detail_field_description,
                    value: agent.description!,
                    valueStyle: KluiTextStyles.bodyMedium,
                    isMultiline: true,
                  ),
                ],
                if (agent.agentType != null) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: context.l10n.agent_detail_field_agent_type,
                    value: agent.agentType!,
                    valueStyle: KluiTextStyles.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Model Configuration Section (Base mode)
          if (agent.model != null)
            _SectionCard(
              title: context.l10n.agent_detail_section_model_base,
              icon: Icons.psychology_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    label: context.l10n.agent_detail_field_model_handle,
                    value: agent.model!,
                    valueStyle: KluiTextStyles.technical,
                  ),
                ],
              ),
            ),
          if (agent.model != null)
            const SizedBox(height: 24),

          // LLM Configuration Section (BYOK mode)
          if (agent.model == null && agent.llmConfig != null)
            _SectionCard(
              title: context.l10n.agent_detail_section_llm_byok,
              icon: Icons.psychology_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    label: context.l10n.agent_detail_field_model,
                    value: agent.llmConfig!['model']?.toString() ?? context.l10n.agent_detail_n_a,
                    valueStyle: KluiTextStyles.technical,
                  ),
                  if (agent.llmConfig!['provider_name'] != null) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: context.l10n.agent_detail_field_provider,
                      value: agent.llmConfig!['provider_name'].toString(),
                      valueStyle: KluiTextStyles.technical,
                    ),
                  ],
                  if (agent.llmConfig!['context_window'] != null) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: context.l10n.agent_detail_field_context_window,
                      value: context.l10n.agent_detail_context_window_tokens(agent.llmConfig!['context_window']),
                      valueStyle: KluiTextStyles.technical,
                    ),
                  ],
                ],
              ),
            ),
          if (agent.model == null && agent.llmConfig != null)
            const SizedBox(height: 24),

          // Embedding Configuration Section (all modes)
          if (agent.embeddingConfig != null)
            _SectionCard(
              title: context.l10n.agent_detail_section_embedding,
              icon: Icons.memory_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (agent.embeddingConfig!['embedding_model'] != null)
                    _InfoRow(
                      label: context.l10n.agent_detail_field_model,
                      value: agent.embeddingConfig!['embedding_model'].toString(),
                      valueStyle: KluiTextStyles.technical,
                    ),
                  if (agent.embeddingConfig!['provider_name'] != null) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: context.l10n.agent_detail_field_provider,
                      value: agent.embeddingConfig!['provider_name'].toString(),
                      valueStyle: KluiTextStyles.technical,
                    ),
                  ],
                  if (agent.embeddingConfig!['embedding_dim'] != null) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: context.l10n.agent_detail_field_embedding_dim,
                      value: agent.embeddingConfig!['embedding_dim'].toString(),
                      valueStyle: KluiTextStyles.technical,
                    ),
                  ],
                ],
              ),
            ),
          if (agent.embeddingConfig != null)
            const SizedBox(height: 24),

          // Embedding handle (new format)
          if (agent.embedding != null)
            _SectionCard(
              title: context.l10n.agent_detail_section_embedding,
              icon: Icons.memory_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    label: context.l10n.agent_detail_field_embedding_handle,
                    value: agent.embedding!,
                    valueStyle: KluiTextStyles.technical,
                  ),
                ],
              ),
            ),
          if (agent.embedding != null)
            const SizedBox(height: 24),

          // Tools Section
          if (agent.tools != null && agent.tools!.isNotEmpty)
            _SectionCard(
              title: context.l10n.agent_detail_section_tools,
              icon: Icons.build_outlined,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: agent.tools!.map((tool) => Chip(
                  label: Text(
                    tool,
                    style: KluiTextStyles.labelSmall,
                  ),
                  backgroundColor: colors.userBubble.withOpacity(0.1),
                  side: BorderSide(
                    color: colors.userBubble.withOpacity(0.3),
                    width: 1,
                  ),
                )).toList(),
              ),
            ),
          if (agent.tools != null && agent.tools!.isNotEmpty)
            const SizedBox(height: 24),

          // Tags Section
          if (agent.tags != null && agent.tags!.isNotEmpty)
            _SectionCard(
              title: context.l10n.agent_detail_section_tags,
              icon: Icons.label_outlined,
              child: agent.tags!.isEmpty
                  ? Text(context.l10n.agent_detail_no_tags, style: KluiTextStyles.bodyMedium.copyWith(color: colors.textSecondary))
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: agent.tags!.map((tag) => Chip(
                        label: Text(
                          tag,
                          style: KluiTextStyles.labelSmall,
                        ),
                        backgroundColor: colors.assistantBubble,
                        side: BorderSide(
                          color: colors.border,
                          width: 1,
                        ),
                      )).toList(),
                    ),
            ),
          if (agent.tags != null && agent.tags!.isNotEmpty)
            const SizedBox(height: 24),

          // Metadata Section
          if (agent.metadata != null && agent.metadata!.isNotEmpty)
            _SectionCard(
              title: context.l10n.agent_detail_section_metadata,
              icon: Icons.description_outlined,
              child: _ConfigViewer(config: agent.metadata!),
            ),
          if (agent.metadata != null && agent.metadata!.isNotEmpty)
            const SizedBox(height: 24),

          // Timestamps Section
          _SectionCard(
            title: context.l10n.agent_detail_section_timestamps,
            icon: Icons.schedule_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (agent.createdAt != null)
                  _InfoRow(
                    label: context.l10n.agent_detail_field_created,
                    value: _formatDateTime(agent.createdAt!),
                    valueStyle: KluiTextStyles.technical,
                  ),
                if (agent.createdAt != null && agent.modifiedAt != null)
                  const SizedBox(height: 12),
                if (agent.modifiedAt != null)
                  _InfoRow(
                    label: context.l10n.agent_detail_field_modified,
                    value: _formatDateTime(agent.modifiedAt!),
                    valueStyle: KluiTextStyles.technical,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // System Prompt Section
          if (agent.systemPrompt != null && agent.systemPrompt!.isNotEmpty)
            _SectionCard(
              title: context.l10n.agent_detail_section_system_prompt,
              icon: Icons.message_outlined,
              child: Text(
                agent.systemPrompt!,
                style: KluiTextStyles.bodyMedium.copyWith(
                  fontFamily: 'JetBrainsMono',
                  color: colors.textSecondary,
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Configuration Section
          if (agent.config != null && agent.config!.isNotEmpty)
            _SectionCard(
              title: context.l10n.agent_detail_section_config,
              icon: Icons.settings_outlined,
              child: _ConfigViewer(config: agent.config!),
            ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, Agent agent) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.agent_delete_confirm_title(agent.name)),
        content: Text(
          context.l10n.agent_delete_confirm_message,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.agent_cancel_button),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              try {
                await ref.read(deleteAgentProvider(agentId).future);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.agent_delete_success(agent.name ?? 'Agent')),
                      backgroundColor: colors.success,
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
                      content: Text(context.l10n.agent_detail_delete_failed(e.toString())),
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
            child: Text(context.l10n.agent_delete_button),
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
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
        border: Border.all(
          color: colors.border,
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
              color: colors.userBubble.withOpacity(0.1),
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
              border: Border.all(
                color: colors.userBubble.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.smart_toy_outlined,
              color: colors.userBubble,
              size: 40,
            ),
          ),
          const SizedBox(width: 24),

          // Agent Name and Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agent.name,
                  style: KluiTextStyles.displayLarge.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (agent.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    agent.description!,
                    style: KluiTextStyles.bodyMedium.copyWith(
                      color: colors.textSecondary,
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
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
        border: Border.all(
          color: colors.border,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border(
                bottom: BorderSide(
                  color: colors.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: colors.userBubble,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: KluiTextStyles.headlineMedium,
                ),
              ],
            ),
          ),

          // Section Content
          Padding(
            padding: const EdgeInsets.all(16),
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
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label (left side, fixed width)
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: KluiTextStyles.labelMedium.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Value (right side, flexible)
        Expanded(
          child: Text(
            value,
            style: (valueStyle ?? KluiTextStyles.bodyMedium).copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: isMultiline ? null : 3,
            overflow: isMultiline ? null : TextOverflow.ellipsis,
          ),
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
            bottom: 12,
          ),
          child: _InfoRow(
            label: entry.key,
            value: entry.value.toString(),
            valueStyle: KluiTextStyles.technical,
            isMultiline: true,
          ),
        );
      }).toList(),
    );
  }
}
