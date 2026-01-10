import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
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
                          ExcludeSemantics(
                            child: Container(
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
                              tooltip: context.l10n.provider_card_delete_provider,
                              semanticLabel: context.l10n.provider_card_delete_provider,
                              semanticHint: context.l10n.provider_card_delete_hint,
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
                            label: _formatProviderType(context),
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
                        ],
                      ),

                      // Base URL (if available)
                      if (provider.baseUrl != null) ...[
                        const SizedBox(height: AppTheme.spacing12),
                        ExcludeSemantics(
                          child: Text(
                            provider.baseUrl!,
                            style: AppTheme.monoSmall.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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
    final type = _formatProviderType(context);
    final category = provider.providerCategory.toUpperCase();
    return context.l10n.provider_card_label(provider.name, type, category);
  }

  String _getCardHint(BuildContext context) {
    if (onDelete != null) {
      return context.l10n.provider_card_hint_with_delete;
    }
    return context.l10n.provider_card_hint_view_details;
  }

  String _formatProviderId(String id) {
    if (id.length > 20) {
      return '${id.substring(0, 17)}...';
    }
    return id;
  }

  String _formatProviderType(BuildContext context) {
    switch (provider.providerType.toLowerCase()) {
      case 'openai':
        return context.l10n.provider_type_openai;
      case 'anthropic':
        return context.l10n.provider_type_anthropic;
      case 'ollama':
        return context.l10n.provider_type_ollama;
      case 'google_ai':
        return context.l10n.provider_type_google_ai;
      case 'google_vertex':
        return context.l10n.provider_type_google_vertex;
      case 'letta':
        return context.l10n.provider_type_letta;
      default:
        return provider.providerType;
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
        return const Color(0xFF10A37F);
      case 'anthropic':
        return const Color(0xFFD97757);
      case 'ollama':
        return const Color(0xFF000000);
      case 'google_ai':
      case 'google_vertex':
        return const Color(0xFF4285F4);
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
    return Semantics(
      label: semanticLabel,
      button: true,
      hint: semanticHint,
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
    return MergeSemantics(
      child: Semantics(
        label: context.l10n.provider_card_type_label(label),
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
      ),
    );
  }
}
