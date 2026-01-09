/// Provider configuration model for LLM and Embedding providers
class ProviderConfig {
  final String id;
  final String name;
  final String providerType;
  final String providerCategory;
  final String? baseUrl;
  final DateTime? updatedAt;
  final String? organizationId;

  const ProviderConfig({
    required this.id,
    required this.name,
    required this.providerType,
    required this.providerCategory,
    this.baseUrl,
    this.updatedAt,
    this.organizationId,
  });

  /// Create ProviderConfig from JSON
  factory ProviderConfig.fromJson(Map<String, dynamic> json) {
    return ProviderConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      providerType: json['provider_type'] as String,
      providerCategory: json['provider_category'] as String,
      baseUrl: json['base_url'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      organizationId: json['organization_id'] as String?,
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
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (organizationId != null) 'organization_id': organizationId,
    };
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
