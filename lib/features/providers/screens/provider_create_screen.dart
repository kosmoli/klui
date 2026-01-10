import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/provider_form.dart';

/// Screen for creating a new Provider with multi-step wizard
class ProviderCreateScreen extends ConsumerWidget {
  const ProviderCreateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.provider_create_title),
      ),
      body: ProviderCreateForm(
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

            // Create provider
            await ref.read(createProviderProvider(request).future);

            // Invalidate provider list cache to trigger refresh
            ref.invalidate(providerListProvider);

            // Close loading dialog
            if (context.mounted) {
              Navigator.of(context).pop();
            }

            // Show success message
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.provider_create_success(request.name)),
                  backgroundColor: AppTheme.primaryColor,
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

            // Show error message
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.provider_create_failed(e.toString())),
                  backgroundColor: AppTheme.errorColor,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: context.l10n.agent_cancel_button,
                    textColor: Colors.white,
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
    );
  }
}
