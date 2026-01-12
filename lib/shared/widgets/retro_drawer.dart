import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/extensions/context_extensions.dart';
import '../../core/theme/klui_text_styles.dart';
import '../../core/theme/klui_theme_extension.dart';

/// Retro-style drawer menu with CRT terminal aesthetic
/// Slides in from left with Neo-Brutalist design
class RetroDrawer extends StatelessWidget {
  const RetroDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Drawer(
      backgroundColor: colors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _DrawerHeader(colors: colors),

            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFF2A2A2A),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerMenuItem(
                    icon: Icons.smart_toy_outlined,
                    label: context.l10n.nav_agents,
                    semanticLabel: context.l10n.nav_agents_hint,
                    route: '/agents',
                    colors: colors,
                  ),
                  _DrawerMenuItem(
                    icon: Icons.cloud_outlined,
                    label: context.l10n.nav_providers,
                    semanticLabel: context.l10n.nav_providers_hint,
                    route: '/providers',
                    colors: colors,
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFF2A2A2A),
                  ),
                  _DrawerMenuItem(
                    icon: Icons.settings_outlined,
                    label: context.l10n.drawer_settings,
                    semanticLabel: context.l10n.drawer_settings_hint,
                    route: '/settings',
                    colors: colors,
                    enabled: false, // Disabled for now
                  ),
                ],
              ),
            ),

            // Footer
            _DrawerFooter(colors: colors),
          ],
        ),
      ),
    );
  }
}

/// Drawer Header - CRT Retro Style
class _DrawerHeader extends StatelessWidget {
  final KluiCustomColors colors;

  const _DrawerHeader({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          bottom: BorderSide(
            color: colors.border,
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Retro terminal icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.userBubble.withOpacity(0.1),
              border: Border.all(
                color: colors.userBubble,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.terminal,
              color: colors.userBubble,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            'KLUI',
            style: KluiTextStyles.headlineSmall.copyWith(
              color: colors.userBubble,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          // Subtitle with retro "terminal" effect
          Text(
            '> KOSMOS LANGUAGE USER INTERFACE_',
            style: KluiTextStyles.bodySmall.copyWith(
              color: colors.textSecondary,
              fontFamily: 'monospace',
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Drawer Menu Item
class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String semanticLabel;
  final String route;
  final KluiCustomColors colors;
  final bool enabled;

  const _DrawerMenuItem({
    required this.icon,
    required this.label,
    required this.semanticLabel,
    required this.route,
    required this.colors,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        label: semanticLabel,
        button: true,
        enabled: enabled,
        child: InkWell(
          onTap: enabled
              ? () {
                  Navigator.pop(context); // Close drawer
                  context.go(route);
                }
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: enabled
                      ? colors.userBubble.withOpacity(0.3)
                      : colors.border,
                  width: 4,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: enabled ? colors.textPrimary : colors.textDisabled,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: KluiTextStyles.bodyLarge.copyWith(
                    color: enabled ? colors.textPrimary : colors.textDisabled,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!enabled) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.warning.withOpacity(0.2),
                      border: Border.all(
                        color: colors.warning,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'SOON',
                      style: KluiTextStyles.labelSmall.copyWith(
                        color: colors.warning,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Drawer Footer
class _DrawerFooter extends StatelessWidget {
  final KluiCustomColors colors;

  const _DrawerFooter({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(
            color: colors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Retro "version" display
          Text(
            'VERSION: 0.1.0-alpha',
            style: KluiTextStyles.labelSmall.copyWith(
              color: colors.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '> SYSTEM READY_',
            style: KluiTextStyles.labelSmall.copyWith(
              color: colors.success,
              fontFamily: 'monospace',
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
