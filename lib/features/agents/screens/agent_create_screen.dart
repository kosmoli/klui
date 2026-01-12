import 'dart:convert';
import '../../../core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/klui_theme_extension.dart';
import '../../../../core/models/provider.dart' as models;
import '../../../../core/models/llm_model.dart';
import '../../../../core/models/create_agent_request.dart';

/// Multi-step Agent Creation Wizard with Neo-Brutalist design
///
/// Steps:
/// 0. Provider Selection (LLM Provider + Embedding Provider)
/// 1. Basic Information (name, description, system prompt)
/// 2. Review and Confirm
class AgentCreateScreen extends ConsumerStatefulWidget {
  const AgentCreateScreen({super.key});

  @override
  ConsumerState<AgentCreateScreen> createState() => _AgentCreateScreenState();
}

class _AgentCreateScreenState extends ConsumerState<AgentCreateScreen> {
  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _systemPromptController = TextEditingController();

  // Form key
  final _formKey = GlobalKey<FormState>();

  // Current step (0-indexed)
  int _currentStep = 0;

  // BYOK Mode
  bool _byokMode = false;

  // Selected providers
  models.ProviderConfig? _selectedLLMProvider;
  models.ProviderConfig? _selectedEmbeddingProvider;

  // Selected models
  LLMModel? _selectedLLMModel;
  LLMModel? _selectedEmbeddingModel;  // Changed to LLMModel

  // Available providers and models
  List<models.ProviderConfig> _availableProviders = [];
  List<LLMModel> _availableLLMModels = [];
  List<LLMModel> _availableEmbeddingModels = [];  // Changed to LLMModel

  // Loading state
  bool _isLoadingProviders = true;
  bool _isLoadingLLMModels = false;
  bool _isLoadingEmbeddingModels = false;

