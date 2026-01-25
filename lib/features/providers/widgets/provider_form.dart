import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/models/create_provider_request.dart';
import '../../../core/models/provider.dart' as models;
import '../../../core/theme/klui_text_styles.dart';
import '../../../core/theme/klui_theme_extension.dart';

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

/// Available provider types - function to get them with theme colors
List<ProviderTypeOption> getProviderTypes(BuildContext context) {
  final colors = Theme.of(context).extension<KluiCustomColors>()!;

  return [
    ProviderTypeOption(
      type: 'openai',
      displayName: 'OpenAI',
      description: 'GPT-4, GPT-3.5 and more',
      icon: Icons.psychology_outlined,
      color: colors.userBubble,
      requiresApiKey: true,
      requiresBaseUrl: true,
    ),
    ProviderTypeOption(
      type: 'anthropic',
      displayName: 'Anthropic',
      description: 'Claude 3.5 Sonnet, Opus, and more',
      icon: Icons.auto_awesome_outlined,
      color: colors.userBubble,
      requiresApiKey: true,
      requiresBaseUrl: false,
    ),
    ProviderTypeOption(
      type: 'ollama',
      displayName: 'Ollama',
      description: 'Local open-source models',
      icon: Icons.pets_outlined,
      color: colors.userBubble,
      requiresApiKey: false,
      requiresBaseUrl: true,
    ),
    ProviderTypeOption(
      type: 'google_ai',
      displayName: 'Google AI',
      description: 'Gemini Pro, Gemini Flash',
      icon: Icons.search_outlined,
      color: colors.userBubble,
      requiresApiKey: true,
      requiresBaseUrl: false,
    ),
    ProviderTypeOption(
      type: 'google_vertex',
      displayName: 'Google Vertex AI',
      description: 'Enterprise AI models',
      icon: Icons.business_outlined,
      color: colors.userBubble,
      requiresApiKey: false,
      requiresBaseUrl: false,
      requiresProject: true,
    ),
  ];
}

/// Provider form (supports both create and edit modes)
class ProviderForm extends ConsumerStatefulWidget {
  final models.ProviderConfig? initialData;
  final Function(CreateProviderRequest) onSubmit;
  final String submitButtonText;

  const ProviderForm({
    super.key,
    this.initialData,
    required this.onSubmit,
    this.submitButtonText = 'Create',
  });

  @override
  ConsumerState<ProviderForm> createState() => _ProviderFormState();
}

class _ProviderFormState extends ConsumerState<ProviderForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _baseUrlController;

  ProviderTypeOption? _selectedProviderType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData?.name ?? '');
    _apiKeyController = TextEditingController(text: '');
    _baseUrlController = TextEditingController(text: widget.initialData?.baseUrl ?? '');

    // Set initial provider type from initialData
    if (widget.initialData != null) {
      _selectedProviderType = _getProviderTypeOption(widget.initialData!.providerType);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  ProviderTypeOption? _getProviderTypeOption(String providerType) {
    final types = getProviderTypes(context);
    for (final t in types) {
      if (t.type == providerType) {
        return t;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
                  items: getProviderTypes(context).map((providerType) {
                    return DropdownMenuItem<ProviderTypeOption>(
                      value: providerType,
                      child: Row(
                        children: [
                          Icon(
                            providerType.icon,
                            color: providerType.color,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(providerType.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProviderType = value;
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
            const SizedBox(height: 24),

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
              const SizedBox(height: 16),

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
                const SizedBox(height: 16),

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
                const SizedBox(height: 16),

              // Selected provider info
              _buildSelectedProviderInfo(context),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  child: Text(widget.submitButtonText),
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

    final colors = Theme.of(context).extension<KluiCustomColors>()!;

    return MergeSemantics(
      child: Semantics(
        label: context.l10n.provider_create_selected_semantic(
          _selectedProviderType!.displayName,
        ),
        value: _selectedProviderType!.description,
        container: true,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: const BorderRadius.all(
              Radius.circular(12),
            ),
            border: Border.all(
              color: colors.border,
              width: 2,
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
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.provider_create_selected(_selectedProviderType!.displayName),
                    style: KluiTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _selectedProviderType!.description,
                style: KluiTextStyles.bodySmall.copyWith(
                  color: colors.textSecondary,
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
            apiKey: _apiKeyController.text.isNotEmpty
                ? _apiKeyController.text
                : null,
            baseUrl: _baseUrlController.text.isNotEmpty
                ? _baseUrlController.text
                : null,
          );
          break;
        case 'anthropic':
          request = CreateProviderRequest.anthropic(
            name: _nameController.text,
            apiKey: _apiKeyController.text.isNotEmpty
                ? _apiKeyController.text
                : null,
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
            apiKey: _apiKeyController.text.isNotEmpty
                ? _apiKeyController.text
                : null,
          );
          break;
        case 'google_vertex':
        default:
          // For edit mode, skip google_vertex or unknown types
          // In create mode, this would need proper handling
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

/// Provider creation form (single-page with dropdown) - now uses ProviderForm
class ProviderCreateForm extends ConsumerWidget {
  final Function(CreateProviderRequest) onSubmit;

  const ProviderCreateForm({
    super.key,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderForm(
      onSubmit: onSubmit,
      submitButtonText: context.l10n.provider_create_button_create,
    );
  }
}

/// Provider edit form - uses ProviderForm with initial data
class ProviderEditForm extends ConsumerWidget {
  final models.ProviderConfig initialData;
  final Function(CreateProviderRequest) onSubmit;

  const ProviderEditForm({
    super.key,
    required this.initialData,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderForm(
      initialData: initialData,
      onSubmit: onSubmit,
      submitButtonText: context.l10n.provider_edit_button_update,
    );
  }
}
