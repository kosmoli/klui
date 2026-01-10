import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
                label: 'Agents',
                isSelected: currentPath == '/agents' ||
                    currentPath.startsWith('/agents/'),
                onTap: () => context.go('/agents'),
              ),
              _NavigationItem(
                icon: Icons.cloud_outlined,
                label: 'Providers',
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
  final bool isSelected;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label tab ${isSelected ? "(selected)" : ""}',
      button: true,
      selected: isSelected,
      hint: 'Double tap to navigate to $label page',
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
    );
  }
}
