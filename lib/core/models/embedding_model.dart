import 'package:freezed_annotation/freezed_annotation.dart';

part 'embedding_model.freezed.dart';
part 'embedding_model.g.dart';

/// Embedding Model configuration
@freezed
abstract class EmbeddingModel with _$EmbeddingModel {
  const EmbeddingModel._();

  const factory EmbeddingModel({
    required String handle,
    required String name,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'provider_type') required String providerType,
    @JsonKey(name: 'provider_name') required String providerName,
    @JsonKey(name: 'embedding_model') required String embeddingModel,
    @JsonKey(name: 'embedding_endpoint_type') required String embeddingEndpointType,
    @JsonKey(name: 'embedding_endpoint') required String embeddingEndpoint,
    @JsonKey(name: 'embedding_dim') required int embeddingDim,
    @JsonKey(name: 'embedding_chunk_size') required int embeddingChunkSize,
    @JsonKey(name: 'batch_size') required int batchSize,
  }) = _EmbeddingModel;

  /// Create EmbeddingModel from JSON
  factory EmbeddingModel.fromJson(Map<String, dynamic> json) =>
      _$EmbeddingModelFromJson(json);
}
