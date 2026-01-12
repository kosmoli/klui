import 'package:flutter/material.dart';
import 'package:klui/core/theme/klui_theme_extension.dart';
import 'package:klui/core/theme/klui_text_styles.dart';

/// Context size indicator showing token usage
class ContextSizeIndicator extends StatelessWidget {
  const ContextSizeIndicator({
    super.key,
    required this.usage,
    this.contextWindowSize = 128000,
  });

  final Map<String, dynamic>? usage;
  final int contextWindowSize;

  /// Calculate total tokens used from usage data
  int _getTotalTokensUsed() {
    if (usage == null) return 0;

    // Letta returns usage in format: {total_tokens: int, ...}
    final totalTokens = usage!['total_tokens'] as int?;
    if (totalTokens != null) return totalTokens;

    // Fallback: sum up individual token counts
    final promptTokens = usage!['prompt_tokens'] as int? ?? 0;
    final completionTokens = usage!['completion_tokens'] as int? ?? 0;
    return promptTokens + completionTokens;
  }

  /// Get usage percentage (0.0 to 1.0)
  double _getUsagePercentage() {
    final used = _getTotalTokensUsed();
    if (contextWindowSize == 0) return 0.0;
    return (used / contextWindowSize).clamp(0.0, 1.0);
  }

  /// Get warning level based on usage
  _WarningLevel _getWarningLevel() {
    final percentage = _getUsagePercentage();
    if (percentage >= 0.9) return _WarningLevel.critical;
    if (percentage >= 0.75) return _WarningLevel.warning;
    return _WarningLevel.normal;
  }

  /// Get color based on warning level
  Color _getColor(KluiCustomColors colors, _WarningLevel level) {
    switch (level) {
      case _WarningLevel.critical:
        return colors.error;
      case _WarningLevel.warning:
        return colors.warning;
      case _WarningLevel.normal:
        return colors.success;
    }
  }

  /// Get icon based on warning level
  IconData _getIcon(_WarningLevel level) {
    switch (level) {
      case _WarningLevel.critical:
        return Icons.error_outline;
      case _WarningLevel.warning:
        return Icons.warning_amber_outlined;
      case _WarningLevel.normal:
        return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    final used = _getTotalTokensUsed();
    final percentage = _getUsagePercentage();
    final level = _getWarningLevel();
    final indicatorColor = _getColor(colors, level);

    if (used == 0) {
      // No usage data yet, show placeholder or nothing
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: indicatorColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Icon(
            _getIcon(level),
            size: 16,
            color: indicatorColor,
          ),
          const SizedBox(width: 8),
          // Token count
          Text(
            '$used',
            style: KluiTextStyles.labelMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            ' / $contextWindowSize',
            style: KluiTextStyles.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          // Progress bar
          SizedBox(
            width: 60,
            height: 4,
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: colors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          // Percentage
          Text(
            '${(percentage * 100).toInt()}%',
            style: KluiTextStyles.labelSmall.copyWith(
              color: indicatorColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum _WarningLevel { normal, warning, critical }
