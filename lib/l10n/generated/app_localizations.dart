import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'Klui - Letta Agent Management'**
  String get app_title;

  /// No description provided for @page_not_found.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get page_not_found;

  /// No description provided for @nav_agents.
  ///
  /// In en, this message translates to:
  /// **'Agents'**
  String get nav_agents;

  /// No description provided for @nav_providers.
  ///
  /// In en, this message translates to:
  /// **'Providers'**
  String get nav_providers;

  /// No description provided for @nav_chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get nav_chat;

  /// No description provided for @nav_agents_tab.
  ///
  /// In en, this message translates to:
  /// **'Agents tab'**
  String get nav_agents_tab;

  /// No description provided for @nav_providers_tab.
  ///
  /// In en, this message translates to:
  /// **'Providers tab'**
  String get nav_providers_tab;

  /// No description provided for @nav_agents_hint.
  ///
  /// In en, this message translates to:
  /// **'View agents list'**
  String get nav_agents_hint;

  /// No description provided for @nav_providers_hint.
  ///
  /// In en, this message translates to:
  /// **'View providers list'**
  String get nav_providers_hint;

  /// No description provided for @nav_selected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get nav_selected;

  /// No description provided for @nav_hint_navigate.
  ///
  /// In en, this message translates to:
  /// **'Double tap to navigate to {page} page'**
  String nav_hint_navigate(Object page);

  /// No description provided for @drawer_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawer_settings;

  /// No description provided for @drawer_settings_hint.
  ///
  /// In en, this message translates to:
  /// **'Open settings (coming soon)'**
  String get drawer_settings_hint;

  /// No description provided for @agent_list_title.
  ///
  /// In en, this message translates to:
  /// **'Agents'**
  String get agent_list_title;

  /// No description provided for @agent_list_no_agents.
  ///
  /// In en, this message translates to:
  /// **'No agents found'**
  String get agent_list_no_agents;

  /// No description provided for @agent_list_create_first.
  ///
  /// In en, this message translates to:
  /// **'Create your first agent to get started'**
  String get agent_list_create_first;

  /// No description provided for @agent_list_error_loading.
  ///
  /// In en, this message translates to:
  /// **'Error loading agents'**
  String get agent_list_error_loading;

  /// No description provided for @agent_list_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get agent_list_retry;

  /// No description provided for @agent_list_create_button.
  ///
  /// In en, this message translates to:
  /// **'Create Agent'**
  String get agent_list_create_button;

  /// No description provided for @agent_card_label.
  ///
  /// In en, this message translates to:
  /// **'Agent card: {name}, type: {type}, model: {model}'**
  String agent_card_label(Object model, Object name, Object type);

  /// No description provided for @agent_card_hint_view_details.
  ///
  /// In en, this message translates to:
  /// **'Double tap to view details'**
  String get agent_card_hint_view_details;

  /// No description provided for @agent_card_hint_with_actions.
  ///
  /// In en, this message translates to:
  /// **'Double tap to view details, has edit button, has delete button'**
  String get agent_card_hint_with_actions;

  /// No description provided for @agent_card_hint_with_edit.
  ///
  /// In en, this message translates to:
  /// **'Double tap to view details, has edit button'**
  String get agent_card_hint_with_edit;

  /// No description provided for @agent_card_hint_with_delete.
  ///
  /// In en, this message translates to:
  /// **'Double tap to view details, has delete button'**
  String get agent_card_hint_with_delete;

  /// No description provided for @agent_card_not_specified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get agent_card_not_specified;

  /// No description provided for @agent_card_ago_days.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String agent_card_ago_days(Object count);

  /// No description provided for @agent_card_ago_hours.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String agent_card_ago_hours(Object count);

  /// No description provided for @agent_card_ago_minutes.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String agent_card_ago_minutes(Object count);

  /// No description provided for @agent_card_ago_just_now.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get agent_card_ago_just_now;

  /// No description provided for @agent_card_model_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get agent_card_model_unknown;

  /// No description provided for @agent_action_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get agent_action_edit;

  /// No description provided for @agent_action_edit_hint.
  ///
  /// In en, this message translates to:
  /// **'Double tap to edit'**
  String get agent_action_edit_hint;

  /// No description provided for @agent_action_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get agent_action_delete;

  /// No description provided for @agent_action_delete_hint.
  ///
  /// In en, this message translates to:
  /// **'Double tap to delete'**
  String get agent_action_delete_hint;

  /// No description provided for @agent_action_destructive.
  ///
  /// In en, this message translates to:
  /// **'(destructive action)'**
  String get agent_action_destructive;

  /// No description provided for @agent_edit_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Edit {name} - Coming soon!'**
  String agent_edit_coming_soon(Object name);

  /// No description provided for @agent_delete_success.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted successfully'**
  String agent_delete_success(Object name);

  /// No description provided for @agent_delete_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete {name}: {error}'**
  String agent_delete_failed(Object error, Object name);

  /// No description provided for @agent_delete_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String agent_delete_confirm_title(Object name);

  /// No description provided for @agent_delete_confirm_message.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Are you sure you want to delete this agent?'**
  String get agent_delete_confirm_message;

  /// No description provided for @agent_delete_button.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get agent_delete_button;

  /// No description provided for @agent_cancel_button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get agent_cancel_button;

  /// No description provided for @agent_create_title.
  ///
  /// In en, this message translates to:
  /// **'Create Agent'**
  String get agent_create_title;

  /// No description provided for @agent_create_back_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Back to Agents'**
  String get agent_create_back_tooltip;

  /// No description provided for @agent_create_step_indicator.
  ///
  /// In en, this message translates to:
  /// **'Step {current}/{total}'**
  String agent_create_step_indicator(Object current, Object total);

  /// No description provided for @agent_create_button_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get agent_create_button_next;

  /// No description provided for @agent_create_button_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get agent_create_button_back;

  /// No description provided for @agent_create_button_create.
  ///
  /// In en, this message translates to:
  /// **'Create Agent'**
  String get agent_create_button_create;

  /// No description provided for @agent_create_creating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get agent_create_creating;

  /// No description provided for @agent_create_success.
  ///
  /// In en, this message translates to:
  /// **'{name} created successfully'**
  String agent_create_success(Object name);

  /// No description provided for @agent_create_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create agent: {error}'**
  String agent_create_failed(Object error);

  /// No description provided for @agent_create_step_provider_title.
  ///
  /// In en, this message translates to:
  /// **'Provider Selection'**
  String get agent_create_step_provider_title;

  /// No description provided for @agent_create_step_model_title.
  ///
  /// In en, this message translates to:
  /// **'Model Selection'**
  String get agent_create_step_model_title;

  /// No description provided for @agent_create_step_provider_desc.
  ///
  /// In en, this message translates to:
  /// **'Select LLM and Embedding providers for your agent'**
  String get agent_create_step_provider_desc;

  /// No description provided for @agent_create_step_model_desc.
  ///
  /// In en, this message translates to:
  /// **'Select LLM and Embedding models for your agent'**
  String get agent_create_step_model_desc;

  /// No description provided for @agent_create_step_basic_title.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get agent_create_step_basic_title;

  /// No description provided for @agent_create_step_basic_desc.
  ///
  /// In en, this message translates to:
  /// **'Enter the basic information for your agent'**
  String get agent_create_step_basic_desc;

  /// No description provided for @agent_create_step_review_title.
  ///
  /// In en, this message translates to:
  /// **'Review and Confirm'**
  String get agent_create_step_review_title;

  /// No description provided for @agent_create_step_review_desc.
  ///
  /// In en, this message translates to:
  /// **'Review your agent configuration before creating'**
  String get agent_create_step_review_desc;

  /// No description provided for @agent_create_byok_mode.
  ///
  /// In en, this message translates to:
  /// **'BYOK Mode'**
  String get agent_create_byok_mode;

  /// No description provided for @agent_create_byok_desc.
  ///
  /// In en, this message translates to:
  /// **'Enable Bring Your Own Key (BYOK) mode to use custom providers'**
  String get agent_create_byok_desc;

  /// No description provided for @agent_create_byok_enabled.
  ///
  /// In en, this message translates to:
  /// **'BYOK Enabled'**
  String get agent_create_byok_enabled;

  /// No description provided for @agent_create_byok_disabled.
  ///
  /// In en, this message translates to:
  /// **'BYOK Disabled'**
  String get agent_create_byok_disabled;

  /// No description provided for @agent_create_llm_provider.
  ///
  /// In en, this message translates to:
  /// **'LLM Provider'**
  String get agent_create_llm_provider;

  /// No description provided for @agent_create_embedding_provider.
  ///
  /// In en, this message translates to:
  /// **'Embedding Provider'**
  String get agent_create_embedding_provider;

  /// No description provided for @agent_create_llm_model.
  ///
  /// In en, this message translates to:
  /// **'LLM Model'**
  String get agent_create_llm_model;

  /// No description provided for @agent_create_embedding_model.
  ///
  /// In en, this message translates to:
  /// **'Embedding Model'**
  String get agent_create_embedding_model;

  /// No description provided for @agent_create_select_provider.
  ///
  /// In en, this message translates to:
  /// **'Select a provider'**
  String get agent_create_select_provider;

  /// No description provided for @agent_create_select_model.
  ///
  /// In en, this message translates to:
  /// **'Select a model'**
  String get agent_create_select_model;

  /// No description provided for @agent_create_no_models.
  ///
  /// In en, this message translates to:
  /// **'No models available'**
  String get agent_create_no_models;

  /// No description provided for @agent_create_select_provider_first.
  ///
  /// In en, this message translates to:
  /// **'Select a provider first'**
  String get agent_create_select_provider_first;

  /// No description provided for @agent_create_please_select_model.
  ///
  /// In en, this message translates to:
  /// **'Please select a model'**
  String get agent_create_please_select_model;

  /// No description provided for @agent_create_field_name.
  ///
  /// In en, this message translates to:
  /// **'Agent Name'**
  String get agent_create_field_name;

  /// No description provided for @agent_create_field_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for your agent'**
  String get agent_create_field_name_hint;

  /// No description provided for @agent_create_field_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get agent_create_field_description;

  /// No description provided for @agent_create_field_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter a description for your agent'**
  String get agent_create_field_description_hint;

  /// No description provided for @agent_create_field_system_prompt.
  ///
  /// In en, this message translates to:
  /// **'System Prompt'**
  String get agent_create_field_system_prompt;

  /// No description provided for @agent_create_field_system_prompt_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter the system prompt for your agent'**
  String get agent_create_field_system_prompt_hint;

  /// No description provided for @agent_create_validation_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter an agent name'**
  String get agent_create_validation_name;

  /// No description provided for @agent_create_validation_system_prompt.
  ///
  /// In en, this message translates to:
  /// **'Please enter a system prompt'**
  String get agent_create_validation_system_prompt;

  /// No description provided for @agent_create_validation_llm_provider.
  ///
  /// In en, this message translates to:
  /// **'Please select an LLM provider and model'**
  String get agent_create_validation_llm_provider;

  /// No description provided for @agent_create_validation_llm_model.
  ///
  /// In en, this message translates to:
  /// **'Please select an LLM model'**
  String get agent_create_validation_llm_model;

  /// No description provided for @agent_create_validation_embedding_provider.
  ///
  /// In en, this message translates to:
  /// **'Please select an Embedding provider and model'**
  String get agent_create_validation_embedding_provider;

  /// No description provided for @agent_create_validation_embedding_model.
  ///
  /// In en, this message translates to:
  /// **'Please select an Embedding model'**
  String get agent_create_validation_embedding_model;

  /// No description provided for @agent_create_review_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get agent_create_review_name;

  /// No description provided for @agent_create_review_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get agent_create_review_description;

  /// No description provided for @agent_create_review_system_prompt.
  ///
  /// In en, this message translates to:
  /// **'System Prompt'**
  String get agent_create_review_system_prompt;

  /// No description provided for @agent_create_review_llm_model.
  ///
  /// In en, this message translates to:
  /// **'LLM Model'**
  String get agent_create_review_llm_model;

  /// No description provided for @agent_create_review_embedding_model.
  ///
  /// In en, this message translates to:
  /// **'Embedding Model'**
  String get agent_create_review_embedding_model;

  /// No description provided for @agent_create_review_not_selected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get agent_create_review_not_selected;

  /// No description provided for @agent_create_error_loading.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data: {error}'**
  String agent_create_error_loading(Object error);

  /// No description provided for @agent_create_error_llm_models.
  ///
  /// In en, this message translates to:
  /// **'Failed to load LLM models: {error}'**
  String agent_create_error_llm_models(Object error);

  /// No description provided for @agent_create_error_embedding_models.
  ///
  /// In en, this message translates to:
  /// **'Failed to load embedding models: {error}'**
  String agent_create_error_embedding_models(Object error);

  /// No description provided for @agent_detail_title.
  ///
  /// In en, this message translates to:
  /// **'Agent Details'**
  String get agent_detail_title;

  /// No description provided for @agent_detail_back_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Back to Agents'**
  String get agent_detail_back_tooltip;

  /// No description provided for @agent_detail_tooltip_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get agent_detail_tooltip_edit;

  /// No description provided for @agent_detail_tooltip_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get agent_detail_tooltip_delete;

  /// No description provided for @agent_detail_edit_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Edit feature - Coming soon!'**
  String get agent_detail_edit_coming_soon;

  /// No description provided for @agent_detail_start_chat.
  ///
  /// In en, this message translates to:
  /// **'Start Chat'**
  String get agent_detail_start_chat;

  /// No description provided for @agent_detail_failed_to_load.
  ///
  /// In en, this message translates to:
  /// **'Failed to load agent'**
  String get agent_detail_failed_to_load;

  /// No description provided for @agent_detail_deleted_success.
  ///
  /// In en, this message translates to:
  /// **'Agent deleted successfully'**
  String get agent_detail_deleted_success;

  /// No description provided for @agent_detail_delete_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete agent: {error}'**
  String agent_detail_delete_failed(Object error);

  /// No description provided for @agent_detail_section_basic.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get agent_detail_section_basic;

  /// No description provided for @agent_detail_section_model_base.
  ///
  /// In en, this message translates to:
  /// **'Model Configuration (Base Mode)'**
  String get agent_detail_section_model_base;

  /// No description provided for @agent_detail_section_llm_byok.
  ///
  /// In en, this message translates to:
  /// **'LLM Configuration (BYOK Mode)'**
  String get agent_detail_section_llm_byok;

  /// No description provided for @agent_detail_section_embedding.
  ///
  /// In en, this message translates to:
  /// **'Embedding Configuration'**
  String get agent_detail_section_embedding;

  /// No description provided for @agent_detail_section_model_settings.
  ///
  /// In en, this message translates to:
  /// **'Model Settings'**
  String get agent_detail_section_model_settings;

  /// No description provided for @agent_detail_section_tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get agent_detail_section_tools;

  /// No description provided for @agent_detail_section_tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get agent_detail_section_tags;

  /// No description provided for @agent_detail_section_metadata.
  ///
  /// In en, this message translates to:
  /// **'Metadata'**
  String get agent_detail_section_metadata;

  /// No description provided for @agent_detail_section_timestamps.
  ///
  /// In en, this message translates to:
  /// **'Timestamps'**
  String get agent_detail_section_timestamps;

  /// No description provided for @agent_detail_section_system_prompt.
  ///
  /// In en, this message translates to:
  /// **'System Prompt'**
  String get agent_detail_section_system_prompt;

  /// No description provided for @agent_detail_section_config.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get agent_detail_section_config;

  /// No description provided for @agent_detail_field_id.
  ///
  /// In en, this message translates to:
  /// **'Agent ID'**
  String get agent_detail_field_id;

  /// No description provided for @agent_detail_field_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get agent_detail_field_name;

  /// No description provided for @agent_detail_field_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get agent_detail_field_description;

  /// No description provided for @agent_detail_field_agent_type.
  ///
  /// In en, this message translates to:
  /// **'Agent Type'**
  String get agent_detail_field_agent_type;

  /// No description provided for @agent_detail_field_model_handle.
  ///
  /// In en, this message translates to:
  /// **'Model Handle'**
  String get agent_detail_field_model_handle;

  /// No description provided for @agent_detail_field_model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get agent_detail_field_model;

  /// No description provided for @agent_detail_field_embedding_handle.
  ///
  /// In en, this message translates to:
  /// **'Embedding Model'**
  String get agent_detail_field_embedding_handle;

  /// No description provided for @agent_detail_field_provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get agent_detail_field_provider;

  /// No description provided for @agent_detail_field_context_window.
  ///
  /// In en, this message translates to:
  /// **'Context Window'**
  String get agent_detail_field_context_window;

  /// No description provided for @agent_detail_field_embedding_model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get agent_detail_field_embedding_model;

  /// No description provided for @agent_detail_field_embedding_provider.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get agent_detail_field_embedding_provider;

  /// No description provided for @agent_detail_field_embedding_dim.
  ///
  /// In en, this message translates to:
  /// **'Dimension'**
  String get agent_detail_field_embedding_dim;

  /// No description provided for @agent_detail_field_created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get agent_detail_field_created;

  /// No description provided for @agent_detail_field_modified.
  ///
  /// In en, this message translates to:
  /// **'Last Modified'**
  String get agent_detail_field_modified;

  /// No description provided for @agent_detail_context_window_tokens.
  ///
  /// In en, this message translates to:
  /// **'{count} tokens'**
  String agent_detail_context_window_tokens(Object count);

  /// No description provided for @agent_detail_n_a.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get agent_detail_n_a;

  /// No description provided for @agent_detail_no_tools.
  ///
  /// In en, this message translates to:
  /// **'No tools'**
  String get agent_detail_no_tools;

  /// No description provided for @agent_detail_no_tags.
  ///
  /// In en, this message translates to:
  /// **'No tags'**
  String get agent_detail_no_tags;

  /// No description provided for @agent_detail_no_metadata.
  ///
  /// In en, this message translates to:
  /// **'No metadata'**
  String get agent_detail_no_metadata;

  /// No description provided for @provider_list_title.
  ///
  /// In en, this message translates to:
  /// **'Providers'**
  String get provider_list_title;

  /// No description provided for @provider_list_no_providers.
  ///
  /// In en, this message translates to:
  /// **'No BYOK providers found'**
  String get provider_list_no_providers;

  /// No description provided for @provider_list_create_first.
  ///
  /// In en, this message translates to:
  /// **'Create a custom provider to use your own API keys'**
  String get provider_list_create_first;

  /// No description provided for @provider_list_error_loading.
  ///
  /// In en, this message translates to:
  /// **'Error loading providers'**
  String get provider_list_error_loading;

  /// No description provided for @provider_list_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get provider_list_retry;

  /// No description provided for @provider_list_create_button.
  ///
  /// In en, this message translates to:
  /// **'Create Provider'**
  String get provider_list_create_button;

  /// No description provided for @provider_list_details_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Provider details for {name} - Coming soon!'**
  String provider_list_details_coming_soon(Object name);

  /// No description provided for @provider_card_label.
  ///
  /// In en, this message translates to:
  /// **'Provider card: {name}, type: {type}, category: {category}'**
  String provider_card_label(Object category, Object name, Object type);

  /// No description provided for @provider_card_hint_view_details.
  ///
  /// In en, this message translates to:
  /// **'Double tap to view details'**
  String get provider_card_hint_view_details;

  /// No description provided for @provider_card_hint_with_delete.
  ///
  /// In en, this message translates to:
  /// **'Double tap to view details, has delete button'**
  String get provider_card_hint_with_delete;

  /// No description provided for @provider_card_delete_provider.
  ///
  /// In en, this message translates to:
  /// **'Delete provider'**
  String get provider_card_delete_provider;

  /// No description provided for @provider_card_delete_hint.
  ///
  /// In en, this message translates to:
  /// **'Double tap to delete provider'**
  String get provider_card_delete_hint;

  /// No description provided for @provider_card_destructive.
  ///
  /// In en, this message translates to:
  /// **'(destructive action)'**
  String get provider_card_destructive;

  /// No description provided for @provider_card_type_label.
  ///
  /// In en, this message translates to:
  /// **'{type} provider type'**
  String provider_card_type_label(Object type);

  /// No description provided for @provider_card_ago_days.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String provider_card_ago_days(Object count);

  /// No description provided for @provider_card_ago_hours.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String provider_card_ago_hours(Object count);

  /// No description provided for @provider_card_ago_minutes.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String provider_card_ago_minutes(Object count);

  /// No description provided for @provider_card_ago_just_now.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get provider_card_ago_just_now;

  /// No description provided for @provider_type_openai.
  ///
  /// In en, this message translates to:
  /// **'OpenAI'**
  String get provider_type_openai;

  /// No description provided for @provider_type_anthropic.
  ///
  /// In en, this message translates to:
  /// **'Anthropic'**
  String get provider_type_anthropic;

  /// No description provided for @provider_type_ollama.
  ///
  /// In en, this message translates to:
  /// **'Ollama'**
  String get provider_type_ollama;

  /// No description provided for @provider_type_google_ai.
  ///
  /// In en, this message translates to:
  /// **'Google AI'**
  String get provider_type_google_ai;

  /// No description provided for @provider_type_google_vertex.
  ///
  /// In en, this message translates to:
  /// **'Google Vertex'**
  String get provider_type_google_vertex;

  /// No description provided for @provider_type_letta.
  ///
  /// In en, this message translates to:
  /// **'Letta'**
  String get provider_type_letta;

  /// No description provided for @provider_create_title.
  ///
  /// In en, this message translates to:
  /// **'Create Provider'**
  String get provider_create_title;

  /// No description provided for @provider_create_creating.
  ///
  /// In en, this message translates to:
  /// **'Creating provider...'**
  String get provider_create_creating;

  /// No description provided for @provider_create_success.
  ///
  /// In en, this message translates to:
  /// **'Provider \"{name}\" created successfully'**
  String provider_create_success(Object name);

  /// No description provided for @provider_create_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create provider: {error}'**
  String provider_create_failed(Object error);

  /// No description provided for @provider_create_step_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get provider_create_step_type;

  /// No description provided for @provider_create_step_config.
  ///
  /// In en, this message translates to:
  /// **'Config'**
  String get provider_create_step_config;

  /// No description provided for @provider_create_step_type_title.
  ///
  /// In en, this message translates to:
  /// **'Provider Type'**
  String get provider_create_step_type_title;

  /// No description provided for @provider_create_step_config_title.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get provider_create_step_config_title;

  /// No description provided for @provider_create_button_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get provider_create_button_back;

  /// No description provided for @provider_create_button_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get provider_create_button_next;

  /// No description provided for @provider_create_button_create.
  ///
  /// In en, this message translates to:
  /// **'Create Provider'**
  String get provider_create_button_create;

  /// No description provided for @provider_create_openai_name.
  ///
  /// In en, this message translates to:
  /// **'OpenAI'**
  String get provider_create_openai_name;

  /// No description provided for @provider_create_openai_desc.
  ///
  /// In en, this message translates to:
  /// **'GPT-4, GPT-3.5 and more'**
  String get provider_create_openai_desc;

  /// No description provided for @provider_create_anthropic_name.
  ///
  /// In en, this message translates to:
  /// **'Anthropic'**
  String get provider_create_anthropic_name;

  /// No description provided for @provider_create_anthropic_desc.
  ///
  /// In en, this message translates to:
  /// **'Claude 3.5 Sonnet, Opus, and more'**
  String get provider_create_anthropic_desc;

  /// No description provided for @provider_create_ollama_name.
  ///
  /// In en, this message translates to:
  /// **'Ollama'**
  String get provider_create_ollama_name;

  /// No description provided for @provider_create_ollama_desc.
  ///
  /// In en, this message translates to:
  /// **'Local open-source models'**
  String get provider_create_ollama_desc;

  /// No description provided for @provider_create_google_ai_name.
  ///
  /// In en, this message translates to:
  /// **'Google AI'**
  String get provider_create_google_ai_name;

  /// No description provided for @provider_create_google_ai_desc.
  ///
  /// In en, this message translates to:
  /// **'Gemini Pro, Gemini Flash'**
  String get provider_create_google_ai_desc;

  /// No description provided for @provider_create_google_vertex_name.
  ///
  /// In en, this message translates to:
  /// **'Google Vertex AI'**
  String get provider_create_google_vertex_name;

  /// No description provided for @provider_create_google_vertex_desc.
  ///
  /// In en, this message translates to:
  /// **'Enterprise AI models'**
  String get provider_create_google_vertex_desc;

  /// No description provided for @provider_create_select_type_label.
  ///
  /// In en, this message translates to:
  /// **'Provider type: {displayName}, {description}'**
  String provider_create_select_type_label(
    Object description,
    Object displayName,
  );

  /// No description provided for @provider_create_select_hint.
  ///
  /// In en, this message translates to:
  /// **'Double tap to select {displayName} provider'**
  String provider_create_select_hint(Object displayName);

  /// No description provided for @provider_create_field_provider_type.
  ///
  /// In en, this message translates to:
  /// **'Provider Type'**
  String get provider_create_field_provider_type;

  /// No description provided for @provider_create_field_provider_type_hint.
  ///
  /// In en, this message translates to:
  /// **'Select a provider type'**
  String get provider_create_field_provider_type_hint;

  /// No description provided for @provider_create_field_provider_type_semantic.
  ///
  /// In en, this message translates to:
  /// **'Provider type dropdown'**
  String get provider_create_field_provider_type_semantic;

  /// No description provided for @provider_create_field_provider_type_hint_semantic.
  ///
  /// In en, this message translates to:
  /// **'Double tap to open provider type dropdown'**
  String get provider_create_field_provider_type_hint_semantic;

  /// No description provided for @provider_create_validation_provider_type.
  ///
  /// In en, this message translates to:
  /// **'Please select a provider type'**
  String get provider_create_validation_provider_type;

  /// No description provided for @provider_create_field_name.
  ///
  /// In en, this message translates to:
  /// **'Provider Name'**
  String get provider_create_field_name;

  /// No description provided for @provider_create_field_name_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., my-openai'**
  String get provider_create_field_name_hint;

  /// No description provided for @provider_create_field_name_semantic.
  ///
  /// In en, this message translates to:
  /// **'Provider name input field'**
  String get provider_create_field_name_semantic;

  /// No description provided for @provider_create_field_name_hint_semantic.
  ///
  /// In en, this message translates to:
  /// **'Enter a unique name for this provider, e.g., my-openai'**
  String get provider_create_field_name_hint_semantic;

  /// No description provided for @provider_create_validation_name.
  ///
  /// In en, this message translates to:
  /// **'Please enter a provider name'**
  String get provider_create_validation_name;

  /// No description provided for @provider_create_field_api_key.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get provider_create_field_api_key;

  /// No description provided for @provider_create_field_api_key_hint_openai.
  ///
  /// In en, this message translates to:
  /// **'sk-...'**
  String get provider_create_field_api_key_hint_openai;

  /// No description provided for @provider_create_field_api_key_hint_anthropic.
  ///
  /// In en, this message translates to:
  /// **'sk-ant-...'**
  String get provider_create_field_api_key_hint_anthropic;

  /// No description provided for @provider_create_field_api_key_hint_google_ai.
  ///
  /// In en, this message translates to:
  /// **'AIza...'**
  String get provider_create_field_api_key_hint_google_ai;

  /// No description provided for @provider_create_field_api_key_hint_default.
  ///
  /// In en, this message translates to:
  /// **'Enter your API key'**
  String get provider_create_field_api_key_hint_default;

  /// No description provided for @provider_create_field_api_key_semantic.
  ///
  /// In en, this message translates to:
  /// **'API key input field'**
  String get provider_create_field_api_key_semantic;

  /// No description provided for @provider_create_field_api_key_hint_semantic.
  ///
  /// In en, this message translates to:
  /// **'Enter your {provider} API key'**
  String provider_create_field_api_key_hint_semantic(Object provider);

  /// No description provided for @provider_create_validation_api_key.
  ///
  /// In en, this message translates to:
  /// **'Please enter an API key'**
  String get provider_create_validation_api_key;

  /// No description provided for @provider_create_field_base_url.
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get provider_create_field_base_url;

  /// No description provided for @provider_create_field_base_url_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., https://api.openai.com/v1'**
  String get provider_create_field_base_url_hint;

  /// No description provided for @provider_create_field_base_url_semantic.
  ///
  /// In en, this message translates to:
  /// **'Base URL input field'**
  String get provider_create_field_base_url_semantic;

  /// No description provided for @provider_create_field_base_url_hint_semantic.
  ///
  /// In en, this message translates to:
  /// **'Enter the API endpoint URL, e.g., https://api.openai.com/v1'**
  String get provider_create_field_base_url_hint_semantic;

  /// No description provided for @provider_create_validation_base_url.
  ///
  /// In en, this message translates to:
  /// **'Please enter a base URL'**
  String get provider_create_validation_base_url;

  /// No description provided for @provider_create_field_project.
  ///
  /// In en, this message translates to:
  /// **'Google Cloud Project'**
  String get provider_create_field_project;

  /// No description provided for @provider_create_field_project_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., my-project'**
  String get provider_create_field_project_hint;

  /// No description provided for @provider_create_field_project_semantic.
  ///
  /// In en, this message translates to:
  /// **'Google Cloud project ID input field'**
  String get provider_create_field_project_semantic;

  /// No description provided for @provider_create_field_project_hint_semantic.
  ///
  /// In en, this message translates to:
  /// **'Enter your Google Cloud project ID, e.g., my-project'**
  String get provider_create_field_project_hint_semantic;

  /// No description provided for @provider_create_validation_project.
  ///
  /// In en, this message translates to:
  /// **'Please enter a project ID'**
  String get provider_create_validation_project;

  /// No description provided for @provider_create_field_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get provider_create_field_location;

  /// No description provided for @provider_create_field_location_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., us-central1'**
  String get provider_create_field_location_hint;

  /// No description provided for @provider_create_field_location_semantic.
  ///
  /// In en, this message translates to:
  /// **'Google Cloud location input field'**
  String get provider_create_field_location_semantic;

  /// No description provided for @provider_create_field_location_hint_semantic.
  ///
  /// In en, this message translates to:
  /// **'Enter the Google Cloud region, e.g., us-central1'**
  String get provider_create_field_location_hint_semantic;

  /// No description provided for @provider_create_validation_location.
  ///
  /// In en, this message translates to:
  /// **'Please enter a location'**
  String get provider_create_validation_location;

  /// No description provided for @provider_create_select_first.
  ///
  /// In en, this message translates to:
  /// **'Please select a provider type first'**
  String get provider_create_select_first;

  /// No description provided for @provider_create_selected.
  ///
  /// In en, this message translates to:
  /// **'Selected: {displayName}'**
  String provider_create_selected(Object displayName);

  /// No description provided for @provider_create_selected_semantic.
  ///
  /// In en, this message translates to:
  /// **'Selected provider: {displayName}'**
  String provider_create_selected_semantic(Object displayName);

  /// No description provided for @provider_delete_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String provider_delete_confirm_title(Object name);

  /// No description provided for @provider_delete_confirm_message.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Are you sure you want to delete this provider?'**
  String get provider_delete_confirm_message;

  /// No description provided for @provider_delete_success.
  ///
  /// In en, this message translates to:
  /// **'{name} deleted successfully'**
  String provider_delete_success(Object name);

  /// No description provided for @provider_delete_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete {name}: {error}'**
  String provider_delete_failed(Object error, Object name);

  /// No description provided for @provider_delete_button.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get provider_delete_button;

  /// No description provided for @provider_cancel_button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get provider_cancel_button;

  /// No description provided for @provider_detail_title.
  ///
  /// In en, this message translates to:
  /// **'Provider Details'**
  String get provider_detail_title;

  /// No description provided for @provider_detail_back_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Back to Providers'**
  String get provider_detail_back_tooltip;

  /// No description provided for @provider_detail_failed_to_load.
  ///
  /// In en, this message translates to:
  /// **'Failed to load provider'**
  String get provider_detail_failed_to_load;

  /// No description provided for @provider_detail_tooltip_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get provider_detail_tooltip_edit;

  /// No description provided for @provider_detail_tooltip_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get provider_detail_tooltip_delete;

  /// No description provided for @provider_detail_edit_coming_soon.
  ///
  /// In en, this message translates to:
  /// **'Edit feature - Coming soon!'**
  String get provider_detail_edit_coming_soon;

  /// No description provided for @provider_detail_section_basic.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get provider_detail_section_basic;

  /// No description provided for @provider_detail_section_config.
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get provider_detail_section_config;

  /// No description provided for @provider_detail_section_credentials.
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get provider_detail_section_credentials;

  /// No description provided for @provider_detail_field_id.
  ///
  /// In en, this message translates to:
  /// **'Provider ID'**
  String get provider_detail_field_id;

  /// No description provided for @provider_detail_field_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get provider_detail_field_name;

  /// No description provided for @provider_detail_field_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get provider_detail_field_type;

  /// No description provided for @provider_detail_field_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get provider_detail_field_category;

  /// No description provided for @provider_detail_field_base_url.
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get provider_detail_field_base_url;

  /// No description provided for @provider_detail_field_region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get provider_detail_field_region;

  /// No description provided for @provider_detail_field_api_key.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get provider_detail_field_api_key;

  /// No description provided for @provider_detail_field_access_key.
  ///
  /// In en, this message translates to:
  /// **'Access Key'**
  String get provider_detail_field_access_key;

  /// No description provided for @provider_detail_field_organization_id.
  ///
  /// In en, this message translates to:
  /// **'Organization ID'**
  String get provider_detail_field_organization_id;

  /// No description provided for @provider_detail_field_updated_at.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get provider_detail_field_updated_at;

  /// No description provided for @provider_detail_category_base.
  ///
  /// In en, this message translates to:
  /// **'Base (Default)'**
  String get provider_detail_category_base;

  /// No description provided for @provider_detail_category_byok.
  ///
  /// In en, this message translates to:
  /// **'BYOK (Custom)'**
  String get provider_detail_category_byok;

  /// No description provided for @common_button_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_button_cancel;

  /// No description provided for @common_button_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_button_delete;

  /// No description provided for @common_button_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_button_retry;

  /// No description provided for @common_button_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get common_button_refresh;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get common_error;

  /// No description provided for @common_not_specified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get common_not_specified;

  /// No description provided for @chat_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation'**
  String get chat_empty_title;

  /// No description provided for @chat_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Send a message to begin chatting with your agent'**
  String get chat_empty_subtitle;

  /// No description provided for @chat_input_hint.
  ///
  /// In en, this message translates to:
  /// **'Type your message...'**
  String get chat_input_hint;

  /// No description provided for @chat_send_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get chat_send_tooltip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
