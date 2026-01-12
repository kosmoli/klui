import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/retry.dart';
import '../config/app_config.dart';
import 'auth_interceptor.dart';

/// HTTP Client for Letta API communication
class ApiClient {
  late final http.Client _client;

  ApiClient({String? authToken}) {
    _client = RetryClient(
      AuthInterceptor(client: http.Client(), authToken: authToken),
      retries: 3,
      when: (response) {
        // Retry on server errors and network issues
        return response.statusCode == null ||
            response.statusCode! >= 500 ||
            response.statusCode == 408;
      },
      whenError: (error, stack) {
        // Retry on network errors
        return error is http.ClientException;
      },
      delay: (attempt) {
        // Exponential backoff
        return Duration(milliseconds: 1000 * (1 << attempt));
      },
    );
  }

  /// Update authentication token
  void updateAuthToken(String? token) {
    // TODO: Implement token update logic
  }

  /// GET request
  Future<http.Response> get(String path, {Map<String, String>? queryParameters}) async {
    final uri = Uri.parse('${AppConfig.fullApiBaseUrl}$path');
    final url = queryParameters != null && queryParameters.isNotEmpty
        ? uri.replace(queryParameters: queryParameters)
        : uri;
    print('[ApiClient] GET: $url');  // Debug log
    return _client.get(url).timeout(AppConfig.requestTimeout);
  }

  /// POST request
  Future<http.Response> post(String path, {Object? body}) async {
    final url = Uri.parse('${AppConfig.fullApiBaseUrl}$path');
    print('[ApiClient] POST: $url');  // Debug log
    return _client
        .post(
          url,
          body: body,
          headers: body != null ? {'Content-Type': 'application/json'} : {},
        )
        .timeout(AppConfig.requestTimeout);
  }

  /// PUT request
  Future<http.Response> put(String path, {Object? body}) async {
    final url = Uri.parse('${AppConfig.fullApiBaseUrl}$path');
    return _client
        .put(
          url,
          body: body,
          headers: body != null ? {'Content-Type': 'application/json'} : {},
        )
        .timeout(AppConfig.requestTimeout);
  }

  /// PATCH request
  Future<http.Response> patch(String path, {Object? body}) async {
    final url = Uri.parse('${AppConfig.fullApiBaseUrl}$path');
    print('[ApiClient] PATCH: $url');  // Debug log
    return _client
        .patch(
          url,
          body: body,
          headers: body != null ? {'Content-Type': 'application/json'} : {},
        )
        .timeout(AppConfig.requestTimeout);
  }

  /// DELETE request
  Future<http.Response> delete(String path) async {
    final url = Uri.parse('${AppConfig.fullApiBaseUrl}$path');
    return _client.delete(url).timeout(AppConfig.requestTimeout);
  }

  /// Stream POST request for SSE
  /// Returns a Stream of String lines from the server
  Stream<String> streamPost(String path, {Object? body}) async* {
    final url = Uri.parse('${AppConfig.fullApiBaseUrl}$path');
    print('[ApiClient] STREAM POST: $url');  // Debug log

    final request = http.Request('POST', url);
    if (body != null) {
      request.body = jsonEncode(body);
    }
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'text/event-stream';

    try {
      final streamedResponse = await _client.send(request).timeout(
        const Duration(minutes: 5), // Longer timeout for streaming
      );

      print('[ApiClient] Response status: ${streamedResponse.statusCode}');
      print('[ApiClient] Response headers: ${streamedResponse.headers}');

      // Check for error status codes
      if (streamedResponse.statusCode != 200) {
        print('[ApiClient] ERROR: Status ${streamedResponse.statusCode}');
        throw Exception('HTTP ${streamedResponse.statusCode}: ${streamedResponse.reasonPhrase}');
      }

      // Stream the response line by line
      int lineCount = 0;
      await for (final line in streamedResponse.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        lineCount++;
        if (lineCount <= 10) {  // Log first 10 lines
          print('[ApiClient] Received line $lineCount: ${line.length > 100 ? line.substring(0, 100) : line}');
        }
        yield line;
      }
      print('[ApiClient] Stream completed. Total lines: $lineCount');
    } catch (e) {
      print('[ApiClient] Stream error: $e');
      rethrow;
    }
  }

  /// Close the client
  void close() {
    _client.close();
  }
}
