import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extensions/context_extensions.dart';
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

/// Provider creation form (single-page with dropdown)
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider Type Selection (Dropdown)
            MergeSemantics(
              child: Semantics(
                label: context.l10n.provider_create_field_provider_type_semantic,
                hint: context.l10n.provider_create_field_provider_type_hint_semantic,
                child: DropdownButtonFormField<ProviderTypeOption>(
                  value: _selectedProviderType,
                  decoration: InputDecoration(
                    labelText: context.l10n.provider_create_field_provider_type,
                    hintText: context.l10n.provider_create_field_provider_type_hint,
                    border: const OutlineInputBorder(),
                  ),
                  items: providerTypes.map((providerType) {
                    return DropdownMenuItem<ProviderTypeOption>(
                      value: providerType,
                      child: Row(
                        children: [
                          Icon(
                            providerType.icon,
                            color: providerType.color,
                            size: 20,
                          ),
                          const SizedBox(width: AppTheme.spacing8),
                          Text(providerType.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProviderType = value;
                      // Clear fields when provider type changes
                      _apiKeyController.clear();
                      _baseUrlController.clear();
                      _projectController.clear();
                      _locationController.clear();
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return context.l10n.provider_create_validation_provider_type;
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),

            // Configuration fields (shown when type is selected)
            if (_selectedProviderType != null) ...[
              // Provider Name
              Semantics(
                label: context.l10n.provider_create_field_name_semantic,
                hint: context.l10n.provider_create_field_name_hint_semantic,
                textField: true,
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: context.l10n.provider_create_field_name,
                    hintText: context.l10n.provider_create_field_name_hint,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.l10n.provider_create_validation_name;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),

              // API Key (if required)
              if (_selectedProviderType!.requiresApiKey)
                Semantics(
                  label: context.l10n.provider_create_field_api_key_semantic,
                  hint: context.l10n.provider_create_field_api_key_hint_semantic(
                    _selectedProviderType!.displayName,
                  ),
                  textField: true,
                  child: TextFormField(
                    controller: _apiKeyController,
                    decoration: InputDecoration(
                      labelText: context.l10n.provider_create_field_api_key,
                      hintText: _getApiKeyHint(context, _selectedProviderType!.type),
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (_selectedProviderType!.requiresApiKey &&
                          (value == null || value.isEmpty)) {
                        return context.l10n.provider_create_validation_api_key;
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
                  label: context.l10n.provider_create_field_base_url_semantic,
                  hint: context.l10n.provider_create_field_base_url_hint_semantic,
                  textField: true,
                  child: TextFormField(
                    controller: _baseUrlController,
                    decoration: InputDecoration(
                      labelText: context.l10n.provider_create_field_base_url,
                      hintText: context.l10n.provider_create_field_base_url_hint,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_selectedProviderType!.requiresBaseUrl &&
                          (value == null || value.isEmpty)) {
                        return context.l10n.provider_create_validation_base_url;
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
                  label: context.l10n.provider_create_field_project_semantic,
                  hint: context.l10n.provider_create_field_project_hint_semantic,
                  textField: true,
                  child: TextFormField(
                    controller: _projectController,
                    decoration: InputDecoration(
                      labelText: context.l10n.provider_create_field_project,
                      hintText: context.l10n.provider_create_field_project_hint,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_selectedProviderType!.requiresProject &&
                          (value == null || value.isEmpty)) {
                        return context.l10n.provider_create_validation_project;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                Semantics(
                  label: context.l10n.provider_create_field_location_semantic,
                  hint: context.l10n.provider_create_field_location_hint_semantic,
                  textField: true,
                  child: TextFormField(
                    controller: _locationController,
                    decoration: InputDecoration(
                      labelText: context.l10n.provider_create_field_location,
                      hintText: context.l10n.provider_create_field_location_hint,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_selectedProviderType!.requiresProject &&
                          (value == null || value.isEmpty)) {
                        return context.l10n.provider_create_validation_location;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: AppTheme.spacing16),
              ],

              // Selected provider info
              _buildSelectedProviderInfo(context),
              const SizedBox(height: AppTheme.spacing32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  child: Text(context.l10n.provider_create_button_create),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedProviderInfo(BuildContext context) {
    if (_selectedProviderType == null) {
      return const SizedBox.shrink();
    }

    return MergeSemantics(
      child: Semantics(
        label: context.l10n.provider_create_selected_semantic(
          _selectedProviderType!.displayName,
        ),
        value: _selectedProviderType!.description,
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
                  ExcludeSemantics(
                    child: Icon(
                      _selectedProviderType!.icon,
                      color: _selectedProviderType!.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  Text(
                    context.l10n.provider_create_selected(_selectedProviderType!.displayName),
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
    );
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

  String _getApiKeyHint(BuildContext context, String providerType) {
    switch (providerType) {
      case 'openai':
        return context.l10n.provider_create_field_api_key_hint_openai;
      case 'anthropic':
        return context.l10n.provider_create_field_api_key_hint_anthropic;
      case 'google_ai':
        return context.l10n.provider_create_field_api_key_hint_google_ai;
      default:
        return context.l10n.provider_create_field_api_key_hint_default;
    }
  }
}
