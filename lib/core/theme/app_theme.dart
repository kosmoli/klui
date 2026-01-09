import 'package:flutter/material.dart';

/// Klui App Theme - Neo-Brutalist Technical Design
///
/// Design Philosophy:
/// - Raw, technical aesthetic that embraces AI's underlying logic
/// - High contrast, bold borders, and intentional imperfections
/// - Inspired by terminal interfaces, data visualizations, and cyberpunk
///
/// Color Palette:
/// - Background: Deep space blue (#0a0e27)
/// - Primary: Neon cyan (#00ff9d) - for success, active states
/// - Secondary: Electric pink (#ff006e) - for alerts, important actions
/// - Tertiary: Amber warning (#ffbe0b) - for warnings
/// - Surface: Elevated surfaces with subtle gradients
class AppTheme {
  // ==================== COLORS ====================

  /// Primary Colors
  static const Color primaryColor = Color(0xFF00FF9D); // Neon Cyan
  static const Color secondaryColor = Color(0xFFFF006E); // Electric Pink
  static const Color tertiaryColor = Color(0xFFFFBE0B); // Amber

  /// Background Colors
  static const Color backgroundColor = Color(0xFF0A0E27); // Deep Space
  static const Color surfaceColor = Color(0xFF151932); // Elevated Surface
  static const Color surfaceVariantColor = Color(0xFF1F2440); // Higher Surface

  /// Text Colors
  static const Color textPrimaryColor = Color(0xFFFFFFFF);
  static const Color textSecondaryColor = Color(0xFFB0B8D4);
  static const Color textDisabledColor = Color(0xFF6E7A9A);

  /// Status Colors
  static const Color successColor = Color(0xFF00FF9D);
  static const Color errorColor = Color(0xFFFF006E);
  static const Color warningColor = Color(0xFFFFBE0B);
  static const Color infoColor = Color(0xFF00D4FF);

  /// Border Colors
  static const Color borderColor = Color(0xFF2E355A);
  static const Color borderActiveColor = Color(0xFF00FF9D);
  static const Color borderErrorColor = Color(0xFFFF006E);

  // ==================== TYPOGRAPHY ====================

  /// Font Families
  ///
  /// NOTE: These fonts need to be added to pubspec.yaml
  /// - Outfit: Modern geometric sans-serif for headings
  /// - JetBrains Mono: Monospace for technical details
  static const String fontFamilyHeading = 'Outfit';
  static const String fontFamilyBody = 'Outfit';
  static const String fontFamilyMono = 'JetBrainsMono';

