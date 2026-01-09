/// LLM Model configuration
class LLMModel {
  final String handle;
  final String name;
  final String displayName;
  final String providerType;
  final String providerName;
  final String model;
  final String modelEndpointType;
  final String modelEndpoint;
  final String providerCategory;
  final String modelType; // "llm" or "embedding"
  final int contextWindow;
  final bool putInnerThoughtsInKwargs;
  final double temperature;
  final int maxTokens;

  const LLMModel({
    required this.handle,
    required this.name,
    required this.displayName,
    required this.providerType,
    required this.providerName,
    required this.model,
    required this.modelEndpointType,
    required this.modelEndpoint,
    required this.providerCategory,
    required this.modelType,
    required this.contextWindow,
    required this.putInnerThoughtsInKwargs,
    required this.temperature,
    required this.maxTokens,
  });

  /// Create LLMModel from JSON
  factory LLMModel.fromJson(Map<String, dynamic> json) {
    return LLMModel(
      handle: json['handle'] as String,
      name: json['name'] as String,
      displayName: json['display_name'] as String,
      providerType: json['provider_type'] as String,
      providerName: json['provider_name'] as String,
      model: json['model'] as String,
      modelEndpointType: json['model_endpoint_type'] as String,
      modelEndpoint: json['model_endpoint'] as String,
      providerCategory: json['provider_category'] as String,
      modelType: json['model_type'] as String,
      contextWindow: json['context_window'] as int,
      putInnerThoughtsInKwargs: json['put_inner_thoughts_in_kwargs'] as bool,
      temperature: (json['temperature'] as num).toDouble(),
      maxTokens: json['max_tokens'] as int,
    );
  }

  /// Convert LLMModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'handle': handle,
      'name': name,
      'display_name': displayName,
      'provider_type': providerType,
      'provider_name': providerName,
      'model': model,
      'model_endpoint_type': modelEndpointType,
      'model_endpoint': modelEndpoint,
      'provider_category': providerCategory,
      'model_type': modelType,
      'context_window': contextWindow,
      'put_inner_thoughts_in_kwargs': putInnerThoughtsInKwargs,
      'temperature': temperature,
      'max_tokens': maxTokens,
    };
  }

  @override
  String toString() {
    return 'LLMModel(name: $name, provider: $providerName, model: $model)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LLMModel && other.handle == handle;
  }

  @override
  int get hashCode => handle.hashCode;
}
