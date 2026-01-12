import 'package:flutter/material.dart';
import 'klui_colors.dart';
import 'klui_text_styles.dart';
import 'klui_theme_extension.dart';

/// Neo-Brutalist Developer Terminal Theme
/// Unified design system for Klui app
class NeoBrutalistTheme {
  NeoBrutalistTheme._();

  /// Light theme (not recommended - this is a dark-first design)
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      // TODO: Implement light theme if needed
    );
  }

  /// Dark theme - Primary theme for Klui
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        background: KluiColors.background,
        surface: KluiColors.surface,
        primary: KluiColors.userBubble,
        secondary: KluiColors.toolSearch,
        error: KluiColors.error,
        onPrimary: KluiColors.userText,
        onBackground: KluiColors.textPrimary,
        onSurface: KluiColors.textPrimary,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: KluiColors.background,

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: KluiColors.surface,
        foregroundColor: KluiColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: KluiTextStyles.displayLarge.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: KluiColors.textPrimary,
          size: 24,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: KluiColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: KluiColors.border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KluiColors.userBubble,
          foregroundColor: KluiColors.userText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: KluiTextStyles.button,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KluiColors.userBubble,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: KluiTextStyles.button,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KluiColors.textPrimary,
          side: BorderSide(color: KluiColors.border, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: KluiTextStyles.button,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: KluiColors.userBubble,
        foregroundColor: KluiColors.userText,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        extendedTextStyle: KluiTextStyles.button,
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KluiColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: KluiColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: KluiColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: KluiColors.userBubble, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: KluiColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: KluiColors.error, width: 2),
        ),
        labelStyle: KluiTextStyles.bodyMedium.copyWith(
          color: KluiColors.textSecondary,
        ),
        hintStyle: KluiTextStyles.bodyMedium.copyWith(
          color: KluiColors.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),

      // List Tiles
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        titleTextStyle: KluiTextStyles.headlineSmall,
        subtitleTextStyle: KluiTextStyles.bodyMedium.copyWith(
          color: KluiColors.textSecondary,
        ),
      ),

      // Icons
      iconTheme: IconThemeData(
        color: KluiColors.textSecondary,
        size: 24,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: KluiColors.border,
        thickness: 1,
        space: 1,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: KluiColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: KluiTextStyles.headlineMedium,
        contentTextStyle: KluiTextStyles.bodyMedium,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: KluiColors.surface,
        contentTextStyle: KluiTextStyles.bodyMedium.copyWith(
          color: KluiColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: KluiColors.surface,
        selectedItemColor: KluiColors.userBubble,
        unselectedItemColor: KluiColors.textSecondary,
        selectedLabelStyle: KluiTextStyles.labelSmall,
        unselectedLabelStyle: KluiTextStyles.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: KluiColors.surfaceVariant,
        labelStyle: KluiTextStyles.labelMedium,
        side: BorderSide(color: KluiColors.border, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: KluiColors.userBubble,
        linearTrackColor: KluiColors.surfaceVariant,
        circularTrackColor: KluiColors.surfaceVariant,
      ),

      // Custom color extensions
      extensions: <ThemeExtension<dynamic>>[
        KluiCustomColors.dark,
      ],
    );
  }

  /// Custom card decoration for Neo-Brutalist cards
  static BoxDecoration cardDecoration({
    Color? color,
    Color? borderColor,
    double borderRadius = 12,
    double borderWidth = 1,
  }) {
    return BoxDecoration(
      color: color ?? KluiColors.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? KluiColors.border,
        width: borderWidth,
      ),
    );
  }

  /// Custom status indicator decoration
  static BoxDecoration statusDecoration(Color statusColor) {
    return BoxDecoration(
      color: statusColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: statusColor.withOpacity(0.3),
        width: 1,
      ),
    );
  }

  /// Shadow for elevated cards
  static List<BoxShadow> cardShadow({
    Color? shadowColor,
    double blurRadius = 12,
    Offset offset = const Offset(0, 4),
  }) {
    return [
      BoxShadow(
        color: (shadowColor ?? KluiColors.userBubble).withOpacity(0.1),
        blurRadius: blurRadius,
        offset: offset,
      ),
    ];
  }
}
