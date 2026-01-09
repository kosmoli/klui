import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/api_providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/models/provider.dart' as models;
import '../../../../core/models/llm_model.dart';
import '../../../../core/models/embedding_model.dart';

/// Multi-step Agent Creation Wizard with Neo-Brutalist design
///
/// Steps:
/// 0. Provider Selection (LLM Provider + Embedding Provider)
/// 1. Basic Information (name, description, system prompt)
/// 2. Model Configuration (model, temperature, max tokens)
/// 3. Review and Confirm
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
  final _temperatureController = TextEditingController(text: '0.7');
  final _maxTokensController = TextEditingController(text: '16384');

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
    _temperatureController.dispose();
    _maxTokensController.dispose();
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

        // Filter by model_type field from API
        final llmModels = allModels.where((m) => m.modelType == 'llm').toList();
        final embeddingModels = allModels.where((m) => m.modelType == 'embedding').toList();

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
            content: Text('Failed to load data: $e'),
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
            content: Text('Failed to load LLM models: $e'),
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
            content: Text('Failed to load embedding models: $e'),
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
        tooltip: 'Back to Agents',
      ),
      title: const Text('Create Agent'),
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
              'Step ${_currentStep + 1}/4',
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
        4,
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
        return _ModelConfigStep(
          selectedLLMModel: _selectedLLMModel,
          onLLMModelChanged: (model) => setState(() => _selectedLLMModel = model),
          availableLLMModels: _availableLLMModels,
          temperatureController: _temperatureController,
          maxTokensController: _maxTokensController,
        );
      case 3:
        return _ReviewStep(
          name: _nameController.text,
          description: _descriptionController.text,
          systemPrompt: _systemPromptController.text,
          llmModel: _selectedLLMModel,
          embeddingModel: _selectedEmbeddingModel,
          temperature: _temperatureController.text,
          maxTokens: _maxTokensController.text,
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
                  child: const Text('Back'),
                ),
              ),

            if (_currentStep > 0)
              const SizedBox(width: AppTheme.spacing16)
            else
              const SizedBox.shrink(),

            // Next/Create button
            Expanded(
              flex: _currentStep > 0 ? 1 : 2,
              child: _currentStep < 3
                  ? ElevatedButton(
                      onPressed: _handleNext,
                      child: const Text('Next'),
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
                          : const Text('Create Agent'),
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
            const SnackBar(
              content: Text('Please select an LLM provider and model'),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        if (_selectedEmbeddingProvider == null || _selectedEmbeddingModel == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select an Embedding provider and model'),
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
            const SnackBar(
              content: Text('Please select an LLM model'),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        if (_selectedEmbeddingModel == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select an Embedding model'),
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
          const SnackBar(
            content: Text('Please enter an agent name'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      if (_systemPromptController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a system prompt'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    } else if (_currentStep == 2) {
      // Validate model config
      final temp = double.tryParse(_temperatureController.text);
      if (temp == null || temp < 0 || temp > 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Temperature must be between 0 and 2'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      final maxTokens = int.tryParse(_maxTokensController.text);
      if (maxTokens == null || maxTokens < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Max tokens must be a positive number'),
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
      final client = ref.read(apiClientProvider);

      // Build LLM config from selected model
      final llmConfig = {
        'model': _selectedLLMModel!.model,
        'model_endpoint_type': _selectedLLMModel!.modelEndpointType,
        'model_endpoint': _selectedLLMModel!.modelEndpoint,
        'provider_name': _selectedLLMModel!.providerName,
        'provider_category': _selectedLLMModel!.providerCategory,
        'context_window': _selectedLLMModel!.contextWindow,
        'put_inner_thoughts_in_kwargs':
            _selectedLLMModel!.putInnerThoughtsInKwargs,
        'temperature': double.parse(_temperatureController.text),
        'max_tokens': int.parse(_maxTokensController.text),
      };

      // Build embedding config from selected model
      final embeddingConfig = {
        'embedding_endpoint_type': _selectedEmbeddingModel!.modelEndpointType,
        'embedding_endpoint': _selectedEmbeddingModel!.modelEndpoint,
        'embedding_model': _selectedEmbeddingModel!.model,
        'embedding_dim': 1536,  // Default embedding dimension for OpenAI models
        'provider_name': _selectedEmbeddingModel!.providerName,
      };

      final requestData = {
        'name': _nameController.text.trim(),
        if (_descriptionController.text.trim().isNotEmpty)
          'description': _descriptionController.text.trim(),
        'system': _systemPromptController.text.trim(),
        'llm_config': llmConfig,
        'embedding_config': embeddingConfig,
      };

      final response = await client.post(
        '/agents/',
        body: jsonEncode(requestData),
      );

      if (context.mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          final agentName = responseData['name'] ?? 'Agent';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$agentName created successfully'),
              backgroundColor: AppTheme.primaryColor,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Refresh list and navigate back
          ref.invalidate(agentListProvider);
          context.go('/agents');
        } else {
          // Parse error response for more details
          String errorMessage = 'Failed to create agent: ${response.statusCode}';
          try {
            final errorData = jsonDecode(response.body);
            if (errorData is Map && errorData.containsKey('detail')) {
              errorMessage = 'Error: ${errorData['detail']}';
            }
          } catch (_) {
            // If parsing fails, use default message
          }
          throw Exception(errorMessage);
        }
      }
    } catch (e) {
      if (context.mounted) {
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
          byokMode ? 'Provider Selection' : 'Model Selection',
          style: AppTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacing8),
        Text(
          byokMode
              ? 'Select LLM and Embedding providers for your agent'
              : 'Select LLM and Embedding models for your agent',
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
                'BYOK Mode',
                style: AppTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                'Enable Bring Your Own Key (BYOK) mode to use custom providers',
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
                    byokMode ? 'BYOK Enabled' : 'BYOK Disabled',
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
            title: 'LLM Provider',
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
            title: 'Embedding Provider',
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
            title: 'LLM Model',
            selectedModel: selectedLLMModel,
            availableModels: availableLLMModels,
            isLoadingModels: isLoadingLLMModels,
            onModelChanged: (value) => onLLMModelChanged(value as LLMModel?),
            modelType: _ModelType.llm,
          ),

          const SizedBox(height: AppTheme.spacing24),

          // Embedding Model Selection
          _DirectModelSection(
            title: 'Embedding Model',
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
          'Basic Information',
          style: AppTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacing8),
        Text(
          'Enter the basic information for your agent',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),
        _TextField(
          label: 'Agent Name',
          hint: 'Enter a name for your agent',
          controller: nameController,
        ),
        const SizedBox(height: AppTheme.spacing16),
        _TextField(
          label: 'Description',
          hint: 'Enter a description for your agent',
          controller: descriptionController,
        ),
        const SizedBox(height: AppTheme.spacing16),
        _TextField(
          label: 'System Prompt',
          hint: 'Enter the system prompt for your agent',
          controller: systemPromptController,
          maxLines: 5,
        ),
      ],
    );
  }
}

/// Model Configuration Step
class _ModelConfigStep extends StatelessWidget {
  final LLMModel? selectedLLMModel;
  final Function(LLMModel?) onLLMModelChanged;
  final List<LLMModel> availableLLMModels;
  final TextEditingController temperatureController;
  final TextEditingController maxTokensController;

  const _ModelConfigStep({
    required this.selectedLLMModel,
    required this.onLLMModelChanged,
    required this.availableLLMModels,
    required this.temperatureController,
    required this.maxTokensController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Model Configuration',
          style: AppTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacing8),
        Text(
          'Configure the model parameters for your agent',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),
        _NumberField(
          label: 'Temperature',
          hint: 'Enter temperature (0.0 - 1.0)',
          controller: temperatureController,
          min: 0.0,
          max: 1.0,
        ),
        const SizedBox(height: AppTheme.spacing16),
        _NumberField(
          label: 'Max Tokens',
          hint: 'Enter max tokens',
          controller: maxTokensController,
          min: 1,
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
  final String temperature;
  final String maxTokens;

  const _ReviewStep({
    required this.name,
    required this.description,
    required this.systemPrompt,
    required this.llmModel,
    required this.embeddingModel,
    required this.temperature,
    required this.maxTokens,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review and Confirm',
          style: AppTheme.headlineSmall,
        ),
        const SizedBox(height: AppTheme.spacing8),
        Text(
          'Review your agent configuration before creating',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: AppTheme.spacing24),
        _ReviewItem(label: 'Name', value: name),
        _ReviewItem(label: 'Description', value: description),
        _ReviewItem(label: 'System Prompt', value: systemPrompt),
        _ReviewItem(label: 'LLM Model', value: llmModel?.displayName ?? 'Not selected'),
        _ReviewItem(label: 'Embedding Model', value: embeddingModel?.displayName ?? 'Not selected'),
        _ReviewItem(label: 'Temperature', value: temperature),
        _ReviewItem(label: 'Max Tokens', value: maxTokens),
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

/// Number field widget
class _NumberField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final double? min;
  final double? max;

  const _NumberField({
    required this.label,
    required this.hint,
    required this.controller,
    this.min,
    this.max,
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
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
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
            labelText: 'Provider',
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppTheme.radiusSmall),
              ),
              borderSide: BorderSide(
                color: AppTheme.borderColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppTheme.surfaceVariantColor,
          ),
          hint: const Text('Select a provider'),
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
            labelText: 'Model',
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppTheme.radiusSmall),
              ),
              borderSide: BorderSide(
                color: AppTheme.borderColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppTheme.surfaceVariantColor,
          ),
          hint: availableModels.isEmpty
              ? Text(
                  selectedProvider == null
                      ? 'Select a provider first'
                      : 'No models available',
                  style: TextStyle(
                    color: selectedProvider == null
                        ? AppTheme.textSecondaryColor
                        : AppTheme.errorColor,
                    fontSize: 14,
                  ),
                )
              : const Text('Select a model'),
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
              return 'Please select a model';
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
            labelText: 'Model',
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppTheme.radiusSmall),
              ),
              borderSide: BorderSide(
                color: AppTheme.borderColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppTheme.surfaceVariantColor,
          ),
          hint: availableModels.isEmpty
              ? Text(
                  'No models available',
                  style: TextStyle(
                    color: AppTheme.errorColor,
                    fontSize: 14,
                  ),
                )
              : const Text('Select a model'),
          items: availableModels.map((model) {
            return DropdownMenuItem<LLMModel>(
              value: model,
              child: Text(model.displayName),
            );
          }).toList(),
          onChanged: (availableModels.isEmpty || isLoadingModels)
              ? null
              : onModelChanged,
          validator: (value) {
            if (value == null) {
              return 'Please select a model';
            }
            return null;
          },
        ),
      ],
    );
  }
}
