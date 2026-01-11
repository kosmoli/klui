// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProviderConfig _$ProviderConfigFromJson(Map<String, dynamic> json) =>
    _ProviderConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      providerType: json['provider_type'] as String,
      providerCategory: json['provider_category'] as String,
      baseUrl: json['base_url'] as String?,
      apiKey: json['api_key'] as String?,
      accessKey: json['access_key'] as String?,
      region: json['region'] as String?,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      organizationId: json['organization_id'] as String?,
      apiKeyEnc: json['api_key_enc'] as String?,
      accessKeyEnc: json['access_key_enc'] as String?,
    );

Map<String, dynamic> _$ProviderConfigToJson(_ProviderConfig instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'provider_type': instance.providerType,
      'provider_category': instance.providerCategory,
      'base_url': instance.baseUrl,
      'api_key': instance.apiKey,
      'access_key': instance.accessKey,
      'region': instance.region,
      'updated_at': instance.updatedAt?.toIso8601String(),
      'organization_id': instance.organizationId,
      'api_key_enc': instance.apiKeyEnc,
      'access_key_enc': instance.accessKeyEnc,
    };
