import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/theme/klui_text_styles.dart';
import '../../../../core/theme/klui_theme_extension.dart';
import '../../../../core/models/provider.dart';

/// Provider Detail Screen with Neo-Brutalist design
///
/// Displays comprehensive information about a single Provider including:
/// - Basic info (name, type, category)
/// - Configuration (base URL, region, project)
/// - Credentials (masked API key, access key)
/// - Tags and metadata
class ProviderDetailScreen extends ConsumerWidget {
  final String providerId;

  const ProviderDetailScreen({
    super.key,
    required this.providerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerAsync = ref.watch(providerProvider(providerId));
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(context, ref),
      body: providerAsync.when(
        data: (provider) => _buildContent(context, provider),
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
                context.l10n.provider_detail_failed_to_load,
                style: KluiTextStyles.headlineSmall,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                ),
                child: Text(
                  error.toString(),
                  style: KluiTextStyles.bodySmall.copyWith(
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
        onPressed: () => context.go('/providers'),
        tooltip: context.l10n.provider_detail_back_tooltip,
      ),
      title: Text(
        context.l10n.provider_detail_title,
        style: KluiTextStyles.headlineSmall.copyWith(
          color: colors.textPrimary,
        ),
      ),
      actions: [
        Tooltip(
          message: context.l10n.provider_detail_tooltip_edit,
          child: IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: colors.textPrimary,
            onPressed: () {
              // TODO: Implement edit
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.provider_detail_edit_coming_soon),
                  backgroundColor: colors.surfaceVariant,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildContent(BuildContext context, ProviderConfig provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _HeaderSection(provider: provider),
          const SizedBox(height: 24),

          // Basic Info Section
          _SectionCard(
            title: context.l10n.provider_detail_section_basic,
            icon: Icons.info_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  label: context.l10n.provider_detail_field_id,
                  value: provider.id,
                  valueStyle: KluiTextStyles.technical,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  label: context.l10n.provider_detail_field_name,
                  value: provider.name,
                  valueStyle: KluiTextStyles.bodyMedium,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  label: context.l10n.provider_detail_field_type,
                  value: provider.providerType,
                  valueStyle: KluiTextStyles.bodyMedium,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  label: context.l10n.provider_detail_field_category,
                  value: provider.providerCategory == 'base'
                      ? context.l10n.provider_detail_category_base
                      : context.l10n.provider_detail_category_byok,
                  valueStyle: KluiTextStyles.bodyMedium,
                ),
                if (provider.organizationId != null) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: context.l10n.provider_detail_field_organization_id,
                    value: provider.organizationId!,
                    valueStyle: KluiTextStyles.technical,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Configuration Section
          if (provider.baseUrl != null || provider.region != null)
            _SectionCard(
              title: context.l10n.provider_detail_section_config,
              icon: Icons.settings_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (provider.baseUrl != null)
                    _InfoRow(
                      label: context.l10n.provider_detail_field_base_url,
                      value: provider.baseUrl!,
                      valueStyle: KluiTextStyles.technical,
                      isMultiline: true,
                    ),
                  if (provider.baseUrl != null && provider.region != null)
                    const SizedBox(height: 12),
                  if (provider.region != null)
                    _InfoRow(
                      label: context.l10n.provider_detail_field_region,
                      value: provider.region!,
                      valueStyle: KluiTextStyles.bodyMedium,
                    ),
                ],
              ),
            ),
          if (provider.baseUrl != null || provider.region != null)
            const SizedBox(height: 24),

          // Timestamp Section
          if (provider.updatedAt != null)
            _SectionCard(
              title: context.l10n.agent_detail_section_timestamps,
              icon: Icons.schedule_outlined,
              child: _InfoRow(
                label: context.l10n.provider_detail_field_updated_at,
                value: _formatDateTime(provider.updatedAt!),
                valueStyle: KluiTextStyles.technical,
              ),
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
}

/// Header Section
class _HeaderSection extends StatelessWidget {
  final ProviderConfig provider;

  const _HeaderSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getProviderColor(context, provider.providerType).withOpacity(0.1),
                borderRadius: const BorderRadius.all(
                  Radius.circular(8),
                ),
              ),
              child: Icon(
                _getProviderIcon(provider.providerType),
                color: _getProviderColor(context, provider.providerType),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    style: KluiTextStyles.headlineMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.providerType,
                    style: KluiTextStyles.bodyMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  IconData _getProviderIcon(String providerType) {
    switch (providerType.toLowerCase()) {
      case 'openai':
        return Icons.psychology_outlined;
      case 'anthropic':
        return Icons.smart_toy_outlined;
      case 'ollama':
        return Icons.computer_outlined;
      case 'google_ai':
      case 'google_vertex':
        return Icons.search_outlined;
      default:
        return Icons.cloud_outlined;
    }
  }

  Color _getProviderColor(BuildContext context, String providerType) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    switch (providerType.toLowerCase()) {
      case 'openai':
        return const Color(0xFF10A37F);
      case 'anthropic':
        return const Color(0xFFD4915D);
      case 'ollama':
        return const Color(0xFF000000);
      case 'google_ai':
      case 'google_vertex':
        return const Color(0xFF4285F4);
      default:
        return colors.userBubble;
    }
  }
}

/// Section Card Widget
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
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(icon, size: 20, color: colors.textSecondary),
              const SizedBox(width: 8),
              Text(
                title,
                style: KluiTextStyles.headlineSmall.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

/// Info Row Widget
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle valueStyle;
  final bool isMultiline;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.valueStyle,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: KluiTextStyles.labelSmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: valueStyle.copyWith(
            color: colors.textPrimary,
          ),
          maxLines: isMultiline ? null : 1,
          overflow: isMultiline ? null : TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Config Viewer Widget (JSON viewer)
class _ConfigViewer extends StatelessWidget {
  final Map<String, dynamic> config;

  const _ConfigViewer({required this.config});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: const BorderRadius.all(
          Radius.circular(4),
        ),
        border: Border.all(
          color: colors.border,
          width: 1,
        ),
      ),
      child: Text(
        _formatConfig(config),
        style: KluiTextStyles.technical.copyWith(
          fontFamily: 'JetBrainsMono',
          color: colors.textPrimary,
        ),
      ),
    );
  }

  String _formatConfig(Map<String, dynamic> map, [int indent = 0]) {
    final spacer = '  ' * indent;
    final buffer = StringBuffer();

    if (map.isEmpty) {
      return '{}';
    }

    buffer.write('{\n');
    final entries = map.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.write('$spacer${entry.key}: ');
      if (entry.value is Map) {
        buffer.write(_formatConfig(
          Map<String, dynamic>.from(entry.value as Map),
          indent + 1,
        ));
      } else if (entry.value is String) {
        buffer.write('"${entry.value}"');
      } else {
        buffer.write(entry.value.toString());
      }
      if (i < entries.length - 1) {
        buffer.write(',');
      }
      buffer.write('\n');
    }
    buffer.write('$spacer}');
    return buffer.toString();
  }
}
