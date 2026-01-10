import 'package:flutter/material.dart';
import '../../../core/models/provider.dart';
import '../../../core/theme/app_theme.dart';

/// A Neo-Brutalist card component for displaying Provider information
///
/// Design Features:
/// - High contrast borders with tech-inspired styling
/// - Monospace font for technical details (ID, dates)
/// - Provider type indicators with distinct colors
/// - Hover effects and subtle animations
class ProviderCard extends StatelessWidget {
  final ProviderConfig provider;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ProviderCard({
    super.key,
    required this.provider,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Provider card: ${provider.name}, type: ${_formatProviderType(provider.providerType)}, category: ${provider.providerCategory.toUpperCase()}',
      button: onTap != null,
      link: onTap != null,
      hint: onDelete != null ? 'Double tap to view details, has delete button' : 'Double tap to view details',
      child: MouseRegion(
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
                      // Provider Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getProviderTypeColor().withOpacity(0.1),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(AppTheme.radiusSmall),
                          ),
                          border: Border.all(
                            color: _getProviderTypeColor().withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          _getProviderTypeIcon(),
                          color: _getProviderTypeColor(),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing12),

                      // Provider Name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.name,
                              style: AppTheme.titleMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppTheme.spacing4),
                            Text(
                              _formatProviderId(provider.id),
                              style: AppTheme.monoSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Action Buttons
                      if (onDelete != null) ...[
                        const SizedBox(width: AppTheme.spacing8),
                        _ActionButton(
                          icon: Icons.delete_outlined,
                          onPressed: onDelete,
                          tooltip: 'Delete',
                          isDestructive: true,
                        ),
                      ],
                    ],
                  ),

                  // Footer: Type + Category + Updated Date
                  const SizedBox(height: AppTheme.spacing12),
                  Row(
                    children: [
                      // Provider Type Badge
                      _InfoChip(
                        icon: Icons.cloud_outlined,
                        label: _formatProviderType(provider.providerType),
                        color: _getProviderTypeColor(),
                      ),
                      const SizedBox(width: AppTheme.spacing8),

                      // Provider Category Badge
                      _InfoChip(
                        icon: provider.providerCategory == 'base'
                            ? Icons.memory_outlined
                            : Icons.storage_outlined,
                        label: provider.providerCategory.toUpperCase(),
                        color: provider.providerCategory == 'base'
                            ? AppTheme.primaryColor
                            : AppTheme.secondaryColor,
                      ),

                      const Spacer(),

                      // Updated Date
                      if (provider.updatedAt != null)
                        Text(
                          _formatDate(provider.updatedAt!),
                          style: AppTheme.monoSmall,
                        ),
                    ],
                  ),

                  // Base URL (if available)
                  if (provider.baseUrl != null) ...[
                    const SizedBox(height: AppTheme.spacing12),
                    Text(
                      provider.baseUrl!,
                      style: AppTheme.monoSmall.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }

  String _formatProviderId(String id) {
    // Shorten ID: provider-4c89dcfa... -> provider-4c89...
    if (id.length > 20) {
      return '${id.substring(0, 17)}...';
    }
    return id;
  }

  String _formatDate(DateTime date) {
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

  String _formatProviderType(String type) {
    // Convert provider_type to display name
    switch (type.toLowerCase()) {
      case 'openai':
        return 'OpenAI';
      case 'anthropic':
        return 'Anthropic';
      case 'ollama':
        return 'Ollama';
      case 'google_ai':
        return 'Google AI';
      case 'google_vertex':
        return 'Google Vertex';
      case 'letta':
        return 'Letta';
      default:
        return type;
    }
  }

  IconData _getProviderTypeIcon() {
    switch (provider.providerType.toLowerCase()) {
      case 'openai':
        return Icons.psychology_outlined;
      case 'anthropic':
        return Icons.auto_awesome_outlined;
      case 'ollama':
        return Icons.pets_outlined;
      case 'google_ai':
      case 'google_vertex':
        return Icons.search_outlined;
      case 'letta':
        return Icons.smart_toy_outlined;
      default:
        return Icons.cloud_outlined;
    }
  }

  Color _getProviderTypeColor() {
    switch (provider.providerType.toLowerCase()) {
      case 'openai':
        return const Color(0xFF10A37F); // OpenAI green
      case 'anthropic':
        return const Color(0xFFD97757); // Anthropic orange
      case 'ollama':
        return const Color(0xFF000000); // Ollama black
      case 'google_ai':
      case 'google_vertex':
        return const Color(0xFF4285F4); // Google blue
      case 'letta':
        return AppTheme.primaryColor;
      default:
        return AppTheme.textSecondaryColor;
    }
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
    return Semantics(
      label: 'Delete provider',
      button: true,
      hint: 'Double tap to delete provider ${isDestructive ? "(destructive action)" : ""}',
      child: Tooltip(
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
            color: isDestructive ? AppTheme.errorColor : AppTheme.primaryColor,
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
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label provider type',
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing8,
          vertical: AppTheme.spacing4,
        ),
        decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: const BorderRadius.all(
          Radius.circular(AppTheme.radiusSmall),
        ),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: AppTheme.spacing4),
          Text(
            label,
            style: AppTheme.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      ),
    );
  }
}
