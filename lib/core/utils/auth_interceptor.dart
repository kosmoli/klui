import 'package:http/http.dart' as http;
import 'package:http/retry.dart';

/// HTTP client interceptor that adds authentication headers
class AuthInterceptor extends http.BaseClient {
  final http.Client _inner;
  final String? _authToken;

  AuthInterceptor({required http.Client client, String? authToken})
    : _inner = client,
      _authToken = authToken;

  set authToken(String? token) {
    // TODO: Implement token update
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Add authentication header if token is available
    if (_authToken != null && _authToken!.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $_authToken';
    }

    // Add common headers
    request.headers['Content-Type'] = 'application/json';

    return _inner.send(request);
  }
}