  // Is creating
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _loadProvidersAndModels();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _systemPromptController.dispose();
    super.dispose();
  }

  Future<void> _loadProvidersAndModels() async {
    setState(() => _isLoadingProviders = true);

    try {
      if (_byokMode) {
        // BYOK mode: load providers from database
        final providers = await ref.read(providerListProvider.future);

        if (mounted) {
          setState(() {
            _availableProviders = providers;
            _availableLLMModels = [];
            _availableEmbeddingModels = [];
            _isLoadingProviders = false;
          });
        }
      } else {
        // Non-BYOK mode: load base models directly (no provider selection needed)
        final allModels = await ref.read(baseLLMModelListProvider.future);

        // Also load embedding models from /v1/models/embedding
        final embeddingResponse = await ref.read(apiClientProvider).get('/models/embedding');
        final List<dynamic> embeddingData = jsonDecode(embeddingResponse.body);
        final embeddingModels = embeddingData
            .map((json) => LLMModel.fromJson(json as Map<String, dynamic>))
            .toList();

        // Filter LLM models by model_type field from API
        final llmModels = allModels.where((m) => m.modelType == 'llm').toList();

        if (mounted) {
          setState(() {
            _availableProviders = [];
            _availableLLMModels = llmModels;
            _availableEmbeddingModels = embeddingModels;
            _isLoadingProviders = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProviders = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.agent_create_error_loading(e.toString())),
            backgroundColor: AppTheme.errorColor,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.agent_create_error_llm_models(e.toString())),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Dynamically load Embedding models for a specific provider
  /// Uses the same /v1/models/ endpoint with provider_name filter
  Future<void> _loadEmbeddingModelsForProvider(String providerName) async {
    setState(() => _isLoadingEmbeddingModels = true);

    try {
      final models = await ref.read(llmModelListByProviderProvider(providerName).future);

      // No filtering - show exactly what the provider returns
      if (mounted) {
        setState(() {
          _availableEmbeddingModels = models;
          _isLoadingEmbeddingModels = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingEmbeddingModels = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.agent_create_error_embedding_models(e.toString())),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/agents'),
        tooltip: context.l10n.agent_create_back_tooltip,
      ),
      title: Text(context.l10n.agent_create_title),
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
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.all(
                Radius.circular(AppTheme.radiusSmall),
              ),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              context.l10n.agent_create_step_indicator(_currentStep + 1, 3),
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            _buildProgressBar(),
            const SizedBox(height: AppTheme.spacing24),

            // Step content
            _buildStepContent(),

            const SizedBox(height: AppTheme.spacing80),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
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
                  ? AppTheme.primaryColor
                  : AppTheme.surfaceVariantColor,
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
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
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
          byokMode: _byokMode,
          onLLMProviderChanged: (provider) {
            setState(() {
              _selectedLLMProvider = provider;
              _selectedLLMModel = null;
            });
            // Dynamically load models for the selected provider
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
            // Dynamically load models for the selected provider
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
          onByokModeChanged: (value) {
            setState(() {
              _byokMode = value;
              // Clear selections when switching modes
              _selectedLLMProvider = null;
              _selectedEmbeddingProvider = null;
              _selectedLLMModel = null;
              _selectedEmbeddingModel = null;
              _availableLLMModels = [];
              _availableEmbeddingModels = [];
            });
            // Reload data based on new mode
            _loadProvidersAndModels();
          },
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
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          top: BorderSide(
            color: AppTheme.borderColor,
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
                  child: Text(context.l10n.agent_create_button_back),
                ),
              ),

            if (_currentStep > 0)
              const SizedBox(width: AppTheme.spacing16)
            else
              const SizedBox.shrink(),

            // Next/Create button
            Expanded(
              flex: _currentStep > 0 ? 1 : 2,
              child: _currentStep < 2
                  ? ElevatedButton(
                      onPressed: _handleNext,
                      child: Text(context.l10n.agent_create_button_next),
                    )
                  : ElevatedButton(
                      onPressed: _isCreating ? null : _handleCreate,
                      child: _isCreating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(context.l10n.agent_create_button_create),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNext() {
    if (_currentStep == 0) {
      // Validate provider/model selection
      if (_byokMode) {
        // BYOK mode: validate provider and model selection
        if (_selectedLLMProvider == null || _selectedLLMModel == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.agent_create_validation_llm_provider),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        if (_selectedEmbeddingProvider == null || _selectedEmbeddingModel == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.agent_create_validation_embedding_provider),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      } else {
        // Non-BYOK mode: only validate model selection
        if (_selectedLLMModel == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.agent_create_validation_llm_model),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        if (_selectedEmbeddingModel == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.agent_create_validation_embedding_model),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }
    } else if (_currentStep == 1) {
      // Validate basic info
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.agent_create_validation_name),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      if (_systemPromptController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.agent_create_validation_system_prompt),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    setState(() => _currentStep++);
  }

  Future<void> _handleCreate() async {
    setState(() => _isCreating = true);

    try {
      // Create CreateAgentRequest - it will automatically detect BYOK mode
      // and generate the correct API format
      final request = CreateAgentRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        llmModel: _selectedLLMModel!,
        embeddingModel: _selectedEmbeddingModel!,
        systemPrompt: _systemPromptController.text.trim(),
      );

      // Use the createAgent provider which handles the format automatically
      final agent = await ref.read(createAgentProvider(request).future);

      if (mounted) {
        final colors = Theme.of(context).extension<KluiCustomColors>()!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.agent_create_success(agent.name),
              style: TextStyle(color: colors.userText), // Dark text for contrast
            ),
            backgroundColor: colors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Refresh list and navigate back
        ref.invalidate(agentListProvider);
        context.go('/agents');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}

/// Step 0: Provider Selection
class _ProviderSelectionStep extends StatelessWidget {
  final models.ProviderConfig? selectedLLMProvider;
  final models.ProviderConfig? selectedEmbeddingProvider;
  final LLMModel? selectedLLMModel;
  final LLMModel? selectedEmbeddingModel;  // Changed to LLMModel
  final List<models.ProviderConfig> availableProviders;
  final List<LLMModel> availableLLMModels;
  final List<LLMModel> availableEmbeddingModels;  // Changed to LLMModel
  final bool isLoadingLLMModels;
  final bool isLoadingEmbeddingModels;  // Added
  final bool byokMode;  // Added
  final Function(models.ProviderConfig?) onLLMProviderChanged;
  final Function(models.ProviderConfig?) onEmbeddingProviderChanged;
  final Function(LLMModel?) onLLMModelChanged;
  final Function(LLMModel?) onEmbeddingModelChanged;  // Changed to LLMModel
  final Function(bool) onByokModeChanged;  // Added

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
    required this.byokMode,
    required this.onLLMProviderChanged,
    required this.onEmbeddingProviderChanged,
    required this.onLLMModelChanged,
    required this.onEmbeddingModelChanged,
    required this.onByokModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step title
        Text(
          byokMode ? context.l10n.agent_create_step_provider_title : context.l10n.agent_create_step_model_title,
          style: AppTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacing8),
        Text(
          byokMode
              ? context.l10n.agent_create_step_provider_desc
              : context.l10n.agent_create_step_model_desc,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),

        // BYOK Mode Toggle
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(AppTheme.radiusMedium),
            ),
            border: Border.all(
              color: AppTheme.borderColor,
              width: 2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.agent_create_byok_mode,
                style: AppTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                context.l10n.agent_create_byok_desc,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
              Row(
                children: [
                  Switch(
                    value: byokMode,
                    onChanged: onByokModeChanged,
                    activeColor: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  Text(
                    byokMode ? context.l10n.agent_create_byok_enabled : context.l10n.agent_create_byok_disabled,
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),

        if (byokMode) ...[
          // BYOK Mode: Show Provider Selection
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

          // Embedding Provider Section (only show in BYOK mode)
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
        ] else ...[
          // Non-BYOK Mode: Direct Model Selection (no Provider selection)
          const SizedBox(height: AppTheme.spacing24),

          // LLM Model Selection
          _DirectModelSection(
            title: context.l10n.agent_create_llm_model,
            selectedModel: selectedLLMModel,
            availableModels: availableLLMModels,
            isLoadingModels: isLoadingLLMModels,
            onModelChanged: (value) => onLLMModelChanged(value as LLMModel?),
            modelType: _ModelType.llm,
          ),

          const SizedBox(height: AppTheme.spacing24),

          // Embedding Model Selection
          _DirectModelSection(
            title: context.l10n.agent_create_embedding_model,
            selectedModel: selectedEmbeddingModel,
            availableModels: availableEmbeddingModels,
            isLoadingModels: false,
            onModelChanged: (value) => onEmbeddingModelChanged(value as LLMModel?),
            modelType: _ModelType.embedding,
          ),
        ],
      ],
    );
  }
}

/// Enum to distinguish between LLM and Embedding model types
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
            color: AppTheme.textSecondaryColor,
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
            color: AppTheme.textSecondaryColor,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.labelSmall.copyWith(
              color: AppTheme.textSecondaryColor,
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
                color: AppTheme.borderColor,
                width: 2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppTheme.radiusSmall),
              ),
              borderSide: BorderSide(
                color: AppTheme.borderColor,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppTheme.radiusSmall),
              ),
              borderSide: BorderSide(
                color: AppTheme.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppTheme.radiusSmall),
              ),
              borderSide: BorderSide(
                color: AppTheme.errorColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppTheme.surfaceVariantColor,
          ),
        ),
      ],
    );
  }
}

/// Enum to distinguish between LLM and Embedding model types
enum _ModelType { llm, embedding }

/// Provider Section widget for BYOK mode
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

/// Direct model selection widget for non-BYOK mode
class _DirectModelSection extends StatelessWidget {
  final String title;
  final LLMModel? selectedModel;
  final List<LLMModel> availableModels;
  final bool isLoadingModels;
  final Function(LLMModel?) onModelChanged;
  final _ModelType modelType;

  const _DirectModelSection({
    required this.title,
    required this.selectedModel,
    required this.availableModels,
    required this.isLoadingModels,
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
        DropdownButtonFormField<LLMModel>(
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
                  context.l10n.agent_create_no_models,
                  style: TextStyle(
                    color: colors.error,
                    fontSize: 14,
                  ),
                )
              : Text(context.l10n.agent_create_select_model),
          items: availableModels.map((model) {
            return DropdownMenuItem<LLMModel>(
              value: model,
              child: Text(model.handle), // Use handle to show provider/model format
            );
          }).toList(),
          onChanged: (availableModels.isEmpty || isLoadingModels)
              ? null
              : onModelChanged,
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
