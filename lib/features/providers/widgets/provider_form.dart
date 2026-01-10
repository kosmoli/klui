import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/create_provider_request.dart';
import '../../../core/theme/app_theme.dart';

/// Provider type selection option
class ProviderTypeOption {
  final String type;
  final String displayName;
  final String description;
  final IconData icon;
  final Color color;
  final bool requiresApiKey;
  final bool requiresBaseUrl;
  final bool requiresProject;

  const ProviderTypeOption({
    required this.type,
    required this.displayName,
    required this.description,
    required this.icon,
    required this.color,
    this.requiresApiKey = true,
    this.requiresBaseUrl = false,
    this.requiresProject = false,
  });
}

/// Available provider types
const List<ProviderTypeOption> providerTypes = [
  ProviderTypeOption(
    type: 'openai',
    displayName: 'OpenAI',
    description: 'GPT-4, GPT-3.5 and more',
    icon: Icons.psychology_outlined,
    color: Color(0xFF10A37F),
    requiresApiKey: true,
    requiresBaseUrl: true,
  ),
  ProviderTypeOption(
    type: 'anthropic',
    displayName: 'Anthropic',
    description: 'Claude 3.5 Sonnet, Opus, and more',
    icon: Icons.auto_awesome_outlined,
    color: Color(0xFFD97757),
    requiresApiKey: true,
    requiresBaseUrl: false,
  ),
  ProviderTypeOption(
    type: 'ollama',
    displayName: 'Ollama',
    description: 'Local open-source models',
    icon: Icons.pets_outlined,
    color: Color(0xFF000000),
    requiresApiKey: false,
    requiresBaseUrl: true,
  ),
  ProviderTypeOption(
    type: 'google_ai',
    displayName: 'Google AI',
    description: 'Gemini Pro, Gemini Flash',
    icon: Icons.search_outlined,
    color: Color(0xFF4285F4),
    requiresApiKey: true,
    requiresBaseUrl: false,
  ),
  ProviderTypeOption(
    type: 'google_vertex',
    displayName: 'Google Vertex AI',
    description: 'Enterprise AI models',
    icon: Icons.business_outlined,
    color: Color(0xFF4285F4),
    requiresApiKey: false,
    requiresBaseUrl: false,
    requiresProject: true,
  ),
];

/// Provider creation form with multi-step wizard
class ProviderCreateForm extends ConsumerStatefulWidget {
  final Function(CreateProviderRequest) onSubmit;

  const ProviderCreateForm({
    super.key,
    required this.onSubmit,
  });

  @override
  ConsumerState<ProviderCreateForm> createState() => _ProviderCreateFormState();
}

