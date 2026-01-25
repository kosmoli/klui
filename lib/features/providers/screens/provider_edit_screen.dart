import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/klui_theme_extension.dart';
import '../../providers/widgets/provider_form.dart';

/// Screen for editing a Provider
class ProviderEditScreen extends ConsumerWidget {
  final String providerId;

  const ProviderEditScreen({
    super.key,
    required this.providerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerAsync = ref.watch(providerProvider(providerId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/providers'),
        ),
        title: Text(context.l10n.provider_edit_title),
      ),
      body: providerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(context.l10n.provider_detail_failed_to_load),
        ),
        data: (provider) => ProviderEditForm(
          initialData: provider,
          onSubmit: (request) async {
            try {
              // Show loading dialog
              if (context.mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) => Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(AppTheme.spacing24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: AppTheme.spacing16),
                            Text(context.l10n.provider_create_creating),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }

              // Update provider
              await ref.read(updateProviderProvider(
                id: providerId,
                request: request,
              ).future);

              // Invalidate provider list cache to trigger refresh
              ref.invalidate(providerListProvider);
              ref.invalidate(providerProvider(providerId));

              // Close loading dialog
              if (context.mounted) {
                Navigator.of(context).pop();
              }

              // Show success message
              if (context.mounted) {
                final colors = Theme.of(context).extension<KluiCustomColors>()!;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      context.l10n.provider_edit_success(request.name),
                      style: TextStyle(color: colors.userText),
                    ),
                    backgroundColor: colors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                // Navigate back to provider list
                context.go('/providers');
              }
            } catch (e) {
              // Close loading dialog
              if (context.mounted) {
                Navigator.of(context).pop();
              }

              // Parse error message
              String errorMessage;
              final errorString = e.toString();

              if (errorString.contains('unique constraint') ||
                  errorString.contains('UniqueViolationError') ||
                  errorString.contains('duplicate key')) {
                final nameMatch = RegExp(r'\(name, organization_id\)=\(([^,]+)').firstMatch(errorString);
                final duplicateName = nameMatch?.group(1) ?? request.name;
                errorMessage = 'Provider "$duplicateName" already exists. Please use a different name.';
              } else if (errorString.contains('Exception:')) {
                errorMessage = errorString.replaceAll('Exception: ', '');
                if (errorMessage.length > 200) {
                  errorMessage = '${errorMessage.substring(0, 200)}...';
                }
              } else {
                errorMessage = errorString;
              }

              // Show error message
              if (context.mounted) {
                final colors = Theme.of(context).extension<KluiCustomColors>()!;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      errorMessage,
                      style: TextStyle(color: colors.userText),
                    ),
                    backgroundColor: colors.error,
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: context.l10n.agent_cancel_button,
                      textColor: colors.userText,
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                    ),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
