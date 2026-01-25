import 'dart:convert';
import '../../../core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/klui_colors.dart';
import '../../../../core/theme/klui_theme_extension.dart';
import '../../../../core/models/provider.dart' as models;
import '../../../../core/models/llm_model.dart';
import '../../../../core/models/create_agent_request.dart';

/// Multi-step Agent Edit Wizard with Neo-Brutalist design
///
/// Steps:
/// 0. Provider Selection (LLM Provider + Embedding Provider)
/// 1. Basic Information (name, description, system prompt)
/// 2. Review and Confirm
class AgentEditScreen extends ConsumerStatefulWidget {
  final String agentId;

  const AgentEditScreen({
    super.key,
    required this.agentId,
  });

  @override
  ConsumerState<AgentEditScreen> createState() => _AgentEditScreenState();
}

class _AgentEditScreenState extends ConsumerState<AgentEditScreen> {
  // Form controllers
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _systemPromptController;

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Current step (0-indexed)
  int _currentStep = 0;

  // Selected providers
  models.ProviderConfig? _selectedLLMProvider;
  models.ProviderConfig? _selectedEmbeddingProvider;

  // Selected models
  LLMModel? _selectedLLMModel;
  LLMModel? _selectedEmbeddingModel;

  // Available providers and models
  List<models.ProviderConfig> _availableProviders = [];
  List<LLMModel> _availableLLMModels = [];
  List<LLMModel> _availableEmbeddingModels = [];

  // Loading state
  bool _isLoadingAgent = true;
  bool _isLoadingProviders = true;
  bool _isLoadingLLMModels = false;
  bool _isLoadingEmbeddingModels = false;

