import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klui/core/extensions/context_extensions.dart';
import 'package:klui/core/theme/klui_text_styles.dart';
import 'package:klui/core/theme/klui_theme_extension.dart';
import 'package:klui/core/providers/tool_providers.dart';
import 'package:klui/core/models/tool.dart';

/// Dialog to manage agent tools
class ToolsManageDialog extends ConsumerStatefulWidget {
  final String agentId;
  final String agentName;

  const ToolsManageDialog({
    super.key,
    required this.agentId,
    required this.agentName,
  });

  @override
  ConsumerState<ToolsManageDialog> createState() => _ToolsManageDialogState();
}

class _ToolsManageDialogState extends ConsumerState<ToolsManageDialog> {
  bool _showAvailable = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context, colors),

            // Content
            Flexible(
              child: _showAvailable
                  ? _AvailableToolsList(agentId: widget.agentId)
                  : _AttachedToolsList(agentId: widget.agentId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, KluiCustomColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.userBubble.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.build_outlined, color: colors.userBubble),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.tools_title,
                  style: KluiTextStyles.headlineSmall,
                ),
                Text(
                  widget.agentName,
                  style: KluiTextStyles.bodySmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Toggle button
          TextButton.icon(
            onPressed: () => setState(() => _showAvailable = !_showAvailable),
            icon: Icon(
              _showAvailable ? Icons.arrow_back : Icons.list,
              size: 18,
            ),
            label: Text(_showAvailable
                ? 'Attached'
                : context.l10n.tools_available),
            style: TextButton.styleFrom(
              foregroundColor: colors.userBubble,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }
}

/// Attached Tools List
class _AttachedToolsList extends ConsumerWidget {
  final String agentId;

  const _AttachedToolsList({required this.agentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    final toolsAsync = ref.watch(agentToolsProvider(agentId));

    return toolsAsync.when(
      loading: () => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                context.l10n.tools_loading,
                style: KluiTextStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colors.error),
              const SizedBox(height: 16),
              Text(
                context.l10n.tools_error_loading,
                style: KluiTextStyles.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: KluiTextStyles.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      data: (tools) {
        if (tools.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.build_outlined, size: 48, color: colors.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.tools_empty,
                    style: KluiTextStyles.bodyMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            final tool = tools[index];
            return _ToolCard(
              tool: tool,
              agentId: agentId,
              isAttached: true,
            );
          },
        );
      },
    );
  }
}

/// Available Tools List
class _AvailableToolsList extends ConsumerWidget {
  final String agentId;

  const _AvailableToolsList({required this.agentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    final attachedToolsAsync = ref.watch(agentToolsProvider(agentId));
    final allToolsAsync = ref.watch(allToolsProvider);

    return allToolsAsync.when(
      loading: () => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                context.l10n.tools_loading,
                style: KluiTextStyles.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colors.error),
              const SizedBox(height: 16),
              Text(
                context.l10n.tools_error_loading,
                style: KluiTextStyles.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: KluiTextStyles.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      data: (allTools) {
        return attachedToolsAsync.when(
          loading: () => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (attachedTools) {
            final attachedIds = attachedTools.map((t) => t.id).toSet();
            final availableTools = allTools
                .where((t) => !attachedIds.contains(t.id))
                .toList();

            if (availableTools.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off, size: 48, color: colors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.tools_no_available,
                        style: KluiTextStyles.bodyMedium.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: availableTools.length,
              itemBuilder: (context, index) {
                final tool = availableTools[index];
                return _ToolCard(
                  tool: tool,
                  agentId: agentId,
                  isAttached: false,
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Tool Card
class _ToolCard extends ConsumerWidget {
  final Tool tool;
  final String agentId;
  final bool isAttached;

  const _ToolCard({
    required this.tool,
    required this.agentId,
    required this.isAttached,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colors.userBubble.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getToolTypeIcon(tool.toolType),
              color: colors.userBubble,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tool.name ?? 'Unnamed Tool',
                  style: KluiTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (tool.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    tool.description!,
                    style: KluiTextStyles.bodySmall.copyWith(
                      color: colors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (_getToolTypeLabel(tool.toolType) != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getToolTypeLabel(tool.toolType)!,
                      style: KluiTextStyles.bodySmall.copyWith(
                        color: colors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Action button
          if (isAttached)
            IconButton(
              onPressed: () => _detachTool(context, ref, colors),
              icon: const Icon(Icons.remove_circle_outline),
              tooltip: context.l10n.tools_detach,
              color: colors.error,
            )
          else
            IconButton(
              onPressed: () => _attachTool(context, ref, colors),
              icon: const Icon(Icons.add_circle_outline),
              tooltip: context.l10n.tools_attach,
              color: colors.success,
            ),
        ],
      ),
    );
  }

  Future<void> _attachTool(
    BuildContext context,
    WidgetRef ref,
    KluiCustomColors colors,
  ) async {
    try {
      await ref.read(attachToolProvider(
        agentId: agentId,
        toolId: tool.id,
      ).future);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.tools_attach_success),
            backgroundColor: colors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Refresh both lists
        ref.invalidate(agentToolsProvider(agentId));
        ref.invalidate(allToolsProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.tools_attach_failed}: $e'),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _detachTool(
    BuildContext context,
    WidgetRef ref,
    KluiCustomColors colors,
  ) async {
    try {
      await ref.read(detachToolProvider(
        agentId: agentId,
        toolId: tool.id,
      ).future);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.tools_detach_success),
            backgroundColor: colors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Refresh both lists
        ref.invalidate(agentToolsProvider(agentId));
        ref.invalidate(allToolsProvider);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.tools_detach_failed}: $e'),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String? _getToolTypeLabel(ToolType? type) {
    switch (type) {
      case ToolType.custom:
        return 'Custom';
      case ToolType.builtin:
        return 'Built-in';
      case ToolType.mcp:
        return 'MCP';
      case ToolType.lettaClient:
        return 'Letta';
      case ToolType.lettaSleeptimeCore:
        return 'Sleeptime';
      case ToolType.pythonFunction:
        return 'Python';
      case null:
        return null;
    }
  }

  IconData _getToolTypeIcon(ToolType? type) {
    switch (type) {
      case ToolType.custom:
        return Icons.extension;
      case ToolType.builtin:
        return Icons.settings;
      case ToolType.mcp:
        return Icons.cloud;
      case ToolType.lettaClient:
        return Icons.hub;
      case ToolType.lettaSleeptimeCore:
        return Icons.bedtime;
      case ToolType.pythonFunction:
        return Icons.code;
      case null:
        return Icons.build;
    }
  }
}
