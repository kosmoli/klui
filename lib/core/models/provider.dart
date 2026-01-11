/// Provider configuration model for LLM and Embedding providers
class ProviderConfig {
  final String id;
  final String name;
  final String providerType;
  final String providerCategory;
  final String? baseUrl;
  final String? apiKey;
  final String? accessKey;
  final String? region;
  final DateTime? updatedAt;
  final String? organizationId;
  final String? apiKeyEnc;
  final String? accessKeyEnc;

  const ProviderConfig({
    required this.id,
    required this.name,
    required this.providerType,
    required this.providerCategory,
    this.baseUrl,
    this.apiKey,
    this.accessKey,
    this.region,
    this.updatedAt,
    this.organizationId,
    this.apiKeyEnc,
    this.accessKeyEnc,
  });

  /// Create ProviderConfig from JSON
  factory ProviderConfig.fromJson(Map<String, dynamic> json) {
    return ProviderConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      providerType: json['provider_type'] as String,
      providerCategory: json['provider_category'] as String,
      baseUrl: json['base_url'] as String?,
      apiKey: json['api_key'] as String?,
      accessKey: json['access_key'] as String?,
      region: json['region'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      organizationId: json['organization_id'] as String?,
      apiKeyEnc: json['api_key_enc'] as String?,
      accessKeyEnc: json['access_key_enc'] as String?,
    );
  }

  /// Convert ProviderConfig to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'provider_type': providerType,
      'provider_category': providerCategory,
      if (baseUrl != null) 'base_url': baseUrl,
      if (apiKey != null) 'api_key': apiKey,
      if (accessKey != null) 'access_key': accessKey,
      if (region != null) 'region': region,
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (organizationId != null) 'organization_id': organizationId,
      if (apiKeyEnc != null) 'api_key_enc': apiKeyEnc,
      if (accessKeyEnc != null) 'access_key_enc': accessKeyEnc,
    };
  }

  /// Get displayable API key (prefer encrypted, fallback to plain with masking)
  String get displayApiKey {
    // Prefer encrypted version if available
    if (apiKeyEnc != null && apiKeyEnc!.isNotEmpty) {
      return apiKeyEnc!.length <= 8 ? '********' : '${apiKeyEnc!.substring(0, 8)}...';
    }
    // Fallback to plain API key with masking
    if (apiKey == null || apiKey!.isEmpty) return '';
    if (apiKey!.length <= 8) return '********';
    return '${apiKey!.substring(0, 8)}...';
  }

  /// Check if provider has any API key configured
  bool get hasApiKey => (apiKeyEnc != null && apiKeyEnc!.isNotEmpty) || (apiKey != null && apiKey!.isNotEmpty);

  /// Check if provider has access key configured
  bool get hasAccessKey => (accessKeyEnc != null && accessKeyEnc!.isNotEmpty) || (accessKey != null && accessKey!.isNotEmpty);

  @override
  String toString() {
    return 'ProviderConfig(id: $id, name: $name, type: $providerType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProviderConfig && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
