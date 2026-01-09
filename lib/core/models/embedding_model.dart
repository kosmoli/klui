/// Embedding Model configuration
class EmbeddingModel {
  final String handle;
  final String name;
  final String displayName;
  final String providerType;
  final String providerName;
  final String embeddingModel;
  final String embeddingEndpointType;
  final String embeddingEndpoint;
  final int embeddingDim;
  final int embeddingChunkSize;
  final int batchSize;

  const EmbeddingModel({
    required this.handle,
    required this.name,
    required this.displayName,
    required this.providerType,
    required this.providerName,
    required this.embeddingModel,
    required this.embeddingEndpointType,
    required this.embeddingEndpoint,
    required this.embeddingDim,
    required this.embeddingChunkSize,
    required this.batchSize,
  });

  /// Create EmbeddingModel from JSON
  factory EmbeddingModel.fromJson(Map<String, dynamic> json) {
    return EmbeddingModel(
      handle: json['handle'] as String,
      name: json['name'] as String,
      displayName: json['display_name'] as String,
      providerType: json['provider_type'] as String,
      providerName: json['provider_name'] as String,
      embeddingModel: json['embedding_model'] as String,
      embeddingEndpointType: json['embedding_endpoint_type'] as String,
      embeddingEndpoint: json['embedding_endpoint'] as String,
      embeddingDim: json['embedding_dim'] as int,
      embeddingChunkSize: json['embedding_chunk_size'] as int,
      batchSize: json['batch_size'] as int,
    );
  }

  /// Convert EmbeddingModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'handle': handle,
      'name': name,
      'display_name': displayName,
      'provider_type': providerType,
      'provider_name': providerName,
      'embedding_model': embeddingModel,
      'embedding_endpoint_type': embeddingEndpointType,
      'embedding_endpoint': embeddingEndpoint,
      'embedding_dim': embeddingDim,
      'embedding_chunk_size': embeddingChunkSize,
      'batch_size': batchSize,
    };
  }

  @override
  String toString() {
    return 'EmbeddingModel(name: $name, provider: $providerName, dim: $embeddingDim)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmbeddingModel && other.handle == handle;
  }

  @override
  int get hashCode => handle.hashCode;
}