  /// Text Styles
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamilyHeading,
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    color: textPrimaryColor,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamilyHeading,
    fontSize: 45,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: textPrimaryColor,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamilyHeading,
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: textPrimaryColor,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamilyHeading,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: textPrimaryColor,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamilyHeading,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: textPrimaryColor,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamilyHeading,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: textPrimaryColor,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamilyHeading,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    color: textPrimaryColor,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamilyHeading,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    color: textPrimaryColor,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamilyHeading,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: textPrimaryColor,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: textPrimaryColor,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: textPrimaryColor,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilyBody,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: textSecondaryColor,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamilyHeading,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: textPrimaryColor,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamilyHeading,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: textPrimaryColor,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamilyHeading,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: textPrimaryColor,
  );

  /// Monospace Text Styles (for technical details)
  static const TextStyle monoLarge = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: primaryColor,
  );

  static const TextStyle monoMedium = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: primaryColor,
  );

  static const TextStyle monoSmall = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: textSecondaryColor,
  );

  // ==================== SPACING ====================

  static const double spacing1 = 1.0;
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;
  static const double spacing64 = 64.0;
  static const double spacing80 = 80.0;

  // ==================== BORDER RADIUS ====================

  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // ==================== SHADOWS ====================

  static List<BoxShadow> get shadowSmall => [
        BoxShadow(
          color: const Color(0xFF00FF9D).withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMedium => [
        BoxShadow(
          color: const Color(0xFF00FF9D).withOpacity(0.15),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowLarge => [
        BoxShadow(
          color: const Color(0xFF00FF9D).withOpacity(0.2),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  // ==================== THEME DATA ====================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      chipTheme: _chipTheme,
      dividerTheme: _dividerTheme,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      cardTheme: _cardTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      floatingActionButtonTheme: _floatingActionButtonTheme,
      chipTheme: _chipTheme,
      dividerTheme: _dividerTheme,
    );
  }

  // ==================== COLOR SCHEMES ====================

  static const ColorScheme _lightColorScheme = ColorScheme.light(
    primary: primaryColor,
    onPrimary: Color(0xFF001F14),
    primaryContainer: Color(0xFF00FF9D),
    onPrimaryContainer: Color(0xFF002017),
    secondary: secondaryColor,
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFFD9E2),
    onSecondaryContainer: Color(0xFF3E001D),
    tertiary: tertiaryColor,
    onTertiary: Color(0xFF3F2E00),
    error: errorColor,
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    background: backgroundColor,
    onBackground: textPrimaryColor,
    surface: surfaceColor,
    onSurface: textPrimaryColor,
    surfaceVariant: surfaceVariantColor,
    onSurfaceVariant: textSecondaryColor,
    outline: borderColor,
    outlineVariant: Color(0xFF2E355A),
  );

  static const ColorScheme _darkColorScheme = ColorScheme.dark(
    primary: primaryColor,
    onPrimary: Color(0xFF00382A),
    primaryContainer: Color(0xFF00FF9D),
    onPrimaryContainer: Color(0xFF002017),
    secondary: secondaryColor,
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFF9F0039),
    onSecondaryContainer: Color(0xFFFFD9E2),
    tertiary: tertiaryColor,
    onTertiary: Color(0xFFFFFFFF),
    error: errorColor,
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    background: backgroundColor,
    onBackground: textPrimaryColor,
    surface: surfaceColor,
    onSurface: textPrimaryColor,
    surfaceVariant: surfaceVariantColor,
    onSurfaceVariant: textSecondaryColor,
    outline: borderColor,
    outlineVariant: Color(0xFF2E355A),
  );

  // ==================== COMPONENT THEMES ====================

  static const TextTheme _textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );

  static const AppBarTheme _appBarTheme = AppBarTheme(
    centerTitle: false,
    elevation: 0,
    backgroundColor: surfaceColor,
    foregroundColor: textPrimaryColor,
    titleTextStyle: titleLarge,
    iconTheme: IconThemeData(
      color: textPrimaryColor,
      size: 24,
    ),
    actionsIconTheme: IconThemeData(
      color: primaryColor,
      size: 24,
    ),
  );

  static const CardThemeData _cardTheme = CardThemeData(
    elevation: 0,
    color: surfaceColor,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
      side: BorderSide(color: borderColor, width: 1),
    ),
    clipBehavior: Clip.antiAlias,
  );

  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Color(0xFF001F14),
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: spacing24,
        vertical: spacing12,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
        side: BorderSide(color: primaryColor, width: 2),
      ),
      textStyle: titleMedium,
    ).copyWith(
      mouseCursor: MaterialStateProperty.all(SystemMouseCursors.click),
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: primaryColor,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: spacing24,
        vertical: spacing12,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
        side: BorderSide(color: primaryColor, width: 2),
      ),
      textStyle: titleMedium,
    ).copyWith(
      mouseCursor: MaterialStateProperty.all(SystemMouseCursors.click),
    ),
  );

  static final TextButtonThemeData _textButtonTheme =
      TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primaryColor,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing8,
      ),
      textStyle: labelLarge,
    ).copyWith(
      mouseCursor: MaterialStateProperty.all(SystemMouseCursors.click),
    ),
  );

  static const InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    fillColor: surfaceVariantColor,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
      borderSide: BorderSide(color: borderColor, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
      borderSide: BorderSide(color: borderColor, width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
      borderSide: BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
      borderSide: BorderSide(color: errorColor, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(radiusMedium)),
      borderSide: BorderSide(color: errorColor, width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(
      horizontal: spacing16,
      vertical: spacing12,
    ),
    labelStyle: TextStyle(
      color: textSecondaryColor,
      fontFamily: fontFamilyBody,
    ),
    hintStyle: TextStyle(
      color: textDisabledColor,
      fontFamily: fontFamilyBody,
    ),
  );

  static const FloatingActionButtonThemeData _floatingActionButtonTheme =
      FloatingActionButtonThemeData(
    backgroundColor: primaryColor,
    foregroundColor: Color(0xFF001F14),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radiusLarge)),
      side: BorderSide(color: primaryColor, width: 2),
    ),
  );

  static const ChipThemeData _chipTheme = ChipThemeData(
    backgroundColor: surfaceVariantColor,
    brightness: Brightness.dark,
    labelStyle: labelSmall,
    padding: EdgeInsets.symmetric(horizontal: spacing8, vertical: spacing4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radiusSmall)),
      side: BorderSide(color: borderColor, width: 1),
    ),
  );

  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: borderColor,
    thickness: 1,
    space: spacing1,
  );
}
