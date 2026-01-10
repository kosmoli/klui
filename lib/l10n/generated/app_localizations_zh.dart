// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get app_title => 'Klui - Letta Agent管理';

  @override
  String get page_not_found => '页面未找到';

  @override
  String get nav_agents => 'Agent';

  @override
  String get nav_providers => 'Provider';

  @override
  String get nav_agents_tab => 'Agent标签页';

  @override
  String get nav_providers_tab => 'Provider标签页';

  @override
  String get nav_selected => '已选中';

  @override
  String nav_hint_navigate(Object page) {
    return '双击导航到$page页面';
  }

  @override
  String get agent_list_title => 'Agent';

  @override
  String get agent_list_no_agents => '未找到Agent';

  @override
  String get agent_list_create_first => '创建您的第一个Agent以开始使用';

  @override
  String get agent_list_error_loading => '加载Agent时出错';

  @override
  String get agent_list_retry => '重试';

  @override
  String get agent_list_create_button => '创建Agent';

  @override
  String agent_card_label(Object model, Object name, Object type) {
    return 'Agent卡片：$name，类型：$type，Model：$model';
  }

  @override
  String get agent_card_hint_view_details => '双击查看详情';

  @override
  String get agent_card_hint_with_actions => '双击查看详情，有编辑按钮，有删除按钮';

  @override
  String get agent_card_hint_with_edit => '双击查看详情，有编辑按钮';

  @override
  String get agent_card_hint_with_delete => '双击查看详情，有删除按钮';

  @override
  String get agent_card_not_specified => '未指定';

  @override
  String agent_card_ago_days(Object count) {
    return '$count天前';
  }

  @override
  String agent_card_ago_hours(Object count) {
    return '$count小时前';
  }

  @override
  String agent_card_ago_minutes(Object count) {
    return '$count分钟前';
  }

  @override
  String get agent_card_ago_just_now => '刚刚';

  @override
  String get agent_card_model_unknown => '未知';

  @override
  String get agent_action_edit => '编辑';

  @override
  String get agent_action_edit_hint => '双击编辑';

  @override
  String get agent_action_delete => '删除';

  @override
  String get agent_action_delete_hint => '双击删除';

  @override
  String get agent_action_destructive => '（危险操作）';

  @override
  String agent_edit_coming_soon(Object name) {
    return '编辑 $name - 即将推出！';
  }

  @override
  String agent_delete_success(Object name) {
    return '$name 删除成功';
  }

  @override
  String agent_delete_failed(Object error, Object name) {
    return '删除 $name 失败：$error';
  }

  @override
  String agent_delete_confirm_title(Object name) {
    return '删除 $name？';
  }

  @override
  String get agent_delete_confirm_message => '此操作无法撤销。您确定要删除此Agent吗？';

  @override
  String get agent_delete_button => '删除';

  @override
  String get agent_cancel_button => '取消';

  @override
  String get agent_create_title => '创建Agent';

  @override
  String get agent_create_back_tooltip => '返回Agent列表';

  @override
  String agent_create_step_indicator(Object current, Object total) {
    return '第 $current/$total 步';
  }

  @override
  String get agent_create_button_next => '下一步';

  @override
  String get agent_create_button_back => '返回';

  @override
  String get agent_create_button_create => '创建Agent';

  @override
  String get agent_create_creating => '创建中...';

  @override
  String agent_create_success(Object name) {
    return '$name 创建成功';
  }

  @override
  String agent_create_failed(Object error) {
    return '创建Agent失败：$error';
  }

  @override
  String get agent_create_step_provider_title => '选择Provider';

  @override
  String get agent_create_step_model_title => '选择Model';

  @override
  String get agent_create_step_provider_desc =>
      '为您的Agent选择 LLM 和 Embedding Provider';

  @override
  String get agent_create_step_model_desc => '为您的Agent选择 LLM 和 Embedding Model';

  @override
  String get agent_create_step_basic_title => '基本信息';

  @override
  String get agent_create_step_basic_desc => '输入您代理的基本信息';

  @override
  String get agent_create_step_review_title => '查看并确认';

  @override
  String get agent_create_step_review_desc => '在创建之前查看您的Agent配置';

  @override
  String get agent_create_byok_mode => 'BYOK 模式';

  @override
  String get agent_create_byok_desc => '启用自备密钥（BYOK）模式以使用自定义Provider';

  @override
  String get agent_create_byok_enabled => 'BYOK 已启用';

  @override
  String get agent_create_byok_disabled => 'BYOK 已禁用';

  @override
  String get agent_create_llm_provider => 'LLM Provider';

  @override
  String get agent_create_embedding_provider => 'Embedding Provider';

  @override
  String get agent_create_llm_model => 'LLM Model';

  @override
  String get agent_create_embedding_model => 'Embedding Model';

  @override
  String get agent_create_select_provider => '选择Provider';

  @override
  String get agent_create_select_model => '选择Model';

  @override
  String get agent_create_no_models => '没有可用Model';

  @override
  String get agent_create_select_provider_first => '请先选择Provider';

  @override
  String get agent_create_please_select_model => '请选择Model';

  @override
  String get agent_create_field_name => 'Agent名称';

  @override
  String get agent_create_field_name_hint => '输入您的Agent名称';

  @override
  String get agent_create_field_description => '描述';

  @override
  String get agent_create_field_description_hint => '输入您的Agent描述';

  @override
  String get agent_create_field_system_prompt => '系统提示词';

  @override
  String get agent_create_field_system_prompt_hint => '输入您的Agent系统提示词';

  @override
  String get agent_create_validation_name => '请输入Agent名称';

  @override
  String get agent_create_validation_system_prompt => '请输入系统提示词';

  @override
  String get agent_create_validation_llm_provider => '请选择 LLM Provider和Model';

  @override
  String get agent_create_validation_llm_model => '请选择 LLM Model';

  @override
  String get agent_create_validation_embedding_provider =>
      '请选择 Embedding Provider和Model';

  @override
  String get agent_create_validation_embedding_model => '请选择 Embedding Model';

  @override
  String get agent_create_review_name => '名称';

  @override
  String get agent_create_review_description => '描述';

  @override
  String get agent_create_review_system_prompt => '系统提示词';

  @override
  String get agent_create_review_llm_model => 'LLM Model';

  @override
  String get agent_create_review_embedding_model => 'Embedding Model';

  @override
  String get agent_create_review_not_selected => '未选择';

  @override
  String agent_create_error_loading(Object error) {
    return '加载数据失败：$error';
  }

  @override
  String agent_create_error_llm_models(Object error) {
    return '加载 LLM Model失败：$error';
  }

  @override
  String agent_create_error_embedding_models(Object error) {
    return '加载 Embedding Model失败：$error';
  }

  @override
  String get agent_detail_title => '代理详情';

  @override
  String get agent_detail_back_tooltip => '返回代理列表';

  @override
  String get agent_detail_tooltip_edit => '编辑';

  @override
  String get agent_detail_tooltip_delete => '删除';

  @override
  String get agent_detail_edit_coming_soon => '编辑功能 - 即将推出！';

  @override
  String get agent_detail_failed_to_load => '加载代理失败';

  @override
  String get agent_detail_deleted_success => '代理删除成功';

  @override
  String agent_detail_delete_failed(Object error) {
    return '删除Agent失败：$error';
  }

  @override
  String get agent_detail_section_basic => '基本信息';

  @override
  String get agent_detail_section_model_base => 'Model配置（基础模式）';

  @override
  String get agent_detail_section_llm_byok => 'LLM 配置（BYOK 模式）';

  @override
  String get agent_detail_section_embedding => 'Embedding 配置';

  @override
  String get agent_detail_section_timestamps => '时间戳';

  @override
  String get agent_detail_section_system_prompt => '系统提示词';

  @override
  String get agent_detail_section_config => '配置';

  @override
  String get agent_detail_field_id => '代理 ID';

  @override
  String get agent_detail_field_name => '名称';

  @override
  String get agent_detail_field_description => '描述';

  @override
  String get agent_detail_field_agent_type => '代理类型';

  @override
  String get agent_detail_field_model_handle => 'Model句柄';

  @override
  String get agent_detail_field_model => 'Model';

  @override
  String get agent_detail_field_provider => 'Provider';

  @override
  String get agent_detail_field_context_window => '上下文窗口';

  @override
  String get agent_detail_field_embedding_model => 'Model';

  @override
  String get agent_detail_field_embedding_provider => 'Provider';

  @override
  String get agent_detail_field_embedding_dim => '维度';

  @override
  String get agent_detail_field_created => '创建时间';

  @override
  String get agent_detail_field_modified => '最后修改';

  @override
  String agent_detail_context_window_tokens(Object count) {
    return '$count 令牌';
  }

  @override
  String get agent_detail_n_a => '不适用';

  @override
  String get provider_list_title => 'Provider';

  @override
  String get provider_list_no_providers => '未找到 BYOK Provider';

  @override
  String get provider_list_create_first => '创建自定义Provider以使用您自己的 API 密钥';

  @override
  String get provider_list_error_loading => '加载Provider时出错';

  @override
  String get provider_list_retry => '重试';

  @override
  String get provider_list_create_button => '创建Provider';

  @override
  String provider_list_details_coming_soon(Object name) {
    return '$name 的Provider详情 - 即将推出！';
  }

  @override
  String provider_card_label(Object category, Object name, Object type) {
    return 'Provider卡片：$name，类型：$type，类别：$category';
  }

  @override
  String get provider_card_hint_view_details => '双击查看详情';

  @override
  String get provider_card_hint_with_delete => '双击查看详情，有删除按钮';

  @override
  String get provider_card_delete_provider => '删除Provider';

  @override
  String get provider_card_delete_hint => '双击删除Provider';

  @override
  String get provider_card_destructive => '（危险操作）';

  @override
  String provider_card_type_label(Object type) {
    return '$type Provider类型';
  }

  @override
  String provider_card_ago_days(Object count) {
    return '$count天前';
  }

  @override
  String provider_card_ago_hours(Object count) {
    return '$count小时前';
  }

  @override
  String provider_card_ago_minutes(Object count) {
    return '$count分钟前';
  }

  @override
  String get provider_card_ago_just_now => '刚刚';

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
  String get provider_create_title => '创建Provider';

  @override
  String get provider_create_creating => '创建Provider中...';

  @override
  String provider_create_success(Object name) {
    return 'Provider \"$name\" 创建成功';
  }

  @override
  String provider_create_failed(Object error) {
    return '创建Provider失败：$error';
  }

  @override
  String get provider_create_step_type => '类型';

  @override
  String get provider_create_step_config => '配置';

  @override
  String get provider_create_step_type_title => 'Provider类型';

  @override
  String get provider_create_step_config_title => '配置';

  @override
  String get provider_create_button_back => '返回';

  @override
  String get provider_create_button_next => '下一步';

  @override
  String get provider_create_button_create => '创建Provider';

  @override
  String get provider_create_openai_name => 'OpenAI';

  @override
  String get provider_create_openai_desc => 'GPT-4、GPT-3.5 等';

  @override
  String get provider_create_anthropic_name => 'Anthropic';

  @override
  String get provider_create_anthropic_desc => 'Claude 3.5 Sonnet、Opus 等';

  @override
  String get provider_create_ollama_name => 'Ollama';

  @override
  String get provider_create_ollama_desc => '本地开源Model';

  @override
  String get provider_create_google_ai_name => 'Google AI';

  @override
  String get provider_create_google_ai_desc => 'Gemini Pro、Gemini Flash';

  @override
  String get provider_create_google_vertex_name => 'Google Vertex AI';

  @override
  String get provider_create_google_vertex_desc => '企业级 AI Model';

  @override
  String provider_create_select_type_label(
    Object description,
    Object displayName,
  ) {
    return 'Provider类型：$displayName，$description';
  }

  @override
  String provider_create_select_hint(Object displayName) {
    return '双击选择 $displayName Provider';
  }

  @override
  String get provider_create_field_provider_type => 'Provider类型';

  @override
  String get provider_create_field_provider_type_hint => '选择Provider类型';

  @override
  String get provider_create_field_provider_type_semantic => 'Provider类型下拉框';

  @override
  String get provider_create_field_provider_type_hint_semantic =>
      '双击打开Provider类型下拉框';

  @override
  String get provider_create_validation_provider_type => '请选择Provider类型';

  @override
  String get provider_create_field_name => 'Provider名称';

  @override
  String get provider_create_field_name_hint => '例如：my-openai';

  @override
  String get provider_create_field_name_semantic => 'Provider名称输入框';

  @override
  String get provider_create_field_name_hint_semantic =>
      '输入此Provider的唯一名称，例如：my-openai';

  @override
  String get provider_create_validation_name => '请输入Provider名称';

  @override
  String get provider_create_field_api_key => 'API 密钥';

  @override
  String get provider_create_field_api_key_hint_openai => 'sk-...';

  @override
  String get provider_create_field_api_key_hint_anthropic => 'sk-ant-...';

  @override
  String get provider_create_field_api_key_hint_google_ai => 'AIza...';

  @override
  String get provider_create_field_api_key_hint_default => '输入您的 API 密钥';

  @override
  String get provider_create_field_api_key_semantic => 'API 密钥输入框';

  @override
  String provider_create_field_api_key_hint_semantic(Object provider) {
    return '输入您的 $provider API 密钥';
  }

  @override
  String get provider_create_validation_api_key => '请输入 API 密钥';

  @override
  String get provider_create_field_base_url => '基础 URL';

  @override
  String get provider_create_field_base_url_hint =>
      '例如：https://api.openai.com/v1';

  @override
  String get provider_create_field_base_url_semantic => '基础 URL 输入框';

  @override
  String get provider_create_field_base_url_hint_semantic =>
      '输入 API 端点 URL，例如：https://api.openai.com/v1';

  @override
  String get provider_create_validation_base_url => '请输入基础 URL';

  @override
  String get provider_create_field_project => 'Google Cloud 项目';

  @override
  String get provider_create_field_project_hint => '例如：my-project';

  @override
  String get provider_create_field_project_semantic => 'Google Cloud 项目 ID 输入框';

  @override
  String get provider_create_field_project_hint_semantic =>
      '输入您的 Google Cloud 项目 ID，例如：my-project';

  @override
  String get provider_create_validation_project => '请输入项目 ID';

  @override
  String get provider_create_field_location => '位置';

  @override
  String get provider_create_field_location_hint => '例如：us-central1';

  @override
  String get provider_create_field_location_semantic => 'Google Cloud 位置输入框';

  @override
  String get provider_create_field_location_hint_semantic =>
      '输入 Google Cloud 区域，例如：us-central1';

  @override
  String get provider_create_validation_location => '请输入位置';

  @override
  String get provider_create_select_first => '请先选择Provider类型';

  @override
  String provider_create_selected(Object displayName) {
    return '已选择：$displayName';
  }

  @override
  String provider_create_selected_semantic(Object displayName) {
    return '已选择的Provider：$displayName';
  }

  @override
  String provider_delete_confirm_title(Object name) {
    return '删除 $name？';
  }

  @override
  String get provider_delete_confirm_message => '此操作无法撤销。您确定要删除此Provider吗？';

  @override
  String provider_delete_success(Object name) {
    return '$name 删除成功';
  }

  @override
  String provider_delete_failed(Object error, Object name) {
    return '删除 $name 失败：$error';
  }

  @override
  String get provider_delete_button => '删除';

  @override
  String get provider_cancel_button => '取消';

  @override
  String get common_button_cancel => '取消';

  @override
  String get common_button_delete => '删除';

  @override
  String get common_button_retry => '重试';

  @override
  String get common_button_refresh => '刷新';

  @override
  String get common_loading => '加载中...';

  @override
  String get common_error => '错误';

  @override
  String get common_not_specified => '未指定';
}