  // Is updating
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _systemPromptController = TextEditingController();
    _loadAgentAndProviders();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _systemPromptController.dispose();
    super.dispose();
  }

  Future<void> _loadAgentAndProviders() async {
    setState(() => _isLoadingAgent = true);

    try {
      // Load agent details
      final agent = await ref.read(agentProvider(widget.agentId).future);

      // Load providers
      final providers = await ref.read(providerListProvider.future);

      if (mounted) {
        setState(() {
          _nameController.text = agent.name;
          _descriptionController.text = agent.description ?? '';
          _systemPromptController.text = agent.systemPrompt ?? '';
          _availableProviders = providers;

          // Try to find the current LLM and embedding models from providers
          // For now, we'll select the first provider by default and load its models
          if (providers.isNotEmpty) {
            // Find LLM provider (provider type that supports LLM)
            _selectedLLMProvider = providers.firstWhere(
              (p) => p.providerType == 'openai' ||
                     p.providerType == 'anthropic' ||
                     p.providerType == 'ollama',
              orElse: () => providers.first,
            );

            // Find embedding provider
            _selectedEmbeddingProvider = providers.firstWhere(
              (p) => p.id != _selectedLLMProvider!.id,
              orElse: () => _selectedLLMProvider!,
            );

            // Load models for the selected providers
            if (_selectedLLMProvider != null) {
              _loadLLMModelsForProvider(_selectedLLMProvider!.name);
            }
            if (_selectedEmbeddingProvider != null &&
                _selectedEmbeddingProvider!.id != _selectedLLMProvider!.id) {
              _loadEmbeddingModelsForProvider(_selectedEmbeddingProvider!.name);
            }
          }

          _isLoadingAgent = false;
          _isLoadingProviders = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingAgent = false;
          _isLoadingProviders = false;
        });
        final colors = Theme.of(context).extension<KluiCustomColors>()!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load agent: $e',
              style: TextStyle(color: colors.userText),
            ),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Dynamically load LLM models for a specific provider
  Future<void> _loadLLMModelsForProvider(String providerName) async {
    setState(() => _isLoadingLLMModels = true);

    try {
      final models = await ref.read(llmModelListByProviderProvider(providerName).future);

      if (mounted) {
        setState(() {
          _availableLLMModels = models;
          _isLoadingLLMModels = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLLMModels = false);
      }
    }
  }

  /// Dynamically load Embedding models for a specific provider
  Future<void> _loadEmbeddingModelsForProvider(String providerName) async {
    setState(() => _isLoadingEmbeddingModels = true);

    try {
      final models = await ref.read(llmModelListByProviderProvider(providerName).future);

      if (mounted) {
        setState(() {
          _availableEmbeddingModels = models;
          _isLoadingEmbeddingModels = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingEmbeddingModels = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingAgent) {
      final colors = Theme.of(context).extension<KluiCustomColors>()!;
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/agents/${widget.agentId}'),
          ),
          title: Text(context.l10n.agent_detail_title),
        ),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colors.success),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/agents/${widget.agentId}'),
        tooltip: context.l10n.agent_create_back_tooltip,
      ),
      title: Text(context.l10n.agent_edit_title),
      actions: [
        // Step indicator
        Center(
          child: Container(
            margin: const EdgeInsets.only(right: AppTheme.spacing16),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing12,
              vertical: AppTheme.spacing8,
            ),
            decoration: BoxDecoration(
              color: colors.success.withOpacity(0.15),
              borderRadius: const BorderRadius.all(
                Radius.circular(AppTheme.radiusSmall),
              ),
              border: Border.all(
                color: colors.success.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Text(
              context.l10n.agent_create_step_indicator(_currentStep + 1, 3),
              style: AppTheme.labelMedium.copyWith(
                color: colors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            _buildProgressBar(colors),
            const SizedBox(height: AppTheme.spacing24),

            // Step content
            _buildStepContent(),

            const SizedBox(height: AppTheme.spacing80),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(KluiCustomColors colors) {
    return Row(
      children: List.generate(
        3,
        (index) => Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: index < 2 ? AppTheme.spacing8 : 0,
            ),
            height: 4,
            decoration: BoxDecoration(
              color: index <= _currentStep
                  ? colors.success
                  : colors.surfaceVariant,
              borderRadius: const BorderRadius.all(
                Radius.circular(AppTheme.radiusSmall),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    if (_isLoadingProviders) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(KluiColors.success),
        ),
      );
    }

    switch (_currentStep) {
      case 0:
        return _ProviderSelectionStep(
          selectedLLMProvider: _selectedLLMProvider,
          selectedEmbeddingProvider: _selectedEmbeddingProvider,
          selectedLLMModel: _selectedLLMModel,
          selectedEmbeddingModel: _selectedEmbeddingModel,
          availableProviders: _availableProviders,
          availableLLMModels: _availableLLMModels,
          availableEmbeddingModels: _availableEmbeddingModels,
          isLoadingLLMModels: _isLoadingLLMModels,
          isLoadingEmbeddingModels: _isLoadingEmbeddingModels,
          onLLMProviderChanged: (provider) {
            setState(() {
              _selectedLLMProvider = provider;
              _selectedLLMModel = null;
            });
            if (provider != null) {
              _loadLLMModelsForProvider(provider.name);
            } else {
              setState(() => _availableLLMModels = []);
            }
          },
          onEmbeddingProviderChanged: (provider) {
            setState(() {
              _selectedEmbeddingProvider = provider;
              _selectedEmbeddingModel = null;
            });
            if (provider != null) {
              _loadEmbeddingModelsForProvider(provider.name);
            } else {
              setState(() => _availableEmbeddingModels = []);
            }
          },
          onLLMModelChanged: (model) =>
              setState(() => _selectedLLMModel = model),
          onEmbeddingModelChanged: (model) =>
              setState(() => _selectedEmbeddingModel = model),
        );
      case 1:
        return _BasicInfoStep(
          nameController: _nameController,
          descriptionController: _descriptionController,
          systemPromptController: _systemPromptController,
        );
      case 2:
        return _ReviewStep(
          name: _nameController.text,
          description: _descriptionController.text,
          systemPrompt: _systemPromptController.text,
          llmModel: _selectedLLMModel,
          embeddingModel: _selectedEmbeddingModel,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.border,
            width: 2,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back button
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _currentStep--),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    side: BorderSide(color: colors.border, width: 2),
                  ),
                  child: Text(context.l10n.agent_create_button_back),
                ),
              ),

            if (_currentStep > 0)
              const SizedBox(width: AppTheme.spacing16)
            else
              const SizedBox.shrink(),

            // Next/Update button
            Expanded(
              flex: _currentStep > 0 ? 1 : 2,
              child: _currentStep < 2
                  ? ElevatedButton(
                      onPressed: _handleNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.success,
                        foregroundColor: colors.userText,
                      ),
                      child: Text(context.l10n.agent_create_button_next),
                    )
                  : ElevatedButton(
                      onPressed: _isUpdating ? null : _handleUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.success,
                        foregroundColor: colors.userText,
                      ),
                      child: _isUpdating
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colors.userText,
                                ),
                              ),
                            )
                          : Text(context.l10n.agent_edit_button_update),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNext() {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    if (_currentStep == 0) {
      if (_selectedLLMProvider == null || _selectedLLMModel == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.agent_create_validation_llm_provider,
              style: TextStyle(color: colors.userText),
            ),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      if (_selectedEmbeddingProvider == null || _selectedEmbeddingModel == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.agent_create_validation_embedding_provider,
              style: TextStyle(color: colors.userText),
            ),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    } else if (_currentStep == 1) {
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.agent_create_validation_name,
              style: TextStyle(color: colors.userText),
            ),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      if (_systemPromptController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.agent_create_validation_system_prompt,
              style: TextStyle(color: colors.userText),
            ),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    setState(() => _currentStep++);
  }

  Future<void> _handleUpdate() async {
    setState(() => _isUpdating = true);

    try {
      final request = CreateAgentRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        llmModel: _selectedLLMModel!,
        embeddingModel: _selectedEmbeddingModel!,
        systemPrompt: _systemPromptController.text.trim(),
      );

      await ref.read(updateAgentProvider(
        id: widget.agentId,
        request: request,
      ).future);

      if (mounted) {
        final colors = Theme.of(context).extension<KluiCustomColors>()!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.agent_edit_success(_nameController.text),
              style: TextStyle(color: colors.userText),
            ),
            backgroundColor: colors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Refresh lists and navigate back
        ref.invalidate(agentListProvider);
        ref.invalidate(agentProvider(widget.agentId));
        context.go('/agents/${widget.agentId}');
      }
    } catch (e) {
      if (mounted) {
        final colors = Theme.of(context).extension<KluiCustomColors>()!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$e',
              style: TextStyle(color: colors.userText),
            ),
            backgroundColor: colors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }
}

/// Step 0: Provider Selection
class _ProviderSelectionStep extends StatelessWidget {
  final models.ProviderConfig? selectedLLMProvider;
  final models.ProviderConfig? selectedEmbeddingProvider;
  final LLMModel? selectedLLMModel;
  final LLMModel? selectedEmbeddingModel;
  final List<models.ProviderConfig> availableProviders;
  final List<LLMModel> availableLLMModels;
  final List<LLMModel> availableEmbeddingModels;
  final bool isLoadingLLMModels;
  final bool isLoadingEmbeddingModels;
  final Function(models.ProviderConfig?) onLLMProviderChanged;
  final Function(models.ProviderConfig?) onEmbeddingProviderChanged;
  final Function(LLMModel?) onLLMModelChanged;
  final Function(LLMModel?) onEmbeddingModelChanged;

  const _ProviderSelectionStep({
    required this.selectedLLMProvider,
    required this.selectedEmbeddingProvider,
    required this.selectedLLMModel,
    required this.selectedEmbeddingModel,
    required this.availableProviders,
    required this.availableLLMModels,
    required this.availableEmbeddingModels,
    required this.isLoadingLLMModels,
    required this.isLoadingEmbeddingModels,
    required this.onLLMProviderChanged,
    required this.onEmbeddingProviderChanged,
    required this.onLLMModelChanged,
    required this.onEmbeddingModelChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step title
        Text(
          context.l10n.agent_create_step_provider_title,
          style: AppTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacing8),
        Text(
          context.l10n.agent_create_step_provider_desc,
          style: AppTheme.bodyMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),

        // LLM Provider Section
        _ProviderSection(
          title: context.l10n.agent_create_llm_provider,
          selectedProvider: selectedLLMProvider,
          selectedModel: selectedLLMModel,
          availableProviders: availableProviders,
          availableModels: availableLLMModels,
          isLoadingModels: isLoadingLLMModels,
          onProviderChanged: (value) => onLLMProviderChanged(value as models.ProviderConfig?),
          onModelChanged: (value) => onLLMModelChanged(value as LLMModel?),
          modelType: _ModelType.llm,
        ),
        const SizedBox(height: AppTheme.spacing24),

        // Embedding Provider Section
        _ProviderSection(
          title: context.l10n.agent_create_embedding_provider,
          selectedProvider: selectedEmbeddingProvider,
          selectedModel: selectedEmbeddingModel,
          availableProviders: availableProviders,
          availableModels: availableEmbeddingModels,
          isLoadingModels: isLoadingEmbeddingModels,
          onProviderChanged: (value) => onEmbeddingProviderChanged(value as models.ProviderConfig?),
          onModelChanged: (value) => onEmbeddingModelChanged(value as LLMModel?),
          modelType: _ModelType.embedding,
        ),
      ],
    );
  }
}

/// Basic Info Step
class _BasicInfoStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController systemPromptController;

  const _BasicInfoStep({
    required this.nameController,
    required this.descriptionController,
    required this.systemPromptController,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.agent_create_step_basic_title,
          style: AppTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacing8),
        Text(
          context.l10n.agent_create_step_basic_desc,
          style: AppTheme.bodyMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),
        _TextField(
          label: context.l10n.agent_create_field_name,
          hint: context.l10n.agent_create_field_name_hint,
          controller: nameController,
        ),
        const SizedBox(height: AppTheme.spacing16),
        _TextField(
          label: context.l10n.agent_create_field_description,
          hint: context.l10n.agent_create_field_description_hint,
          controller: descriptionController,
        ),
        const SizedBox(height: AppTheme.spacing16),
        _TextField(
          label: context.l10n.agent_create_field_system_prompt,
          hint: context.l10n.agent_create_field_system_prompt_hint,
          controller: systemPromptController,
          maxLines: 5,
        ),
      ],
    );
  }
}

