import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/app_theme.dart';

/// Main bottom navigation bar for the app
class MainNavigation extends StatelessWidget {
  final String currentPath;

  const MainNavigation({
    super.key,
    required this.currentPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          top: BorderSide(
            color: AppTheme.borderColor,
            width: 2,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavigationItem(
                icon: Icons.smart_toy_outlined,
                label: context.l10n.nav_agents,
                semanticLabel: context.l10n.nav_agents_tab,
                isSelected: currentPath == '/agents' ||
                    currentPath.startsWith('/agents/'),
                onTap: () => context.go('/agents'),
              ),
              _NavigationItem(
                icon: Icons.cloud_outlined,
                label: context.l10n.nav_providers,
                semanticLabel: context.l10n.nav_providers_tab,
                isSelected: currentPath == '/providers' ||
                    currentPath.startsWith('/providers/'),
                onTap: () => context.go('/providers'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String semanticLabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.semanticLabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use MergeSemantics to combine icon + text into one semantic unit
    return MergeSemantics(
      child: Semantics(
        label: semanticLabel,
        button: true,
        selected: isSelected,
        hint: context.l10n.nav_hint_navigate(label),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
              vertical: AppTheme.spacing12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              border: isSelected
                  ? Border(
                      top: BorderSide(
                        color: AppTheme.primaryColor,
                        width: 3,
                      ),
                    )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                  size: 24,
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  label,
                  style: AppTheme.labelSmall.copyWith(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
