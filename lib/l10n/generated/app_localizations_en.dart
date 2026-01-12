// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Klui - Letta Agent Management';

  @override
  String get page_not_found => 'Page not found';

  @override
  String get nav_agents => 'Agents';

  @override
  String get nav_providers => 'Providers';

  @override
  String get nav_chat => 'Chat';

  @override
  String get nav_agents_tab => 'Agents tab';

  @override
  String get nav_providers_tab => 'Providers tab';

  @override
  String get nav_agents_hint => 'View agents list';

  @override
  String get nav_providers_hint => 'View providers list';

  @override
  String get nav_selected => 'selected';

  @override
  String nav_hint_navigate(Object page) {
    return 'Double tap to navigate to $page page';
  }

  @override
  String get drawer_settings => 'Settings';

  @override
  String get drawer_settings_hint => 'Open settings (coming soon)';

  @override
  String get agent_list_title => 'Agents';

  @override
  String get agent_list_no_agents => 'No agents found';

  @override
  String get agent_list_create_first =>
      'Create your first agent to get started';

  @override
  String get agent_list_error_loading => 'Error loading agents';

  @override
  String get agent_list_retry => 'Retry';

  @override
  String get agent_list_create_button => 'Create Agent';

  @override
  String agent_card_label(Object model, Object name, Object type) {
    return 'Agent card: $name, type: $type, model: $model';
  }

  @override
  String get agent_card_hint_view_details => 'Double tap to view details';

  @override
  String get agent_card_hint_with_actions =>
      'Double tap to view details, has edit button, has delete button';

  @override
  String get agent_card_hint_with_edit =>
      'Double tap to view details, has edit button';

  @override
  String get agent_card_hint_with_delete =>
      'Double tap to view details, has delete button';

  @override
  String get agent_card_not_specified => 'Not specified';

  @override
  String agent_card_ago_days(Object count) {
    return '${count}d ago';
  }

  @override
  String agent_card_ago_hours(Object count) {
    return '${count}h ago';
  }

  @override
  String agent_card_ago_minutes(Object count) {
    return '${count}m ago';
  }

  @override
  String get agent_card_ago_just_now => 'Just now';

  @override
  String get agent_card_model_unknown => 'Unknown';

  @override
  String get agent_action_edit => 'Edit';

  @override
  String get agent_action_edit_hint => 'Double tap to edit';

  @override
  String get agent_action_delete => 'Delete';

  @override
  String get agent_action_delete_hint => 'Double tap to delete';

  @override
  String get agent_action_destructive => '(destructive action)';

  @override
  String agent_edit_coming_soon(Object name) {
    return 'Edit $name - Coming soon!';
  }

  @override
  String agent_delete_success(Object name) {
    return '$name deleted successfully';
  }

  @override
  String agent_delete_failed(Object error, Object name) {
    return 'Failed to delete $name: $error';
  }

  @override
  String agent_delete_confirm_title(Object name) {
    return 'Delete $name?';
  }

  @override
  String get agent_delete_confirm_message =>
      'This action cannot be undone. Are you sure you want to delete this agent?';

  @override
  String get agent_delete_button => 'Delete';

  @override
  String get agent_cancel_button => 'Cancel';

  @override
  String get agent_create_title => 'Create Agent';

  @override
  String get agent_create_back_tooltip => 'Back to Agents';

  @override
  String agent_create_step_indicator(Object current, Object total) {
    return 'Step $current/$total';
  }

  @override
  String get agent_create_button_next => 'Next';

  @override
  String get agent_create_button_back => 'Back';

  @override
  String get agent_create_button_create => 'Create Agent';

  @override
  String get agent_create_creating => 'Creating...';

  @override
  String agent_create_success(Object name) {
    return '$name created successfully';
  }

  @override
  String agent_create_failed(Object error) {
    return 'Failed to create agent: $error';
  }

  @override
  String get agent_create_step_provider_title => 'Provider Selection';

  @override
  String get agent_create_step_model_title => 'Model Selection';

  @override
  String get agent_create_step_provider_desc =>
      'Select LLM and Embedding providers for your agent';

  @override
  String get agent_create_step_model_desc =>
      'Select LLM and Embedding models for your agent';

  @override
  String get agent_create_step_basic_title => 'Basic Information';

  @override
  String get agent_create_step_basic_desc =>
      'Enter the basic information for your agent';

  @override
  String get agent_create_step_review_title => 'Review and Confirm';

  @override
  String get agent_create_step_review_desc =>
      'Review your agent configuration before creating';

  @override
  String get agent_create_byok_mode => 'BYOK Mode';

  @override
  String get agent_create_byok_desc =>
      'Enable Bring Your Own Key (BYOK) mode to use custom providers';

  @override
  String get agent_create_byok_enabled => 'BYOK Enabled';

  @override
  String get agent_create_byok_disabled => 'BYOK Disabled';

  @override
  String get agent_create_llm_provider => 'LLM Provider';

  @override
  String get agent_create_embedding_provider => 'Embedding Provider';

  @override
  String get agent_create_llm_model => 'LLM Model';

  @override
  String get agent_create_embedding_model => 'Embedding Model';

  @override
  String get agent_create_select_provider => 'Select a provider';

  @override
  String get agent_create_select_model => 'Select a model';

  @override
  String get agent_create_no_models => 'No models available';

  @override
  String get agent_create_select_provider_first => 'Select a provider first';

  @override
  String get agent_create_please_select_model => 'Please select a model';

  @override
  String get agent_create_field_name => 'Agent Name';

  @override
  String get agent_create_field_name_hint => 'Enter a name for your agent';

  @override
  String get agent_create_field_description => 'Description';

  @override
  String get agent_create_field_description_hint =>
      'Enter a description for your agent';

  @override
  String get agent_create_field_system_prompt => 'System Prompt';

  @override
  String get agent_create_field_system_prompt_hint =>
      'Enter the system prompt for your agent';

  @override
  String get agent_create_validation_name => 'Please enter an agent name';

  @override
  String get agent_create_validation_system_prompt =>
      'Please enter a system prompt';

  @override
  String get agent_create_validation_llm_provider =>
      'Please select an LLM provider and model';

  @override
  String get agent_create_validation_llm_model => 'Please select an LLM model';

  @override
  String get agent_create_validation_embedding_provider =>
      'Please select an Embedding provider and model';

  @override
  String get agent_create_validation_embedding_model =>
      'Please select an Embedding model';

  @override
  String get agent_create_review_name => 'Name';

  @override
  String get agent_create_review_description => 'Description';

  @override
  String get agent_create_review_system_prompt => 'System Prompt';

  @override
  String get agent_create_review_llm_model => 'LLM Model';

  @override
  String get agent_create_review_embedding_model => 'Embedding Model';

  @override
  String get agent_create_review_not_selected => 'Not selected';

  @override
  String agent_create_error_loading(Object error) {
    return 'Failed to load data: $error';
  }

  @override
  String agent_create_error_llm_models(Object error) {
    return 'Failed to load LLM models: $error';
  }

  @override
  String agent_create_error_embedding_models(Object error) {
    return 'Failed to load embedding models: $error';
  }

  @override
  String get agent_detail_title => 'Agent Details';

  @override
  String get agent_detail_back_tooltip => 'Back to Agents';

  @override
  String get agent_detail_tooltip_edit => 'Edit';

  @override
  String get agent_detail_tooltip_delete => 'Delete';

  @override
  String get agent_detail_edit_coming_soon => 'Edit feature - Coming soon!';

  @override
  String get agent_detail_start_chat => 'Start Chat';

  @override
  String get agent_detail_failed_to_load => 'Failed to load agent';

  @override
  String get agent_detail_deleted_success => 'Agent deleted successfully';

  @override
  String agent_detail_delete_failed(Object error) {
    return 'Failed to delete agent: $error';
  }

  @override
  String get agent_detail_section_basic => 'Basic Information';

  @override
  String get agent_detail_section_model_base =>
      'Model Configuration (Base Mode)';

  @override
  String get agent_detail_section_llm_byok => 'LLM Configuration (BYOK Mode)';

  @override
  String get agent_detail_section_embedding => 'Embedding Configuration';

  @override
  String get agent_detail_section_model_settings => 'Model Settings';

  @override
  String get agent_detail_section_tools => 'Tools';

  @override
  String get agent_detail_section_tags => 'Tags';

  @override
  String get agent_detail_section_metadata => 'Metadata';

  @override
  String get agent_detail_section_timestamps => 'Timestamps';

  @override
  String get agent_detail_section_system_prompt => 'System Prompt';

  @override
  String get agent_detail_section_config => 'Configuration';

  @override
  String get agent_detail_field_id => 'Agent ID';

  @override
  String get agent_detail_field_name => 'Name';

  @override
  String get agent_detail_field_description => 'Description';

  @override
  String get agent_detail_field_agent_type => 'Agent Type';

  @override
  String get agent_detail_field_model_handle => 'Model Handle';

  @override
  String get agent_detail_field_model => 'Model';

  @override
  String get agent_detail_field_embedding_handle => 'Embedding Model';

  @override
  String get agent_detail_field_provider => 'Provider';

  @override
  String get agent_detail_field_context_window => 'Context Window';

  @override
  String get agent_detail_field_embedding_model => 'Model';

  @override
  String get agent_detail_field_embedding_provider => 'Provider';

  @override
  String get agent_detail_field_embedding_dim => 'Dimension';

  @override
  String get agent_detail_field_created => 'Created';

  @override
  String get agent_detail_field_modified => 'Last Modified';

  @override
  String agent_detail_context_window_tokens(Object count) {
    return '$count tokens';
  }

  @override
  String get agent_detail_n_a => 'N/A';

  @override
  String get agent_detail_no_tools => 'No tools';

  @override
  String get agent_detail_no_tags => 'No tags';

  @override
  String get agent_detail_no_metadata => 'No metadata';

  @override
  String get provider_list_title => 'Providers';

  @override
  String get provider_list_no_providers => 'No BYOK providers found';

  @override
  String get provider_list_create_first =>
      'Create a custom provider to use your own API keys';

  @override
  String get provider_list_error_loading => 'Error loading providers';

  @override
  String get provider_list_retry => 'Retry';

  @override
  String get provider_list_create_button => 'Create Provider';

  @override
  String provider_list_details_coming_soon(Object name) {
    return 'Provider details for $name - Coming soon!';
  }

  @override
  String provider_card_label(Object category, Object name, Object type) {
    return 'Provider card: $name, type: $type, category: $category';
  }

  @override
  String get provider_card_hint_view_details => 'Double tap to view details';

  @override
  String get provider_card_hint_with_delete =>
      'Double tap to view details, has delete button';

  @override
  String get provider_card_delete_provider => 'Delete provider';

  @override
  String get provider_card_delete_hint => 'Double tap to delete provider';

  @override
  String get provider_card_destructive => '(destructive action)';

  @override
  String provider_card_type_label(Object type) {
    return '$type provider type';
  }

  @override
  String provider_card_ago_days(Object count) {
    return '${count}d ago';
  }

  @override
  String provider_card_ago_hours(Object count) {
    return '${count}h ago';
  }

  @override
  String provider_card_ago_minutes(Object count) {
    return '${count}m ago';
  }

  @override
  String get provider_card_ago_just_now => 'Just now';

  @override
  String get provider_type_openai => 'OpenAI';

  @override
  String get provider_type_anthropic => 'Anthropic';

  @override
  String get provider_type_ollama => 'Ollama';

  @override
  String get provider_type_google_ai => 'Google AI';

  @override
  String get provider_type_google_vertex => 'Google Vertex';

  @override
  String get provider_type_letta => 'Letta';

  @override
  String get provider_create_title => 'Create Provider';

  @override
  String get provider_create_creating => 'Creating provider...';

  @override
  String provider_create_success(Object name) {
    return 'Provider \"$name\" created successfully';
  }

  @override
  String provider_create_failed(Object error) {
    return 'Failed to create provider: $error';
  }

  @override
  String get provider_create_step_type => 'Type';

  @override
  String get provider_create_step_config => 'Config';

  @override
  String get provider_create_step_type_title => 'Provider Type';

  @override
  String get provider_create_step_config_title => 'Configuration';

  @override
  String get provider_create_button_back => 'Back';

  @override
  String get provider_create_button_next => 'Next';

  @override
  String get provider_create_button_create => 'Create Provider';

  @override
  String get provider_create_openai_name => 'OpenAI';

  @override
  String get provider_create_openai_desc => 'GPT-4, GPT-3.5 and more';

  @override
  String get provider_create_anthropic_name => 'Anthropic';

  @override
  String get provider_create_anthropic_desc =>
      'Claude 3.5 Sonnet, Opus, and more';

  @override
  String get provider_create_ollama_name => 'Ollama';

  @override
  String get provider_create_ollama_desc => 'Local open-source models';

  @override
  String get provider_create_google_ai_name => 'Google AI';

  @override
  String get provider_create_google_ai_desc => 'Gemini Pro, Gemini Flash';

  @override
  String get provider_create_google_vertex_name => 'Google Vertex AI';

  @override
  String get provider_create_google_vertex_desc => 'Enterprise AI models';

  @override
  String provider_create_select_type_label(
    Object description,
    Object displayName,
  ) {
    return 'Provider type: $displayName, $description';
  }

  @override
  String provider_create_select_hint(Object displayName) {
    return 'Double tap to select $displayName provider';
  }

  @override
  String get provider_create_field_provider_type => 'Provider Type';

  @override
  String get provider_create_field_provider_type_hint =>
      'Select a provider type';

  @override
  String get provider_create_field_provider_type_semantic =>
      'Provider type dropdown';

  @override
  String get provider_create_field_provider_type_hint_semantic =>
      'Double tap to open provider type dropdown';

  @override
  String get provider_create_validation_provider_type =>
      'Please select a provider type';

  @override
  String get provider_create_field_name => 'Provider Name';

  @override
  String get provider_create_field_name_hint => 'e.g., my-openai';

  @override
  String get provider_create_field_name_semantic => 'Provider name input field';

  @override
  String get provider_create_field_name_hint_semantic =>
      'Enter a unique name for this provider, e.g., my-openai';

  @override
  String get provider_create_validation_name => 'Please enter a provider name';

  @override
  String get provider_create_field_api_key => 'API Key';

  @override
  String get provider_create_field_api_key_hint_openai => 'sk-...';

  @override
  String get provider_create_field_api_key_hint_anthropic => 'sk-ant-...';

  @override
  String get provider_create_field_api_key_hint_google_ai => 'AIza...';

  @override
  String get provider_create_field_api_key_hint_default => 'Enter your API key';

  @override
  String get provider_create_field_api_key_semantic => 'API key input field';

  @override
  String provider_create_field_api_key_hint_semantic(Object provider) {
    return 'Enter your $provider API key';
  }

  @override
  String get provider_create_validation_api_key => 'Please enter an API key';

  @override
  String get provider_create_field_base_url => 'Base URL';

  @override
  String get provider_create_field_base_url_hint =>
      'e.g., https://api.openai.com/v1';

  @override
  String get provider_create_field_base_url_semantic => 'Base URL input field';

  @override
  String get provider_create_field_base_url_hint_semantic =>
      'Enter the API endpoint URL, e.g., https://api.openai.com/v1';

  @override
  String get provider_create_validation_base_url => 'Please enter a base URL';

  @override
  String get provider_create_field_project => 'Google Cloud Project';

  @override
  String get provider_create_field_project_hint => 'e.g., my-project';

  @override
  String get provider_create_field_project_semantic =>
      'Google Cloud project ID input field';

  @override
  String get provider_create_field_project_hint_semantic =>
      'Enter your Google Cloud project ID, e.g., my-project';

  @override
  String get provider_create_validation_project => 'Please enter a project ID';

  @override
  String get provider_create_field_location => 'Location';

  @override
  String get provider_create_field_location_hint => 'e.g., us-central1';

  @override
  String get provider_create_field_location_semantic =>
      'Google Cloud location input field';

  @override
  String get provider_create_field_location_hint_semantic =>
      'Enter the Google Cloud region, e.g., us-central1';

  @override
  String get provider_create_validation_location => 'Please enter a location';

  @override
  String get provider_create_select_first =>
      'Please select a provider type first';

  @override
  String provider_create_selected(Object displayName) {
    return 'Selected: $displayName';
  }

  @override
  String provider_create_selected_semantic(Object displayName) {
    return 'Selected provider: $displayName';
  }

  @override
  String provider_delete_confirm_title(Object name) {
    return 'Delete $name?';
  }

  @override
  String get provider_delete_confirm_message =>
      'This action cannot be undone. Are you sure you want to delete this provider?';

  @override
  String provider_delete_success(Object name) {
    return '$name deleted successfully';
  }

  @override
  String provider_delete_failed(Object error, Object name) {
    return 'Failed to delete $name: $error';
  }

  @override
  String get provider_delete_button => 'Delete';

  @override
  String get provider_cancel_button => 'Cancel';

  @override
  String get provider_detail_title => 'Provider Details';

  @override
  String get provider_detail_back_tooltip => 'Back to Providers';

  @override
  String get provider_detail_failed_to_load => 'Failed to load provider';

  @override
  String get provider_detail_tooltip_edit => 'Edit';

  @override
  String get provider_detail_tooltip_delete => 'Delete';

  @override
  String get provider_detail_edit_coming_soon => 'Edit feature - Coming soon!';

  @override
  String get provider_detail_section_basic => 'Basic Information';

  @override
  String get provider_detail_section_config => 'Configuration';

  @override
  String get provider_detail_section_credentials => 'Credentials';

  @override
  String get provider_detail_field_id => 'Provider ID';

  @override
  String get provider_detail_field_name => 'Name';

  @override
  String get provider_detail_field_type => 'Type';

  @override
  String get provider_detail_field_category => 'Category';

  @override
  String get provider_detail_field_base_url => 'Base URL';

  @override
  String get provider_detail_field_region => 'Region';

  @override
  String get provider_detail_field_api_key => 'API Key';

  @override
  String get provider_detail_field_access_key => 'Access Key';

  @override
  String get provider_detail_field_organization_id => 'Organization ID';

  @override
  String get provider_detail_field_updated_at => 'Last Updated';

  @override
  String get provider_detail_category_base => 'Base (Default)';

  @override
  String get provider_detail_category_byok => 'BYOK (Custom)';

  @override
  String get common_button_cancel => 'Cancel';

  @override
  String get common_button_delete => 'Delete';

  @override
  String get common_button_retry => 'Retry';

  @override
  String get common_button_refresh => 'Refresh';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_error => 'Error';

  @override
  String get common_not_specified => 'Not specified';

  @override
  String get chat_empty_title => 'Start a conversation';

  @override
  String get chat_empty_subtitle =>
      'Send a message to begin chatting with your agent';

  @override
  String get chat_input_hint => 'Type your message...';

  @override
  String get chat_send_tooltip => 'Send message';

  @override
  String get chat_error_no_agent => 'Please select an agent first';

  @override
  String get chat_input_disabled_no_agent =>
      'Select an agent to start chatting';

  @override
  String agent_selector_label(Object name) {
    return 'Current agent: $name';
  }

  @override
  String get agent_selector_hint => 'Double tap to select an agent';

  @override
  String agent_selector_item_label(Object name) {
    return 'Agent: $name';
  }

  @override
  String get agent_selector_select_hint => 'Double tap to select this agent';
}
