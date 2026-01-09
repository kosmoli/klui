import 'package:flutter/material.dart';
import '../../core/models/agent.dart';
import '../../core/theme/app_theme.dart';

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
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing8,
          ),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(AppTheme.radiusMedium),
            ),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.all(
              Radius.circular(AppTheme.radiusMedium),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Name + Actions
                  Row(
                    children: [
                      // Agent Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(AppTheme.radiusSmall),
                          ),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.smart_toy_outlined,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing12),

                      // Agent Name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              agent.name,
                              style: AppTheme.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppTheme.spacing4),
                            Text(
                              _formatAgentId(agent.id),
                              style: AppTheme.monoSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Action Buttons
                      if (onEdit != null || onDelete != null) ...[
                        const SizedBox(width: AppTheme.spacing8),
                        if (onEdit != null)
                          _ActionButton(
                            icon: Icons.edit_outlined,
                            onPressed: onEdit,
                            tooltip: 'Edit',
                          ),
                        if (onDelete != null)
                          _ActionButton(
                            icon: Icons.delete_outlined,
                            onPressed: onDelete,
                            tooltip: 'Delete',
                            isDestructive: true,
                          ),
                      ],
                    ],
                  ),

                  // Description
                  if (agent.description != null && agent.description!.isNotEmpty) ...[
                    const SizedBox(height: AppTheme.spacing12),
                    Text(
                      agent.description!,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Footer: Model + Created Date
                  const SizedBox(height: AppTheme.spacing12),
                  Row(
                    children: [
                      // Model Tag
                      // Base mode: agent.model (handle format, e.g., "openai-proxy/claude-sonnet-4")
                      // BYOK mode: construct from provider_name + model
                      if (agent.model != null || agent.llmConfig != null)
                        _InfoChip(
                          icon: Icons.psychology_outlined,
                          label: _getModelLabel(agent),
                        ),
                      if (agent.model != null || agent.llmConfig != null) const Spacer(),
                      // Created Date
                      Text(
                        _formatDate(agent.createdAt),
                        style: AppTheme.monoSmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatAgentId(String id) {
    // Shorten ID: agent-4c89dcfa... -> agent-4c89...
    if (id.length > 20) {
      return '${id.substring(0, 17)}...';
    }
    return id;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _getModelLabel(Agent agent) {
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

    return 'Unknown';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppTheme.radiusSmall),
        ),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacing8),
          decoration: BoxDecoration(
            color: isDestructive
                ? AppTheme.errorColor.withOpacity(0.1)
                : AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: const BorderRadius.all(
              Radius.circular(AppTheme.radiusSmall),
            ),
            border: Border.all(
              color: isDestructive
                  ? AppTheme.errorColor.withOpacity(0.3)
                  : AppTheme.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDestructive
                ? AppTheme.errorColor
                : AppTheme.primaryColor,
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing8,
        vertical: AppTheme.spacing4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariantColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppTheme.radiusSmall),
        ),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppTheme.textSecondaryColor,
          ),
          const SizedBox(width: AppTheme.spacing4),
          Text(
            label,
            style: AppTheme.labelSmall.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
