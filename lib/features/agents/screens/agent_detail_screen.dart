import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../core/extensions/context_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/providers/tool_providers.dart';
import '../../../../core/theme/klui_text_styles.dart';
import '../../../../core/theme/klui_theme_extension.dart';
import '../../../../core/models/agent.dart';
import '../../../../core/models/tool.dart';

/// Agent Detail Screen with Tabs
///
/// Displays comprehensive information about a single Agent with tabs:
/// - Info: Basic info, model configuration, timestamps
/// - Memory: Core memory blocks management
/// - Tools: Attached tools management
class AgentDetailScreen extends ConsumerStatefulWidget {
  final String agentId;

  const AgentDetailScreen({
    super.key,
    required this.agentId,
  });

  @override
  ConsumerState<AgentDetailScreen> createState() => _AgentDetailScreenState();
}

class _AgentDetailScreenState extends ConsumerState<AgentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final agentAsync = ref.watch(agentProvider(widget.agentId));
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(context, ref),
      body: agentAsync.when(
        data: (agent) => _buildContent(context, agent, colors),
        loading: () => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colors.userBubble),
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.error.withOpacity(0.1),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(12),
                  ),
                  border: Border.all(
                    color: colors.error.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: colors.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.agent_detail_failed_to_load,
                style: KluiTextStyles.headlineSmall,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                ),
                child: Text(
                  error.toString(),
                  style: KluiTextStyles.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    final agentAsync = ref.watch(agentProvider(widget.agentId));

    return AppBar(
      backgroundColor: colors.surface,
      elevation: 0,
      iconTheme: IconThemeData(color: colors.textPrimary),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: colors.textPrimary,
        onPressed: () => context.go('/agents'),
        tooltip: context.l10n.agent_detail_back_tooltip,
      ),
      title: agentAsync.when(
        data: (agent) => Text(
          agent.name,
          style: KluiTextStyles.headlineSmall.copyWith(
            color: colors.textPrimary,
          ),
        ),
        loading: () => Text(
          context.l10n.agent_detail_title,
          style: KluiTextStyles.headlineSmall.copyWith(
            color: colors.textPrimary,
          ),
        ),
        error: (_, __) => Text(
          context.l10n.agent_detail_title,
          style: KluiTextStyles.headlineSmall.copyWith(
            color: colors.textPrimary,
          ),
        ),
      ),
      actions: [
        // Edit button
        Semantics(
          label: context.l10n.agent_detail_tooltip_edit,
          button: true,
          child: IconButton(
            icon: const Icon(Icons.edit_outlined),
            color: colors.textPrimary,
            onPressed: () => context.go('/agents/${widget.agentId}/edit'),
            tooltip: context.l10n.agent_detail_tooltip_edit,
          ),
        ),
        // Start Chat button
        Semantics(
          label: context.l10n.agent_detail_start_chat,
          button: true,
          child: IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            color: colors.userBubble,
            onPressed: () => context.go('/chat?agentId=${widget.agentId}'),
            tooltip: context.l10n.agent_detail_start_chat,
            style: IconButton.styleFrom(
              backgroundColor: colors.userBubble.withOpacity(0.1),
            ),
          ),
        ),
        // Delete button
        Semantics(
          label: context.l10n.agent_detail_tooltip_delete,
          button: true,
          hint: context.l10n.agent_delete_confirm_message,
          child: IconButton(
            icon: const Icon(Icons.delete_outlined),
            color: colors.error,
            onPressed: () {
              final agentAsyncValue = ref.read(agentProvider(widget.agentId));
              agentAsyncValue.when(
                data: (agent) => _showDeleteDialog(context, agent),
                loading: () => {},
                error: (_, __) => {},
              );
            },
            tooltip: context.l10n.agent_detail_tooltip_delete,
          ),
        ),
        const SizedBox(width: 8),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: context.l10n.agent_detail_tab_info),
          Tab(text: context.l10n.memory_view_title),
          Tab(text: context.l10n.tools_title),
        ],
        labelColor: colors.userBubble,
        unselectedLabelColor: colors.textSecondary,
        indicatorColor: colors.userBubble,
      ),
    );
  }

  Widget _buildContent(BuildContext context, Agent agent, KluiCustomColors colors) {
    return Column(
      children: [
        // Header Section
        _HeaderSection(agent: agent),
        const SizedBox(height: 16),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _InfoTab(agent: agent),
              _MemoryTab(agentId: widget.agentId, agentName: agent.name ?? 'Agent'),
              _ToolsTab(agentId: widget.agentId, agentName: agent.name ?? 'Agent'),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, Agent agent) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.agent_delete_confirm_title(agent.name)),
        content: Text(
          context.l10n.agent_delete_confirm_message,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(context.l10n.agent_cancel_button),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              try {
                await ref.read(deleteAgentProvider(widget.agentId).future);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.agent_delete_success(agent.name ?? 'Agent')),
                      backgroundColor: colors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  ref.invalidate(agentListProvider);
                  context.go('/agents');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.agent_detail_delete_failed(e.toString())),
                      backgroundColor: colors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(context.l10n.agent_delete_button),
          ),
        ],
      ),
    );
  }
}