/// Review Step
class _ReviewStep extends StatelessWidget {
  final String name;
  final String description;
  final String systemPrompt;
  final LLMModel? llmModel;
  final LLMModel? embeddingModel;

  const _ReviewStep({
    required this.name,
    required this.description,
    required this.systemPrompt,
    required this.llmModel,
    required this.embeddingModel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.agent_create_step_review_title,
          style: AppTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacing8),
        Text(
          context.l10n.agent_create_step_review_desc,
          style: AppTheme.bodyMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),
        _ReviewItem(label: context.l10n.agent_create_review_name, value: name),
        _ReviewItem(label: context.l10n.agent_create_review_description, value: description),
        _ReviewItem(label: context.l10n.agent_create_review_system_prompt, value: systemPrompt),
        _ReviewItem(label: context.l10n.agent_create_review_llm_model, value: llmModel?.displayName ?? context.l10n.agent_create_review_not_selected),
        _ReviewItem(label: context.l10n.agent_create_review_embedding_model, value: embeddingModel?.displayName ?? context.l10n.agent_create_review_not_selected),
      ],
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            value,
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Text field widget
class _TextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int? maxLines;

  const _TextField({
    required this.label,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.labelLarge,
        ),
        const SizedBox(height: AppTheme.spacing8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppTheme.radiusSmall),
              ),
              borderSide: BorderSide(
                color: colors.border,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppTheme.radiusSmall),
              ),
              borderSide: BorderSide(
                color: colors.border,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppTheme.radiusSmall),
              ),
              borderSide: BorderSide(
                color: colors.success,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppTheme.radiusSmall),
              ),
              borderSide: BorderSide(
                color: colors.error,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: colors.surfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Enum to distinguish between LLM and Embedding model types
enum _ModelType { llm, embedding }

/// Provider Section widget
class _ProviderSection extends StatelessWidget {
  final String title;
  final models.ProviderConfig? selectedProvider;
  final dynamic selectedModel;
  final List<models.ProviderConfig> availableProviders;
  final List<dynamic> availableModels;
  final bool isLoadingModels;
  final Function(dynamic) onProviderChanged;
  final Function(dynamic) onModelChanged;
  final _ModelType modelType;

  const _ProviderSection({
    required this.title,
    required this.selectedProvider,
    required this.selectedModel,
    required this.availableProviders,
    required this.availableModels,
    required this.isLoadingModels,
    required this.onProviderChanged,
    required this.onModelChanged,
    required this.modelType,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<KluiCustomColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.titleMedium,
        ),
        const SizedBox(height: AppTheme.spacing8),
        DropdownButtonFormField<models.ProviderConfig>(
          value: selectedProvider,
          decoration: InputDecoration(
            labelText: context.l10n.provider_create_field_provider_type,
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppTheme.radiusSmall),
              ),
              borderSide: BorderSide(
                color: colors.border,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: colors.surfaceVariant,
          ),
          hint: Text(context.l10n.agent_create_select_provider),
          items: availableProviders.map((provider) {
            return DropdownMenuItem<models.ProviderConfig>(
              value: provider,
              child: Text(provider.name),
            );
          }).toList(),
          onChanged: (value) => onProviderChanged(value),
        ),
        const SizedBox(height: AppTheme.spacing16),
        DropdownButtonFormField<dynamic>(
          value: selectedModel,
          decoration: InputDecoration(
            labelText: context.l10n.agent_create_select_model,
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppTheme.radiusSmall),
              ),
              borderSide: BorderSide(
                color: colors.border,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: colors.surfaceVariant,
          ),
          hint: availableModels.isEmpty
              ? Text(
                  selectedProvider == null
                      ? context.l10n.agent_create_select_provider_first
                      : context.l10n.agent_create_no_models,
                  style: TextStyle(
                    color: selectedProvider == null
                        ? colors.textSecondary
                        : colors.error,
                    fontSize: 14,
                  ),
                )
              : Text(context.l10n.agent_create_select_model),
          items: availableModels.map((model) {
            final displayName = (model as LLMModel).displayName;
            return DropdownMenuItem<dynamic>(
              value: model,
              child: Text(displayName),
            );
          }).toList(),
          onChanged: (availableModels.isEmpty || isLoadingModels)
              ? null
              : (value) {
                  onModelChanged(value);
                },
          validator: (value) {
            if (value == null) {
              return context.l10n.agent_create_please_select_model;
            }
            return null;
          },
        ),
      ],
    );
  }
}
