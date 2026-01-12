import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:klui/core/theme/klui_theme_extension.dart';
import 'package:klui/core/theme/klui_text_styles.dart';
import 'package:diff_match_patch/diff_match_patch.dart';

enum DiffType { addition, deletion, modification, unchanged }

class DiffLine {
  final DiffType type;
  final String content;
  final int oldLineNumber;
  final int? newLineNumber;

  const DiffLine({
    required this.type,
    required this.content,
    required this.oldLineNumber,
    this.newLineNumber,
  });
}

class DiffViewer extends StatelessWidget {
  const DiffViewer({
    super.key,
    required this.oldContent,
    required this.newContent,
    this.language = 'text',
    this.filePath = '',
  });

  final String oldContent;
  final String newContent;
  final String language;
  final String filePath;

  List<DiffLine> _computeDiff() {
    final dmp = DiffMatchPatch();
    final diffs = dmp.diff(oldContent, newContent);
    dmp.diffCleanupSemantic(diffs);

    final List<DiffLine> lines = [];
    int oldLineNum = 1;
    int newLineNum = 1;

    for (final diff in diffs) {
      final text = diff.text;
      final operation = diff.operation;

      if (operation == DIFF_EQUAL) {
        final textLines = text.split('\n');
        for (var i = 0; i < textLines.length; i++) {
          if (i < textLines.length - 1 || textLines[i].isNotEmpty) {
            lines.add(DiffLine(
              type: DiffType.unchanged,
              content: textLines[i],
              oldLineNumber: oldLineNum++,
              newLineNumber: newLineNum++,
            ));
          }
        }
      } else if (operation == DIFF_DELETE) {
        final textLines = text.split('\n');
        for (var i = 0; i < textLines.length; i++) {
          if (i < textLines.length - 1 || textLines[i].isNotEmpty) {
            lines.add(DiffLine(
              type: DiffType.deletion,
              content: textLines[i],
              oldLineNumber: oldLineNum++,
              newLineNumber: null,
            ));
          }
        }
      } else if (operation == DIFF_INSERT) {
        final textLines = text.split('\n');
        for (var i = 0; i < textLines.length; i++) {
          if (i < textLines.length - 1 || textLines[i].isNotEmpty) {
            lines.add(DiffLine(
              type: DiffType.addition,
              content: textLines[i],
              oldLineNumber: newLineNum,
              newLineNumber: newLineNum++,
            ));
          }
        }
      }
    }

    return lines;
  }

  Color _getBackgroundColor(DiffType type, KluiCustomColors colors) {
    switch (type) {
      case DiffType.addition:
        return colors.success.withOpacity(0.15);
      case DiffType.deletion:
        return colors.error.withOpacity(0.15);
      case DiffType.modification:
        return colors.warning.withOpacity(0.15);
      case DiffType.unchanged:
        return colors.surface;
    }
  }

  Color _getLineColor(DiffType type, KluiCustomColors colors) {
    switch (type) {
      case DiffType.addition:
        return colors.success;
      case DiffType.deletion:
        return colors.error;
      case DiffType.modification:
        return colors.warning;
      case DiffType.unchanged:
        return colors.textSecondary;
    }
  }

  String _getPrefix(DiffType type) {
    switch (type) {
      case DiffType.addition:
        return '+';
      case DiffType.deletion:
        return '-';
      case DiffType.modification:
        return '~';
      case DiffType.unchanged:
        return ' ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    final diffLines = _computeDiff();

    if (diffLines.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No changes detected',
          style: KluiTextStyles.bodyMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with file path
          if (filePath.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.surfaceVariant.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                border: Border(
                  bottom: BorderSide(color: colors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 16,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      filePath,
                      style: KluiTextStyles.labelMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Diff content
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: diffLines.length,
            itemBuilder: (context, index) {
              final line = diffLines[index];
              final backgroundColor = _getBackgroundColor(line.type, colors);
              final lineColor = _getLineColor(line.type, colors);
              final prefix = _getPrefix(line.type);

              return Container(
                color: backgroundColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Line numbers
                    Container(
                      width: 80,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        line.oldLineNumber != null && line.newLineNumber != null
                            ? '${line.oldLineNumber} → ${line.newLineNumber}'
                            : (line.oldLineNumber?.toString() ?? line.newLineNumber?.toString() ?? ''),
                        style: KluiTextStyles.codeBlock.copyWith(
                          fontSize: 11,
                          color: colors.textSecondary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    // Diff prefix
                    Container(
                      width: 20,
                      alignment: Alignment.center,
                      child: Text(
                        prefix,
                        style: KluiTextStyles.codeBlock.copyWith(
                          fontSize: 13,
                          color: lineColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Content
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          line.content.isEmpty ? ' ' : line.content,
                          style: KluiTextStyles.codeBlock.copyWith(
                            fontSize: 13,
                            color: lineColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
