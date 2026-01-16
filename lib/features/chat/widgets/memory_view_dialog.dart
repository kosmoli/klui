import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:klui/core/extensions/context_extensions.dart';
import 'package:klui/core/theme/klui_text_styles.dart';
import 'package:klui/core/theme/klui_theme_extension.dart';
import 'package:klui/core/providers/api_providers.dart';

/// Memory block model
class MemoryBlock {
  final String id;
  final String label;
  final String value;
  final int? limit;
  final String? createdAt;

  MemoryBlock({
    required this.id,
    required this.label,
    required this.value,
    this.limit,
    this.createdAt,
  });

  factory MemoryBlock.fromJson(Map<String, dynamic> json) {
    return MemoryBlock(
      id: json['id'] ?? json['block_id'] ?? '',
      label: json['label'] ?? '',
      value: json['value'] ?? json['content'] ?? '',
      limit: json['limit'],
      createdAt: json['created_at'],
    );
  }

  int get valueLength => value.length;

  /// Calculate usage percentage
  double get usagePercentage {
    if (limit == null || limit! == 0) return 0;
    return valueLength / limit!;
  }
}

/// Dialog to view and edit agent memory
class MemoryViewDialog extends ConsumerStatefulWidget {
  final String agentId;
  final String agentName;

  const MemoryViewDialog({
    super.key,
    required this.agentId,
    required this.agentName,
  });

  @override
  ConsumerState<MemoryViewDialog> createState() => _MemoryViewDialogState();
}

class _MemoryViewDialogState extends ConsumerState<MemoryViewDialog> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = true;
  List<MemoryBlock> _blocks = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMemory();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadMemory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get('/agents/${widget.agentId}/core-memory/blocks');

      if (response.statusCode == 200) {
        final List<dynamic> data = _decodeJson(response.body);
        final blocks = data.map((json) => MemoryBlock.fromJson(json)).toList();

        // Create controllers for each block
        for (final block in blocks) {
          _controllers[block.label] = TextEditingController(text: block.value);
        }

        setState(() {
          _blocks = blocks;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load memory: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading memory: $e';
        _isLoading = false;
      });
    }
  }

  List<dynamic> _decodeJson(String body) {
    // Simple JSON decode fallback
    try {
      return List<dynamic>.from(
        const JsonDecoder().convert(body) as List
      );
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveBlock(MemoryBlock block, String newValue) async {
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.patch(
        '/agents/${widget.agentId}/core-memory/blocks/${block.label}',
        body: {'value': newValue},
      );

      if (response.statusCode == 200) {
        // Success
        if (mounted) {
          final colors = Theme.of(context).extension<KluiCustomColors>()!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.memory_edit_success),
              backgroundColor: colors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        await _loadMemory(); // Reload to get updated values
      } else {
        throw Exception('Status ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        final colors = Theme.of(context).extension<KluiCustomColors>()!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.memory_edit_failed}: $e'),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

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
            Container(
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
                  Icon(Icons.psychology_outlined, color: colors.userBubble),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.memory_view_title,
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
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: _buildContent(colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(KluiCustomColors colors) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colors.error),
              const SizedBox(height: 16),
              Text(_error!, style: KluiTextStyles.bodyMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadMemory,
                child: Text(context.l10n.common_button_refresh),
              ),
            ],
          ),
        ),
      );
    }

    if (_blocks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.memory_outlined, size: 48, color: colors.textSecondary),
              const SizedBox(height: 16),
              Text(
                context.l10n.memory_empty,
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
      itemCount: _blocks.length,
      itemBuilder: (context, index) {
        final block = _blocks[index];
        return _MemoryBlockCard(
          block: block,
          controller: _controllers[block.label]!,
          onSave: (newValue) => _saveBlock(block, newValue),
        );
      },
    );
  }
}

/// Individual memory block card
class _MemoryBlockCard extends StatefulWidget {
  final MemoryBlock block;
  final TextEditingController controller;
  final Future<void> Function(String) onSave;

  const _MemoryBlockCard({
    required this.block,
    required this.controller,
    required this.onSave,
  });

  @override
  State<_MemoryBlockCard> createState() => _MemoryBlockCardState();
}

class _MemoryBlockCardState extends State<_MemoryBlockCard> {
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    final usage = widget.block.usagePercentage;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      widget.block.label,
                      style: KluiTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.block.limit != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(${widget.block.valueLength}/${widget.block.limit})',
                        style: KluiTextStyles.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!_isEditing)
                IconButton(
                  onPressed: () => setState(() => _isEditing = true),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: 'Edit',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
            ],
          ),

          // Usage bar
          if (widget.block.limit != null && widget.block.limit! > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: usage.clamp(0.0, 1.0),
                  backgroundColor: colors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    usage > 0.9 ? colors.error : usage > 0.7 ? colors.warning : colors.success,
                  ),
                  minHeight: 4,
                ),
              ),
            ),

          // Content
          if (_isEditing)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: widget.controller,
                  maxLines: null,
                  minLines: 3,
                  style: KluiTextStyles.bodyMedium,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    contentPadding: const EdgeInsets.all(8),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSaving
                          ? null
                          : () {
                              setState(() {
                                _isEditing = false;
                                widget.controller.text = widget.block.value;
                              });
                            },
                      child: Text(context.l10n.common_button_cancel),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      child: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ],
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                widget.block.value.isEmpty
                    ? '<empty>'
                    : widget.block.value,
                style: KluiTextStyles.bodyMedium.copyWith(
                  color: widget.block.value.isEmpty
                      ? colors.textSecondary
                      : colors.textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    final newValue = widget.controller.text;
    if (newValue == widget.block.value) {
      setState(() => _isEditing = false);
      return;
    }

    setState(() => _isSaving = true);
    await widget.onSave(newValue);
    setState(() {
      _isSaving = false;
      _isEditing = false;
    });
  }
}
