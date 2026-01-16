import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/provider.dart';
import '../../../core/theme/klui_text_styles.dart';
import '../../../core/theme/klui_theme_extension.dart';

/// A Neo-Brutalist card component for displaying Provider information
///
/// Design Features:
/// - High contrast borders with tech-inspired styling
/// - Monospace font for technical details (ID, dates)
/// - Provider type indicators with distinct colors
/// - Hover effects and subtle animations
///
/// In Memos, all providers are user-created (no BYOK/base category distinction)
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
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

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
                borderRadius: const BorderRadius.all(
                  Radius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                                color: colors.userBubble.withOpacity(0.1),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8),
                                ),
                                border: Border.all(
                                  color: colors.userBubble.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                _getProviderTypeIcon(),
                                color: colors.userBubble,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Provider Name
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.name,
                                  style: KluiTextStyles.headlineMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatProviderId(provider.id),
                                  style: KluiTextStyles.technical,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Action Buttons
                          if (onDelete != null) ...[
                            const SizedBox(width: 8),
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

                      // Footer: Type Badge only (no category in Memos)
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Provider Type Badge
                          _InfoChip(
                            icon: Icons.cloud_outlined,
                            label: _formatProviderType(context),
                            color: colors.userBubble,
                          ),

                          const Spacer(),
                        ],
                      ),

                      // Base URL (if available)
                      if (provider.baseUrl != null) ...[
                        const SizedBox(height: 12),
                        ExcludeSemantics(
                          child: Text(
                            provider.baseUrl!,
                            style: KluiTextStyles.technical.copyWith(
                              color: colors.textSecondary,
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
    return context.l10n.provider_card_label(provider.name, type);
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

    return Semantics(
      label: semanticLabel,
      button: true,
      hint: semanticHint,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDestructive
                  ? colors.error.withOpacity(0.1)
                  : colors.userBubble.withOpacity(0.1),
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
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
              color: isDestructive ? colors.error : colors.userBubble,
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
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    final chipColor = color ?? colors.userBubble;

    return MergeSemantics(
      child: Semantics(
        label: context.l10n.provider_card_type_label(label),
        container: true,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: chipColor.withOpacity(0.1),
            borderRadius: const BorderRadius.all(
              Radius.circular(6),
            ),
            border: Border.all(
              color: chipColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: chipColor,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: KluiTextStyles.labelSmall.copyWith(
                  color: chipColor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'JetBrains Mono',
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
