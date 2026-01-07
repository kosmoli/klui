/// Application configuration
class AppConfig {
  /// API base URL for Letta backend
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8283',
  );

  /// API version
  static const String apiVersion = 'v1';

  /// Full API base URL with version
  /// Note: Letta API uses '/v1/' not '/api/v1/'
  static String get fullApiBaseUrl => '$apiBaseUrl/$apiVersion';

  /// Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);

  /// SSE connection timeout
  static const Duration sseTimeout = Duration(minutes: 5);
}
