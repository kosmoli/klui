import 'package:freezed_annotation/freezed_annotation.dart';

part 'provider.freezed.dart';
part 'provider.g.dart';

/// Provider configuration model for LLM and Embedding providers
/// In Memos, all providers are user-created (no BYOK/base distinction)
@freezed
abstract class ProviderConfig with _$ProviderConfig {
  const ProviderConfig._();

  const factory ProviderConfig({
    required String id,
    required String name,
    @JsonKey(name: 'provider_type') required String providerType,
    @JsonKey(name: 'base_url') String? baseUrl,
    @JsonKey(name: 'api_key') String? apiKey,
    @JsonKey(name: 'access_key') String? accessKey,
    String? region,
    @JsonKey(name: 'api_version') String? apiVersion,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @JsonKey(name: 'organization_id') String? organizationId,
    @JsonKey(name: 'api_key_enc') String? apiKeyEnc,
    @JsonKey(name: 'access_key_enc') String? accessKeyEnc,
  }) = _ProviderConfig;

  /// Create ProviderConfig from JSON
  factory ProviderConfig.fromJson(Map<String, dynamic> json) =>
      _$ProviderConfigFromJson(json);

  /// Get displayable API key (prefer encrypted, fallback to plain with masking)
  String get displayApiKey {
    // Prefer encrypted version if available
    if (apiKeyEnc != null && apiKeyEnc!.isNotEmpty) {
      return apiKeyEnc!.length <= 8
          ? '********'
          : '${apiKeyEnc!.substring(0, 8)}...';
    }
    // Fallback to plain API key with masking
    if (apiKey == null || apiKey!.isEmpty) return '';
    if (apiKey!.length <= 8) return '********';
    return '${apiKey!.substring(0, 8)}...';
  }

  /// Check if provider has any API key configured
  bool get hasApiKey =>
      (apiKeyEnc != null && apiKeyEnc!.isNotEmpty) ||
      (apiKey != null && apiKey!.isNotEmpty);

  /// Check if provider has access key configured
  bool get hasAccessKey =>
      (accessKeyEnc != null && accessKeyEnc!.isNotEmpty) ||
      (accessKey != null && accessKey!.isNotEmpty);
}
