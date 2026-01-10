/// Request model for creating a Provider
/// Supports multiple provider types with their specific configurations
class CreateProviderRequest {
  final String name;
  final String providerType;
  final Map<String, dynamic> providerConfig;

  const CreateProviderRequest({
    required this.name,
    required this.providerType,
    required this.providerConfig,
  });

  /// Factory constructor for OpenAI provider
  factory CreateProviderRequest.openai({
    required String name,
    required String apiKey,
    String? baseUrl,
  }) {
    return CreateProviderRequest(
      name: name,
      providerType: 'openai',
      providerConfig: {
        'api_key': apiKey,
        if (baseUrl != null) 'base_url': baseUrl,
      },
    );
  }

  /// Factory constructor for Anthropic provider
  factory CreateProviderRequest.anthropic({
    required String name,
    required String apiKey,
  }) {
    return CreateProviderRequest(
      name: name,
      providerType: 'anthropic',
      providerConfig: {
        'api_key': apiKey,
      },
    );
  }

  /// Factory constructor for Ollama provider
  factory CreateProviderRequest.ollama({
    required String name,
    required String baseUrl,
  }) {
    return CreateProviderRequest(
      name: name,
      providerType: 'ollama',
      providerConfig: {
        'base_url': baseUrl,
      },
    );
  }

  /// Factory constructor for Google AI provider
  factory CreateProviderRequest.googleAi({
    required String name,
    required String apiKey,
  }) {
    return CreateProviderRequest(
      name: name,
      providerType: 'google_ai',
      providerConfig: {
        'api_key': apiKey,
      },
    );
  }

  /// Factory constructor for Google Vertex provider
  factory CreateProviderRequest.googleVertex({
    required String name,
    required String project,
    required String location,
  }) {
    return CreateProviderRequest(
      name: name,
      providerType: 'google_vertex',
      providerConfig: {
        'project': project,
        'location': location,
      },
    );
  }

  /// Convert to JSON for API request
  /// Flattens provider_config to top level for Letta API compatibility
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'name': name,
      'provider_type': providerType,
    };

    // Flatten provider_config fields to top level
    providerConfig.forEach((key, value) {
      json[key] = value;
    });

    return json;
  }
}