/// Header Section
class _HeaderSection extends StatelessWidget {
  final Agent agent;

  const _HeaderSection({required this.agent});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.all(
          Radius.circular(12),
        ),
        border: Border.all(
          color: colors.border,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Agent Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.userBubble.withOpacity(0.1),
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
              border: Border.all(
                color: colors.userBubble.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.smart_toy_outlined,
              color: colors.userBubble,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),

          // Agent Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agent.name,
                  style: KluiTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (agent.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    agent.description!,
                    style: KluiTextStyles.bodyMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Info Tab - Shows basic information
class _InfoTab extends StatelessWidget {
  final Agent agent;

  const _InfoTab({required this.agent});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Info Section
          _SectionCard(
            title: context.l10n.agent_detail_section_basic,
            icon: Icons.info_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(
                  label: context.l10n.agent_detail_field_id,
                  value: agent.id,
                  valueStyle: KluiTextStyles.technical,
                ),
                if (agent.agentType != null) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: context.l10n.agent_detail_field_agent_type,
                    value: agent.agentType!,
                    valueStyle: KluiTextStyles.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Model Configuration Section (Base mode)
          if (agent.model != null)
            _SectionCard(
              title: context.l10n.agent_detail_section_model_base,
              icon: Icons.psychology_outlined,
              child: _InfoRow(
                label: context.l10n.agent_detail_field_model_handle,
                value: agent.model!,
                valueStyle: KluiTextStyles.technical,
              ),
            ),
          if (agent.model != null)
            const SizedBox(height: 16),

          // LLM Configuration Section (BYOK mode)
          if (agent.model == null && agent.llmConfig != null)
            _SectionCard(
              title: context.l10n.agent_detail_section_llm_byok,
              icon: Icons.psychology_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (agent.llmConfig!['model'] != null)
                    _InfoRow(
                      label: context.l10n.agent_detail_field_model,
                      value: agent.llmConfig!['model']?.toString() ?? context.l10n.agent_detail_n_a,
                      valueStyle: KluiTextStyles.technical,
                    ),
                  if (agent.llmConfig!['provider_name'] != null) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: context.l10n.agent_detail_field_provider,
                      value: agent.llmConfig!['provider_name'].toString(),
                      valueStyle: KluiTextStyles.technical,
                    ),
                  ],
                  if (agent.llmConfig!['context_window'] != null) ...[
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: context.l10n.agent_detail_field_context_window,
                      value: context.l10n.agent_detail_context_window_tokens(agent.llmConfig!['context_window']),
                      valueStyle: KluiTextStyles.technical,
                    ),
                  ],
                ],
              ),
            ),
          if (agent.model == null && agent.llmConfig != null)
            const SizedBox(height: 16),

          // Embedding Configuration
          if (agent.embedding != null)
            _SectionCard(
              title: context.l10n.agent_detail_section_embedding,
              icon: Icons.memory_outlined,
              child: _InfoRow(
                label: context.l10n.agent_detail_field_embedding_handle,
                value: agent.embedding!,
                valueStyle: KluiTextStyles.technical,
              ),
            ),
          if (agent.embedding != null)
            const SizedBox(height: 16),

          // Timestamps Section
          _SectionCard(
            title: context.l10n.agent_detail_section_timestamps,
            icon: Icons.schedule_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (agent.createdAt != null)
                  _InfoRow(
                    label: context.l10n.agent_detail_field_created,
                    value: _formatDateTime(agent.createdAt!),
                    valueStyle: KluiTextStyles.technical,
                  ),
                if (agent.createdAt != null && agent.modifiedAt != null)
                  const SizedBox(height: 12),
                if (agent.modifiedAt != null)
                  _InfoRow(
                    label: context.l10n.agent_detail_field_modified,
                    value: _formatDateTime(agent.modifiedAt!),
                    valueStyle: KluiTextStyles.technical,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // System Prompt Section
          if (agent.systemPrompt != null && agent.systemPrompt!.isNotEmpty)
            _SectionCard(
              title: context.l10n.agent_detail_section_system_prompt,
              icon: Icons.message_outlined,
              child: Text(
                agent.systemPrompt!,
                style: KluiTextStyles.bodyMedium.copyWith(
                  fontFamily: 'JetBrainsMono',
                  color: colors.textSecondary,
                ),
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Memory Tab - Shows memory management
class _MemoryTab extends StatelessWidget {
  final String agentId;
  final String agentName;

  const _MemoryTab({
    required this.agentId,
    required this.agentName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Column(
      children: [
        // Description
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            context.l10n.memory_tab_description,
            style: KluiTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Memory View (embedded as a full-page widget)
        Expanded(
          child: _EmbeddedMemoryView(agentId: agentId, agentName: agentName),
        ),
      ],
    );
  }
}

/// Embedded Memory View (without dialog wrapper)
class _EmbeddedMemoryView extends ConsumerStatefulWidget {
  final String agentId;
  final String agentName;

  const _EmbeddedMemoryView({
    required this.agentId,
    required this.agentName,
  });

  @override
  ConsumerState<_EmbeddedMemoryView> createState() => _EmbeddedMemoryViewState();
}

class _EmbeddedMemoryViewState extends ConsumerState<_EmbeddedMemoryView> {
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
    try {
      final decoded = jsonDecode(body);
      if (decoded is List) {
        return decoded;
      }
      return [];
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
        final colors = Theme.of(context).extension<KluiCustomColors>()!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.memory_edit_success),
            backgroundColor: colors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        await _loadMemory();
      } else {
        throw Exception('Status ${response.statusCode}');
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

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

/// Tools Tab - Shows tools management
class _ToolsTab extends StatelessWidget {
  final String agentId;
  final String agentName;

  const _ToolsTab({
    required this.agentId,
    required this.agentName,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Column(
      children: [
        // Description
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            context.l10n.tools_tab_description,
            style: KluiTextStyles.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Tools Management
        Expanded(
          child: _EmbeddedToolsView(agentId: agentId, agentName: agentName),
        ),
      ],
    );
  }
}

/// Embedded Tools View (without dialog wrapper)
class _EmbeddedToolsView extends StatefulWidget {
  final String agentId;
  final String agentName;

  const _EmbeddedToolsView({
    required this.agentId,
    required this.agentName,
  });

  @override
  State<_EmbeddedToolsView> createState() => _EmbeddedToolsViewState();
}

class _EmbeddedToolsViewState extends State<_EmbeddedToolsView> {
  bool _showAvailable = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Column(
      children: [
        // Toggle buttons
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: false,
                label: Text(context.l10n.tools_attached),
                icon: const Icon(Icons.check_circle, size: 18),
              ),
              ButtonSegment(
                value: true,
                label: Text(context.l10n.tools_available),
                icon: const Icon(Icons.list, size: 18),
              ),
            ],
            selected: {_showAvailable},
            onSelectionChanged: (Set<bool> selected) {
              setState(() {
                _showAvailable = selected.first;
              });
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return colors.userBubble.withOpacity(0.2);
                }
                return colors.surfaceVariant;
              }),
              foregroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return colors.userBubble;
                }
                return colors.textPrimary;
              }),
            ),
          ),
        ),

        // Content
        Expanded(
          child: _showAvailable
              ? _AvailableToolsList(agentId: widget.agentId)
              : _AttachedToolsList(agentId: widget.agentId),
        ),
      ],
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
            child: _buildToolInfo(colors),
          ),

          // Action button
          _buildActionButton(context, ref, colors),
        ],
      ),
    );
  }

  Widget _buildToolInfo(KluiCustomColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tool.name ?? 'Unnamed Tool',
          style: KluiTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (tool.description != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              tool.description!,
              style: KluiTextStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref, KluiCustomColors colors) {
    if (isAttached) {
      return IconButton(
        onPressed: () => _detachTool(context, ref, colors),
        icon: const Icon(Icons.remove_circle_outline),
        tooltip: context.l10n.tools_detach,
        color: colors.error,
      );
    } else {
      return IconButton(
        onPressed: () => _attachTool(context, ref, colors),
        icon: const Icon(Icons.add_circle_outline),
        tooltip: context.l10n.tools_attach,
        color: colors.success,
      );
    }
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
      case ToolType.lettaVoiceSleeptimeCore:
        return Icons.bedtime;
      case ToolType.lettaBuiltin:
      case ToolType.lettaCore:
        return Icons.memory;
      case ToolType.lettaMemoryCore:
        return Icons.psychology;
      case ToolType.lettaFilesCore:
        return Icons.folder;
      case ToolType.lettaMultiAgentCore:
        return Icons.people;
      case ToolType.pythonFunction:
        return Icons.code;
      case null:
        return Icons.build;
    }
  }
}

/// Memory Block Card
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
        color: colors.surface,
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

/// Section Card Widget
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
        border: Border.all(
          color: colors.border,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border(
                bottom: BorderSide(
                  color: colors.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: colors.userBubble,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: KluiTextStyles.headlineMedium,
                ),
              ],
            ),
          ),

          // Section Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Info Row Widget
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;
  final bool isMultiline;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueStyle,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label (left side, fixed width)
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: KluiTextStyles.labelMedium.copyWith(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Value (right side, flexible)
        Expanded(
          child: Text(
            value,
            style: (valueStyle ?? KluiTextStyles.bodyMedium).copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: isMultiline ? null : 3,
            overflow: isMultiline ? null : TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

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
