import 'package:flutter/material.dart';
import 'klui_colors.dart';

/// Klui Design System Typography
/// CRT Retro Theme:
/// - Monospace (JetBrains Mono) for ALL machine/technical content
/// - Sans-serif for human language only
class KluiTextStyles {
  // Private constructor
  KluiTextStyles._();

  // Fonts
  static const monoFont = 'JetBrains Mono'; // For machine/technical content
  static const bodyFont = 'SF Pro Text'; // For human language

  // ========== MONOSPACE STYLES (Machine/Technical) ==========

  // Tool names, commands, code - ALWAYS monospace
  static const toolName = TextStyle(
    fontFamily: monoFont,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: KluiColors.userBubble,
  );

  // Status indicators
  static const statusIndicator = TextStyle(
    fontFamily: monoFont,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: KluiColors.userBubble,
  );

  // Code blocks, command output - monospace
  static const codeBlock = TextStyle(
    fontFamily: monoFont,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: KluiColors.userBubble,
  );

  // Agent IDs, model handles - monospace
  static const technical = TextStyle(
    fontFamily: monoFont,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: KluiColors.textSecondary,
  );

  // Command input - monospace
  static const command = TextStyle(
    fontFamily: monoFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: KluiColors.userBubble,
    height: 1.5,
  );

  // Tool parameters - monospace
  static const parameter = TextStyle(
    fontFamily: monoFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: KluiColors.toolSearch,
  );

  // ========== SANS-SERIF STYLES (Human Language) ==========

  // User messages - human language
  static const userMessage = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: KluiColors.userText,
  );

  // Assistant messages - human language
  static const assistantMessage = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: KluiColors.textPrimary,
    height: 1.5,
  );

  // Reasoning - human language, italic
  static const reasoning = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: KluiColors.reasoning,
    fontStyle: FontStyle.italic,
  );

  // ========== MATERIAL DESIGN STYLES ==========

  static const displayLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: KluiColors.textPrimary,
  );

  static const headlineMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: KluiColors.textPrimary,
  );

  static const headlineSmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: KluiColors.textPrimary,
  );

  static const bodyLarge = TextStyle(
    fontFamily: bodyFont,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: KluiColors.textPrimary,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: KluiColors.textPrimary,
    height: 1.5,
  );

  static const bodySmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: KluiColors.textSecondary,
    height: 1.4,
  );

  static const labelMedium = TextStyle(
    fontFamily: bodyFont,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: KluiColors.textPrimary,
  );

  static const labelSmall = TextStyle(
    fontFamily: bodyFont,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: KluiColors.textSecondary,
  );

  static const button = TextStyle(
    fontFamily: bodyFont,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: KluiColors.userText,
  );
}
