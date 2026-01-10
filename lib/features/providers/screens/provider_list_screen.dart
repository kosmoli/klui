import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/main_navigation.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Providers'),
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
                  Container(
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
                  const SizedBox(height: AppTheme.spacing24),
                  Text(
                    'No BYOK providers found',
                    style: AppTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    'Create a custom provider to use your own API keys',
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
                  // TODO: Navigate to provider detail
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Provider details for ${provider.name} - Coming soon!'),
                      backgroundColor: AppTheme.surfaceVariantColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
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
                'Error loading providers',
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
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/providers/create'),
        icon: const Icon(Icons.add),
        label: const Text('Create Provider'),
      ),
      bottomNavigationBar: MainNavigation(currentPath: '/providers'),
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
        title: Text('Delete ${provider.name}?'),
        content: Text(
          'This action cannot be undone. Are you sure you want to delete this provider?',
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
                await ref.read(deleteProviderProvider(provider.id).future);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${provider.name} deleted successfully'),
                      backgroundColor: AppTheme.primaryColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  // Refresh the list
                  ref.invalidate(providerListProvider);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete ${provider.name}: $e'),
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
