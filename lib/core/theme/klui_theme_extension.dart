import 'package:flutter/material.dart';
import 'klui_colors.dart';

/// Custom color extension for Klui CRT theme
///
/// Usage:
/// ```dart
/// final colors = Theme.of(context).extension<KluiCustomColors>();
/// colors?.userBubble
/// ```
@immutable
class KluiCustomColors extends ThemeExtension<KluiCustomColors> {
  final Color background;
  final Color surface;
  final Color surfaceVariant;

  // Message bubbles
  final Color userBubble;
  final Color userText;
  final Color assistantBubble;
  final Color assistantText;
  final Color reasoning;

  // Tool colors
  final Color toolBash;
  final Color toolFile;
  final Color toolSearch;
  final Color toolMemory;

  // Status colors
  final Color statusStreaming;
  final Color statusReady;
  final Color statusRunning;
  final Color statusSuccess;
  final Color statusError;
  final Color success;
  final Color error;
  final Color warning;

  // Text colors
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;

  // Border
  final Color border;

  const KluiCustomColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.userBubble,
    required this.userText,
    required this.assistantBubble,
    required this.assistantText,
    required this.reasoning,
    required this.toolBash,
    required this.toolFile,
    required this.toolSearch,
    required this.toolMemory,
    required this.statusStreaming,
    required this.statusReady,
    required this.statusRunning,
    required this.statusSuccess,
    required this.statusError,
    required this.success,
    required this.error,
    required this.warning,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.border,
  });

  /// Factory constructor to create from KluiColors
  factory KluiCustomColors.fromKluiColors() {
    return const KluiCustomColors(
      background: KluiColors.background,
      surface: KluiColors.surface,
      surfaceVariant: KluiColors.surfaceVariant,
      userBubble: KluiColors.userBubble,
      userText: KluiColors.userText,
      assistantBubble: KluiColors.assistantBubble,
      assistantText: KluiColors.assistantText,
      reasoning: KluiColors.reasoning,
      toolBash: KluiColors.toolBash,
      toolFile: KluiColors.toolFile,
      toolSearch: KluiColors.toolSearch,
      toolMemory: KluiColors.toolMemory,
      statusStreaming: KluiColors.statusStreaming,
      statusReady: KluiColors.statusReady,
      statusRunning: KluiColors.statusRunning,
      statusSuccess: KluiColors.statusSuccess,
      statusError: KluiColors.statusError,
      success: KluiColors.success,
      error: KluiColors.error,
      warning: KluiColors.warning,
      textPrimary: KluiColors.textPrimary,
      textSecondary: KluiColors.textSecondary,
      textDisabled: KluiColors.textSecondary, // Use textSecondary as fallback
      border: KluiColors.border,
    );
  }

  @override
  KluiCustomColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? userBubble,
    Color? userText,
    Color? assistantBubble,
    Color? assistantText,
    Color? reasoning,
    Color? toolBash,
    Color? toolFile,
    Color? toolSearch,
    Color? toolMemory,
    Color? statusStreaming,
    Color? statusReady,
    Color? statusRunning,
    Color? statusSuccess,
    Color? statusError,
    Color? success,
    Color? error,
    Color? warning,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? border,
  }) {
    return KluiCustomColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      userBubble: userBubble ?? this.userBubble,
      userText: userText ?? this.userText,
      assistantBubble: assistantBubble ?? this.assistantBubble,
      assistantText: assistantText ?? this.assistantText,
      reasoning: reasoning ?? this.reasoning,
      toolBash: toolBash ?? this.toolBash,
      toolFile: toolFile ?? this.toolFile,
      toolSearch: toolSearch ?? this.toolSearch,
      toolMemory: toolMemory ?? this.toolMemory,
      statusStreaming: statusStreaming ?? this.statusStreaming,
      statusReady: statusReady ?? this.statusReady,
      statusRunning: statusRunning ?? this.statusRunning,
      statusSuccess: statusSuccess ?? this.statusSuccess,
      statusError: statusError ?? this.statusError,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      border: border ?? this.border,
    );
  }

  @override
  KluiCustomColors lerp(ThemeExtension<KluiCustomColors>? other, double t) {
    if (other is! KluiCustomColors) {
      return this;
    }

    return KluiCustomColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      userBubble: Color.lerp(userBubble, other.userBubble, t)!,
      userText: Color.lerp(userText, other.userText, t)!,
      assistantBubble: Color.lerp(assistantBubble, other.assistantBubble, t)!,
      assistantText: Color.lerp(assistantText, other.assistantText, t)!,
      reasoning: Color.lerp(reasoning, other.reasoning, t)!,
      toolBash: Color.lerp(toolBash, other.toolBash, t)!,
      toolFile: Color.lerp(toolFile, other.toolFile, t)!,
      toolSearch: Color.lerp(toolSearch, other.toolSearch, t)!,
      toolMemory: Color.lerp(toolMemory, other.toolMemory, t)!,
      statusStreaming: Color.lerp(statusStreaming, other.statusStreaming, t)!,
      statusReady: Color.lerp(statusReady, other.statusReady, t)!,
      statusRunning: Color.lerp(statusRunning, other.statusRunning, t)!,
      statusSuccess: Color.lerp(statusSuccess, other.statusSuccess, t)!,
      statusError: Color.lerp(statusError, other.statusError, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }

  /// Light theme variant (if needed in future)
  static KluiCustomColors get light => KluiCustomColors.fromKluiColors();

  /// Dark theme variant (primary theme)
  static KluiCustomColors get dark => KluiCustomColors.fromKluiColors();
}
