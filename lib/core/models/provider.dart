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
  final String? project;
  final DateTime? updatedAt;
  final String? organizationId;
  final Map<String, dynamic>? tags;

  const ProviderConfig({
    required this.id,
    required this.name,
    required this.providerType,
    required this.providerCategory,
    this.baseUrl,
    this.apiKey,
    this.accessKey,
    this.region,
    this.project,
    this.updatedAt,
    this.organizationId,
    this.tags,
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
      project: json['project'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      organizationId: json['organization_id'] as String?,
      tags: json['tags'] as Map<String, dynamic>?,
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
      if (project != null) 'project': project,
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (organizationId != null) 'organization_id': organizationId,
      if (tags != null) 'tags': tags,
    };
  }

  /// Get masked API key for display (show only first 8 chars)
  String get maskedApiKey {
    if (apiKey == null || apiKey!.isEmpty) return '';
    if (apiKey!.length <= 8) return '********';
    return '${apiKey!.substring(0, 8)}...';
  }

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
