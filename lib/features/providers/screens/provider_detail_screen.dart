import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/theme/app_theme.dart';
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

    return Scaffold(
      appBar: _buildAppBar(context, ref),
      body: providerAsync.when(
        data: (provider) => _buildContent(context, provider),
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
                context.l10n.provider_detail_failed_to_load,
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
        onPressed: () => context.go('/providers'),
        tooltip: context.l10n.provider_detail_back_tooltip,
      ),
      title: Text(context.l10n.provider_detail_title),
      actions: [
        Tooltip(
          message: context.l10n.provider_detail_tooltip_edit,
          child: IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: Implement edit
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.provider_detail_edit_coming_soon),
                  backgroundColor: AppTheme.surfaceVariantColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: AppTheme.spacing8),
      ],
    );
  }

  Widget _buildContent(BuildContext context, ProviderConfig provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _HeaderSection(provider: provider),
          const SizedBox(height: AppTheme.spacing24),

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
                  valueStyle: AppTheme.monoSmall,
                ),
                const SizedBox(height: AppTheme.spacing12),
                _InfoRow(
                  label: context.l10n.provider_detail_field_name,
                  value: provider.name,
                  valueStyle: AppTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spacing12),
                _InfoRow(
                  label: context.l10n.provider_detail_field_type,
                  value: provider.providerType,
                  valueStyle: AppTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spacing12),
                _InfoRow(
                  label: context.l10n.provider_detail_field_category,
                  value: provider.providerCategory == 'base'
                      ? context.l10n.provider_detail_category_base
                      : context.l10n.provider_detail_category_byok,
                  valueStyle: AppTheme.bodyMedium,
                ),
                if (provider.organizationId != null) ...[
                  const SizedBox(height: AppTheme.spacing12),
                  _InfoRow(
                    label: context.l10n.provider_detail_field_organization_id,
                    value: provider.organizationId!,
                    valueStyle: AppTheme.monoSmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing24),

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
                      valueStyle: AppTheme.monoSmall,
                      isMultiline: true,
                    ),
                  if (provider.baseUrl != null && provider.region != null)
                    const SizedBox(height: AppTheme.spacing12),
                  if (provider.region != null)
                    _InfoRow(
                      label: context.l10n.provider_detail_field_region,
                      value: provider.region!,
                      valueStyle: AppTheme.bodyMedium,
                    ),
                ],
              ),
            ),
          if (provider.baseUrl != null || provider.region != null)
            const SizedBox(height: AppTheme.spacing24),

          // Timestamp Section
          if (provider.updatedAt != null)
            _SectionCard(
              title: context.l10n.agent_detail_section_timestamps,
              icon: Icons.schedule_outlined,
              child: _InfoRow(
                label: context.l10n.provider_detail_field_updated_at,
                value: _formatDateTime(provider.updatedAt!),
                valueStyle: AppTheme.monoSmall,
              ),
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
}

/// Header Section
class _HeaderSection extends StatelessWidget {
  final ProviderConfig provider;

  const _HeaderSection({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: _getProviderColor(provider.providerType).withOpacity(0.1),
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: Icon(
                _getProviderIcon(provider.providerType),
                color: _getProviderColor(provider.providerType),
                size: 32,
              ),
            ),
            const SizedBox(width: AppTheme.spacing16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.name,
                    style: AppTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppTheme.spacing4),
                  Text(
                    provider.providerType,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondaryColor,
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

  Color _getProviderColor(String providerType) {
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
        return AppTheme.primaryColor;
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
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
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
          Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.textSecondaryColor),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                title,
                style: AppTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
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
          style: valueStyle,
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
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing12),
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
      child: Text(
        _formatConfig(config),
        style: AppTheme.monoSmall.copyWith(
          fontFamily: 'JetBrainsMono',
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
