import 'package:freezed_annotation/freezed_annotation.dart';

part 'llm_model.freezed.dart';

/// LLM Model configuration
@freezed
abstract class LLMModel with _$LLMModel {
  const LLMModel._();

  const factory LLMModel({
    required String handle,
    required String name,
    @JsonKey(name: 'display_name') required String displayName,
    @JsonKey(name: 'provider_type') required String providerType,
    @JsonKey(name: 'provider_name') required String providerName,
    required String model,
    @JsonKey(name: 'model_endpoint_type') required String modelEndpointType,
    @JsonKey(name: 'model_endpoint') required String modelEndpoint,
    @JsonKey(name: 'provider_category') required String providerCategory,
    @JsonKey(name: 'model_type') required String modelType,
    @JsonKey(name: 'context_window') required int contextWindow,
    @JsonKey(name: 'put_inner_thoughts_in_kwargs')
        required bool putInnerThoughtsInKwargs,
    required double temperature,
    @JsonKey(name: 'max_tokens') required int maxTokens,
  }) = _LLMModel;

  /// Create LLMModel from JSON with custom fallback logic
  factory LLMModel.fromJson(Map<String, dynamic> json) {
    // Embedding models from /v1/models/embedding don't have provider_category field
    final providerCategory = json['provider_category'] as String? ?? 'base';

    return LLMModel(
      handle: json['handle'] as String,
      name: json['name'] as String,
      displayName: json['display_name'] as String,
      providerType: json['provider_type'] as String? ??
          json['embedding_endpoint_type'] as String? ??
          'unknown',
      providerName: json['provider_name'] as String,
      model: json['model'] as String? ?? json['embedding_model'] as String? ?? '',
      modelEndpointType: json['model_endpoint_type'] as String? ??
          json['embedding_endpoint_type'] as String? ??
          'unknown',
      modelEndpoint: json['model_endpoint'] as String? ??
          json['embedding_endpoint'] as String? ??
          '',
      providerCategory: providerCategory,
      modelType: json['model_type'] as String? ??
          (json.containsKey('embedding_model') ? 'embedding' : 'llm'),
      contextWindow: json['context_window'] as int? ?? 30000,
      putInnerThoughtsInKwargs:
          json['put_inner_thoughts_in_kwargs'] as bool? ?? false,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      maxTokens: json['max_tokens'] as int? ?? 4096,
    );
  }
}
