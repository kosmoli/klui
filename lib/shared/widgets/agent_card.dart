import 'package:flutter/material.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/models/agent.dart';
import '../../core/theme/klui_text_styles.dart';
import '../../core/theme/klui_theme_extension.dart';

/// A Neo-Brutalist card component for displaying Agent information
///
/// Design Features:
/// - High contrast borders with tech-inspired styling
/// - Monospace font for technical details (ID, dates)
/// - Status indicators with neon colors
/// - Hover effects and subtle animations
class AgentCard extends StatelessWidget {
  final Agent agent;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AgentCard({
    super.key,
    required this.agent,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    // 根据标准，优先使用MergeSemantics组合图标+文字
    return MergeSemantics(
      child: Semantics(
        label: _getCardLabel(context),
        button: onTap != null,
        link: onTap != null,
        hint: _getCardHint(context),
        child: MouseRegion(
          cursor: onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
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
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Name + Actions
                      Row(
                        children: [
                          // Agent Icon (纯装饰，用ExcludeSemantics)
                          ExcludeSemantics(
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: colors.userBubble.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: colors.userBubble.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.smart_toy_outlined,
                                color: colors.userBubble,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Agent Name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  agent.name,
                                  style: KluiTextStyles.headlineMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatAgentId(agent.id),
                                  style: KluiTextStyles.technical,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Action Buttons
                          if (onEdit != null || onDelete != null) ...[
                            const SizedBox(width: 8),
                            if (onEdit != null)
                              _ActionButton(
                                icon: Icons.edit_outlined,
                                onPressed: onEdit,
                                tooltip: context.l10n.agent_action_edit,
                                semanticLabel: context.l10n.agent_action_edit,
                                semanticHint: context.l10n.agent_action_edit_hint,
                              ),
                            if (onDelete != null)
                              _ActionButton(
                                icon: Icons.delete_outlined,
                                onPressed: onDelete,
                                tooltip: context.l10n.agent_action_delete,
                                semanticLabel: context.l10n.agent_action_delete,
                                semanticHint: context.l10n.agent_action_delete_hint,
                                isDestructive: true,
                              ),
                          ],
                        ],
                      ),

                      // Description
                      if (agent.description != null && agent.description!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          agent.description!,
                          style: KluiTextStyles.bodySmall.copyWith(
                            color: colors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Footer: Model
                      const SizedBox(height: 12),
                      if (agent.model != null || agent.llmConfig != null)
                        _InfoChip(
                          icon: Icons.psychology_outlined,
                          label: _getModelLabel(context, agent),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getCardLabel(BuildContext context) {
    final type = agent.agentType ?? context.l10n.agent_card_not_specified;
    final model = agent.model ?? context.l10n.agent_card_not_specified;
    return context.l10n.agent_card_label(agent.name, type, model);
  }

  String _getCardHint(BuildContext context) {
    if (onEdit != null && onDelete != null) {
      return context.l10n.agent_card_hint_with_actions;
    } else if (onEdit != null) {
      return context.l10n.agent_card_hint_with_edit;
    } else if (onDelete != null) {
      return context.l10n.agent_card_hint_with_delete;
    }
    return context.l10n.agent_card_hint_view_details;
  }

  String _formatAgentId(String id) {
    // Shorten ID: agent-4c89dcfa... -> agent-4c89...
    if (id.length > 20) {
      return '${id.substring(0, 17)}...';
    }
    return id;
  }

  String _getModelLabel(BuildContext context, Agent agent) {
    // Base mode: use agent.model (handle format)
    if (agent.model != null) {
      return agent.model!;
    }

    // BYOK mode: construct handle from provider_name + model
    if (agent.llmConfig != null) {
      final provider = agent.llmConfig!['provider_name']?.toString() ?? 'unknown';
      final model = agent.llmConfig!['model']?.toString() ?? 'unknown';
      return '$provider/$model';
    }

    return context.l10n.agent_card_model_unknown;
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final String semanticLabel;
  final String semanticHint;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    required this.semanticLabel,
    required this.semanticHint,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    // IconButton是标准widget，已经有Semantics
    // 但我们需要自定义label以符合i18n标准
    return Semantics(
      label: semanticLabel,
      button: true,
      hint: semanticHint,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDestructive
                  ? colors.error.withOpacity(0.1)
                  : colors.userBubble.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDestructive
                    ? colors.error.withOpacity(0.3)
                    : colors.userBubble.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isDestructive
                  ? colors.error
                  : colors.userBubble,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    // 使用MergeSemantics组合图标+文字
    return MergeSemantics(
      child: Semantics(
        label: label,
        container: true,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: colors.border,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: colors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: KluiTextStyles.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
