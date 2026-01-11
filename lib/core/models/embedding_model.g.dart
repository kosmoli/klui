// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'embedding_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EmbeddingModel _$EmbeddingModelFromJson(Map<String, dynamic> json) =>
    _EmbeddingModel(
      handle: json['handle'] as String,
      name: json['name'] as String,
      displayName: json['display_name'] as String,
      providerType: json['provider_type'] as String,
      providerName: json['provider_name'] as String,
      embeddingModel: json['embedding_model'] as String,
      embeddingEndpointType: json['embedding_endpoint_type'] as String,
      embeddingEndpoint: json['embedding_endpoint'] as String,
      embeddingDim: (json['embedding_dim'] as num).toInt(),
      embeddingChunkSize: (json['embedding_chunk_size'] as num).toInt(),
      batchSize: (json['batch_size'] as num).toInt(),
    );

Map<String, dynamic> _$EmbeddingModelToJson(_EmbeddingModel instance) =>
    <String, dynamic>{
      'handle': instance.handle,
      'name': instance.name,
      'display_name': instance.displayName,
      'provider_type': instance.providerType,
      'provider_name': instance.providerName,
      'embedding_model': instance.embeddingModel,
      'embedding_endpoint_type': instance.embeddingEndpointType,
      'embedding_endpoint': instance.embeddingEndpoint,
      'embedding_dim': instance.embeddingDim,
      'embedding_chunk_size': instance.embeddingChunkSize,
      'batch_size': instance.batchSize,
    };
