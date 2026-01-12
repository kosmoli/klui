import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:klui/core/theme/klui_theme_extension.dart';
import 'package:klui/core/theme/klui_text_styles.dart';
import 'package:klui/core/models/chat_message.dart';
import 'diff_viewer.dart';

/// Tool call card with status indicator and approval buttons
class ToolCallCard extends StatefulWidget {
  const ToolCallCard({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  State<ToolCallCard> createState() => _ToolCallCardState();
}

class _ToolCallCardState extends State<ToolCallCard> {
  bool _isExpanded = false;

  Color _getToolColor(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    final toolName = widget.message.toolName?.toLowerCase() ?? '';
    if (toolName.contains('bash') || toolName.contains('shell')) {
      return colors.toolBash;
    } else if (toolName.contains('write') || toolName.contains('edit')) {
      return colors.toolFile;
    } else if (toolName.contains('search')) {
      return colors.toolSearch;
    } else if (toolName.contains('memory')) {
      return colors.toolMemory;
    }
    return colors.assistantText;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    // Safely extract tool information with null checks
    final toolName = widget.message.toolName ?? 'Unknown Tool';
    final toolInput = widget.message.toolInput ?? {};
    final phase = widget.message.metadata?['phase'] ?? 'ready';

    // Check if this is a file edit tool with diff information
    final isFileEdit = _isFileEditTool(toolName);
    final shouldShowDiff = isFileEdit &&
        phase == 'finished' &&
        toolInput['old_content'] != null &&
        toolInput['new_content'] != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getToolColor(context).withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: _getToolColor(context).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Tool Name + Status
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Status Indicator Dot
                  _StatusDot(phase: phase, color: _getToolColor(context)),
                  const SizedBox(width: 12),
                  // Tool Name
                  Expanded(
                    child: Text(
                      toolName,
                      style: KluiTextStyles.toolName.copyWith(color: _getToolColor(context)),
                    ),
                  ),
                  // Chevron (if has input)
                  if (toolInput.isNotEmpty)
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: colors.reasoning,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Tool Input (expanded)
          if (_isExpanded && toolInput.isNotEmpty)
            _ToolInputSection(toolInput: toolInput, toolColor: _getToolColor(context)),

          // Approval UI (if ready)
          if (phase == 'ready')
            _ToolApprovalActions(
              onApprove: () {
                setState(() {
                  // Simulate approval
                });
              },
              onReject: () {
                setState(() {
                  // Simulate rejection
                });
              },
            ),

          // Result (if finished)
          if (phase == 'finished' && widget.message.content.isNotEmpty)
            shouldShowDiff
                ? DiffViewer(
                    oldContent: toolInput['old_content']?.toString() ?? '',
                    newContent: toolInput['new_content']?.toString() ?? '',
                    language: _detectLanguage(toolInput['file_path']?.toString()),
                    filePath: toolInput['file_path']?.toString() ?? '',
                  )
                : _ToolCallResult(
                    result: widget.message.content,
                    isSuccess: widget.message.metadata?['isOk'] == true,
                  ),
        ],
      ),
    );
  }

  /// Check if the tool is a file edit operation
  bool _isFileEditTool(String? toolName) {
    if (toolName == null) return false;
    final lowerName = toolName.toLowerCase();
    return lowerName.contains('file_edit') ||
        lowerName.contains('file_write') ||
        lowerName.contains('str_replace') ||
        lowerName.contains('archive_insert') ||
        lowerName.contains('archive_replace');
  }

  /// Detect programming language from file path
  String _detectLanguage(String? filePath) {
    if (filePath == null) return 'text';

    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'py':
        return 'python';
      case 'js':
        return 'javascript';
      case 'ts':
        return 'typescript';
      case 'dart':
        return 'dart';
      case 'java':
        return 'java';
      case 'cpp':
      case 'cc':
      case 'cxx':
        return 'cpp';
      case 'c':
        return 'c';
      case 'cs':
        return 'csharp';
      case 'go':
        return 'go';
      case 'rs':
        return 'rust';
      case 'rb':
        return 'ruby';
      case 'php':
        return 'php';
      case 'swift':
        return 'swift';
      case 'kt':
        return 'kotlin';
      case 'sh':
      case 'bash':
        return 'bash';
      case 'sql':
        return 'sql';
      case 'html':
      case 'htm':
        return 'html';
      case 'css':
        return 'css';
      case 'scss':
        return 'scss';
      case 'json':
        return 'json';
      case 'yaml':
      case 'yml':
        return 'yaml';
      case 'xml':
        return 'xml';
      case 'md':
        return 'markdown';
      case 'tsx':
      case 'jsx':
        return 'jsx';
      default:
        return 'text';
    }
  }
}

