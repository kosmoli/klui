import 'package:flutter/material.dart';
import '../../core/theme/klui_theme_extension.dart';

/// Retro-style menu button with CRT terminal aesthetic
/// Displays hamburger icon with Neo-Brutalist design
class RetroMenuButton extends StatelessWidget {
  const RetroMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Semantics(
      label: 'Open menu',
      button: true,
      hint: 'Opens the navigation drawer',
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(
            color: colors.userBubble,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: colors.userBubble.withOpacity(0.2),
              offset: const Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Scaffold.of(context).openDrawer(),
            borderRadius: BorderRadius.circular(2),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Retro hamburger icon (CRT green)
                  Icon(
                    Icons.menu,
                    color: colors.userBubble,
                    size: 24,
                  ),
                  // Optional: Add cursor effect next to icon
                  Container(
                    width: 8,
                    height: 16,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: colors.userBubble.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