class _ProviderCreateFormState extends ConsumerState<ProviderCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _projectController = TextEditingController();
  final _locationController = TextEditingController();

  ProviderTypeOption? _selectedProviderType;
  int _currentStep = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    _projectController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Step indicator
        _buildStepIndicator(),
        const SizedBox(height: AppTheme.spacing24),

        // Form content
        Expanded(
          child: Stepper(
            currentStep: _currentStep,
            onStepContinue: _handleStepContinue,
            onStepCancel: _handleStepCancel,
            controlsBuilder: _buildStepperControls,
            steps: [
              // Step 1: Select Provider Type
              Step(
                title: const Text('Provider Type'),
                content: _buildProviderTypeSelection(),
              ),

              // Step 2: Configure Provider
              Step(
                title: const Text('Configuration'),
                content: _buildProviderConfiguration(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _StepIndicator(
          step: 1,
          label: 'Type',
          isActive: _currentStep == 0,
          isCompleted: _currentStep > 0,
        ),
        Expanded(
          child: Container(
            height: 2,
            color: _currentStep > 0
                ? AppTheme.primaryColor
                : AppTheme.borderColor,
          ),
        ),
        _StepIndicator(
          step: 2,
          label: 'Config',
          isActive: _currentStep == 1,
          isCompleted: false,
        ),
      ],
    );
  }

  Widget _buildProviderTypeSelection() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: AppTheme.spacing16,
        mainAxisSpacing: AppTheme.spacing16,
      ),
      itemCount: providerTypes.length,
      itemBuilder: (context, index) {
        final providerType = providerTypes[index];
        final isSelected = _selectedProviderType?.type == providerType.type;

        return Semantics(
          label: 'Provider type: ${providerType.displayName}, ${providerType.description}',
          button: true,
          selected: isSelected,
          hint: 'Double tap to select ${providerType.displayName} provider',
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedProviderType = providerType;
              });
            },
            borderRadius: const BorderRadius.all(
              Radius.circular(AppTheme.radiusMedium),
            ),
            child: Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: isSelected
                  ? providerType.color.withOpacity(0.1)
                  : AppTheme.surfaceColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(AppTheme.radiusMedium),
              ),
              border: Border.all(
                color: isSelected
                    ? providerType.color
                    : AppTheme.borderColor,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      providerType.icon,
                      color: providerType.color,
                      size: 24,
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    Expanded(
                      child: Text(
                        providerType.displayName,
                        style: AppTheme.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  providerType.description,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  Widget _buildProviderConfiguration() {
    if (_selectedProviderType == null) {
      return const Center(
        child: Text('Please select a provider type first'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider Name
            Semantics(
              label: 'Provider name input field',
              hint: 'Enter a unique name for this provider, e.g., my-openai',
              textField: true,
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Provider Name',
                  hintText: 'e.g., my-openai',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a provider name';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),

            // API Key (if required)
            if (_selectedProviderType!.requiresApiKey)
              Semantics(
                label: 'API key input field',
                hint: 'Enter your ${_selectedProviderType!.displayName} API key',
                textField: true,
                child: TextFormField(
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    hintText: _getApiKeyHint(_selectedProviderType!.type),
                    border: const OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (_selectedProviderType!.requiresApiKey &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter an API key';
                    }
                    return null;
                  },
                ),
              ),
            if (_selectedProviderType!.requiresApiKey)
              const SizedBox(height: AppTheme.spacing16),

            // Base URL (if required)
            if (_selectedProviderType!.requiresBaseUrl)
              Semantics(
                label: 'Base URL input field',
                hint: 'Enter the API endpoint URL, e.g., https://api.openai.com/v1',
                textField: true,
                child: TextFormField(
                  controller: _baseUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Base URL',
                    hintText: 'e.g., https://api.openai.com/v1',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_selectedProviderType!.requiresBaseUrl &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter a base URL';
                    }
                    return null;
                  },
                ),
              ),
            if (_selectedProviderType!.requiresBaseUrl)
              const SizedBox(height: AppTheme.spacing16),

            // Project (for Google Vertex)
            if (_selectedProviderType!.requiresProject) ...[
              Semantics(
                label: 'Google Cloud project ID input field',
                hint: 'Enter your Google Cloud project ID, e.g., my-project',
                textField: true,
                child: TextFormField(
                  controller: _projectController,
                  decoration: const InputDecoration(
                    labelText: 'Google Cloud Project',
                    hintText: 'e.g., my-project',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_selectedProviderType!.requiresProject &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter a project ID';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
              Semantics(
                label: 'Google Cloud location input field',
                hint: 'Enter the Google Cloud region, e.g., us-central1',
                textField: true,
                child: TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'e.g., us-central1',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_selectedProviderType!.requiresProject &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),
            ],

            // Provider info
            Semantics(
              label: 'Selected provider: ${_selectedProviderType!.displayName}',
              value: '${_selectedProviderType!.description}',
              container: true,
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                color: AppTheme.surfaceVariantColor,
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppTheme.radiusMedium),
                ),
                border: Border.all(
                  color: AppTheme.borderColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _selectedProviderType!.icon,
                        color: _selectedProviderType!.color,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacing8),
                      Text(
                        'Selected: ${_selectedProviderType!.displayName}',
                        style: AppTheme.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  Text(
                    _selectedProviderType!.description,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepperControls(
    BuildContext context,
    ControlsDetails details,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Row(
        children: [
          if (_currentStep > 0)
            TextButton(
              onPressed: details.onStepCancel,
              child: const Text('Back'),
            ),
          const Spacer(),
          if (_currentStep == 0)
            ElevatedButton(
              onPressed: _selectedProviderType != null ? details.onStepContinue : null,
              child: const Text('Next'),
            )
          else
            ElevatedButton(
              onPressed: _handleSubmit,
              child: const Text('Create Provider'),
            ),
        ],
      ),
    );
  }

  void _handleStepContinue() {
    if (_currentStep == 0 && _selectedProviderType != null) {
      setState(() {
        _currentStep = 1;
      });
    }
  }

  void _handleStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      CreateProviderRequest request;

      switch (_selectedProviderType!.type) {
        case 'openai':
          request = CreateProviderRequest.openai(
            name: _nameController.text,
            apiKey: _apiKeyController.text,
            baseUrl: _baseUrlController.text.isNotEmpty
                ? _baseUrlController.text
                : null,
          );
          break;
        case 'anthropic':
          request = CreateProviderRequest.anthropic(
            name: _nameController.text,
            apiKey: _apiKeyController.text,
          );
          break;
        case 'ollama':
          request = CreateProviderRequest.ollama(
            name: _nameController.text,
            baseUrl: _baseUrlController.text,
          );
          break;
        case 'google_ai':
          request = CreateProviderRequest.googleAi(
            name: _nameController.text,
            apiKey: _apiKeyController.text,
          );
          break;
        case 'google_vertex':
          request = CreateProviderRequest.googleVertex(
            name: _nameController.text,
            project: _projectController.text,
            location: _locationController.text,
          );
          break;
        default:
          return;
      }

      widget.onSubmit(request);
    }
  }

  String _getApiKeyHint(String providerType) {
    switch (providerType) {
      case 'openai':
        return 'sk-...';
      case 'anthropic':
        return 'sk-ant-...';
      case 'google_ai':
        return 'AIza...';
      default:
        return 'Enter your API key';
    }
  }
}

class _StepIndicator extends StatelessWidget {
  final int step;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepIndicator({
    required this.step,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: AppTheme.spacing8,
      ),
      decoration: BoxDecoration(
        color: isActive || isCompleted
            ? AppTheme.primaryColor
            : AppTheme.surfaceVariantColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive || isCompleted
              ? AppTheme.primaryColor
              : AppTheme.borderColor,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isCompleted ? '✓' : '$step',
            style: AppTheme.titleMedium.copyWith(
              color: isActive || isCompleted ? Colors.white : null,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: AppTheme.labelSmall.copyWith(
              color: isActive || isCompleted ? Colors.white : null,
            ),
          ),
        ],
      ),
    );
  }
}