/// Status indicator dot with animation
class _StatusDot extends StatefulWidget {
  const _StatusDot({
    required this.phase,
    required this.color,
  });

  final String phase;
  final Color color;

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Blink animation for ready/running phases - faster speed
    if (widget.phase == 'ready' || widget.phase == 'running') {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400), // Reduced from 800ms
      )..repeat(reverse: true);
      _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
    } else {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200), // Reduced from 300ms
      );
      _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    Color dotColor;
    switch (widget.phase) {
      case 'streaming':
        dotColor = colors.statusStreaming;
        break;
      case 'ready':
        dotColor = colors.statusReady;
        break;
      case 'running':
        dotColor = colors.statusRunning;
        break;
      case 'finished':
        dotColor = colors.statusSuccess;
        break;
      default:
        dotColor = colors.reasoning;
    }

    return SizedBox(
      width: 12,
      height: 12,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Opacity(
            opacity: _animation.value,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Tool input section (when expanded)
class _ToolInputSection extends StatelessWidget {
  const _ToolInputSection({
    required this.toolInput,
    required this.toolColor,
  });

  final Map<String, dynamic> toolInput;
  final Color toolColor;

  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is Map || value is List) {
      return const JsonEncoder.withIndent('  ').convert(value);
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Parameters:',
            style: KluiTextStyles.statusIndicator.copyWith(
              color: colors.reasoning,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          ...toolInput.entries.map((entry) {
            final valueStr = _formatValue(entry.value);
            final isMultiline = valueStr.contains('\n');

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key}: ',
                    style: KluiTextStyles.assistantMessage.copyWith(
                      fontSize: 13,
                      color: toolColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: isMultiline
                        ? Text(
                            valueStr,
                            style: KluiTextStyles.codeBlock.copyWith(
                              fontSize: 12,
                              color: colors.textPrimary,
                            ),
                          )
                        : Text(
                            valueStr,
                            style: KluiTextStyles.parameter,
                          ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Approval actions
class _ToolApprovalActions extends StatelessWidget {
  const _ToolApprovalActions({
    required this.onApprove,
    required this.onReject,
  });

  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          // Reject Button
          Expanded(
            child: _ApprovalButton(
              label: 'Reject',
              icon: Icons.block,
              color: colors.error,
              backgroundColor: colors.error.withOpacity(0.1),
              onTap: onReject,
            ),
          ),
          const SizedBox(width: 12),
          // Approve Button
          Expanded(
            child: _ApprovalButton(
              label: 'Approve',
              icon: Icons.check_circle,
              color: colors.success,
              backgroundColor: colors.success.withOpacity(0.1),
              onTap: onApprove,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApprovalButton extends StatelessWidget {
  const _ApprovalButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: KluiTextStyles.bodyFont,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tool result section
class _ToolCallResult extends StatelessWidget {
  const _ToolCallResult({
    required this.result,
    required this.isSuccess,
  });

  final String result;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    final isCode = result.trimLeft().startsWith('```');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSuccess ? colors.border : colors.error,
          width: 1,
        ),
      ),
      child: isCode
          ? _CodeBlockView(code: result, isSuccess: isSuccess)
          : Text(
              result,
              style: isSuccess
                  ? KluiTextStyles.codeBlock
                  : KluiTextStyles.assistantMessage.copyWith(
                      fontSize: 14,
                    ),
            ),
    );
  }
}

/// Code block view with horizontal scroll
class _CodeBlockView extends StatelessWidget {
  const _CodeBlockView({
    required this.code,
    required this.isSuccess,
  });

  final String code;
  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    // Extract language and code content
    final lines = code.split('\n');
    final firstLine = lines.first.trim();
    final hasLanguage = firstLine.startsWith('```');

    String language = 'text';
    String codeContent = code;

    if (hasLanguage) {
      final langMatch = RegExp(r'```(\w+)?').firstMatch(firstLine);
      language = langMatch?.group(1) ?? 'text';
      codeContent = lines.skip(1).join('\n');
      if (codeContent.endsWith('```')) {
        codeContent = codeContent.substring(0, codeContent.length - 3);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Language Header
        if (language != 'text')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              language.toUpperCase(),
              style: KluiTextStyles.statusIndicator.copyWith(
                color: colors.toolSearch,
                fontSize: 10,
                letterSpacing: 1.2,
              ),
            ),
          ),
        // Code Content - Horizontal Scroll
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SelectableText(
            codeContent.trim(),
            style: KluiTextStyles.codeBlock.copyWith(
              color: isSuccess ? colors.assistantText : colors.error,
            ),
          ),
        ),
      ],
    );
  }
}
