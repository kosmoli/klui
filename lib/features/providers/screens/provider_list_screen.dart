import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/klui_theme_extension.dart';
import '../../../shared/widgets/retro_drawer.dart';
import '../../../shared/widgets/retro_menu_button.dart';
import '../widgets/provider_card.dart';

/// Screen displaying list of Providers with Neo-Brutalist design
class ProviderListScreen extends ConsumerStatefulWidget {
  const ProviderListScreen({super.key});

  @override
  ConsumerState<ProviderListScreen> createState() => _ProviderListScreenState();
}

class _ProviderListScreenState extends ConsumerState<ProviderListScreen> {
  @override
  Widget build(BuildContext context) {
    final providersAsync = ref.watch(providerListProvider);
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Scaffold(
      drawer: const RetroDrawer(),
      appBar: AppBar(
        leading: const RetroMenuButton(),
        title: Text(context.l10n.provider_list_title),
        toolbarHeight: 48, // Reduced from default 56
        actions: [
          // Back to Chat button
          IconButton(
            onPressed: () => context.go('/chat'),
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Back to Chat',
            style: IconButton.styleFrom(
              backgroundColor: colors.userBubble.withOpacity(0.1),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: providersAsync.when(
        data: (providers) {
          // Filter out base providers, only show BYOK providers (user-created)
          final byokProviders = providers
              .where((p) => p.providerCategory == 'byok')
              .toList();

          if (byokProviders.isEmpty) {
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
                        Icons.cloud_off_outlined,
                        size: 64,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing24),
                  Text(
                    context.l10n.provider_list_no_providers,
                    style: AppTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    context.l10n.provider_list_create_first,
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
            itemCount: byokProviders.length,
            itemBuilder: (context, index) {
              final provider = byokProviders[index];
              return ProviderCard(
                provider: provider,
                onTap: () {
                  context.push('/providers/${provider.id}');
                },
                onDelete: () {
                  _showDeleteDialog(context, provider, ref);
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
                context.l10n.provider_list_error_loading,
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
                  ref.invalidate(providerListProvider);
                },
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.provider_list_retry),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Semantics(
        label: context.l10n.provider_list_create_button,
        button: true,
        hint: context.l10n.provider_list_create_button,
        child: FloatingActionButton.extended(
          onPressed: () => context.go('/providers/create'),
          icon: const Icon(Icons.add),
          label: Text(context.l10n.provider_list_create_button),
        ),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    dynamic provider,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.provider_delete_confirm_title(provider.name)),
        content: Text(context.l10n.provider_delete_confirm_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.provider_cancel_button),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              try {
                await ref.read(deleteProviderProvider(provider.id).future);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.provider_delete_success(provider.name)),
                      backgroundColor: AppTheme.primaryColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  ref.invalidate(providerListProvider);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.provider_delete_failed(provider.name, e.toString())),
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
            child: Text(context.l10n.provider_delete_button),
          ),
        ],
      ),
    );
  }
}
