import 'dart:convert';
import 'package:http/http.dart' as http;

/// ========================================
/// Letta API Helper
///
/// Utility functions for API responses parsing and error handling.
/// This file is designed to be easily extracted into a separate SDK package.
///
/// Usage:
/// ```dart
/// final agents = ApiHelper.parseList(response, Agent.fromJson);
/// final agent = ApiHelper.parseSingle(response, Agent.fromJson);
/// ```
/// ========================================

/// Exception thrown when API request fails
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? detail;

  const ApiException._({
    required this.statusCode,
    required this.message,
    this.detail,
  });

  /// Create exception from HTTP response
  factory ApiException.fromResponse(http.Response response) {
    String message = 'Request failed: ${response.statusCode}';
    String? detail;

    try {
      final errorData = jsonDecode(response.body);
      if (errorData is Map) {
        if (errorData.containsKey('detail')) {
          detail = errorData['detail'].toString();
          message = 'Error: $detail';
        } else if (errorData.containsKey('message')) {
          detail = errorData['message'].toString();
          message = 'Error: $detail';
        }
      }
    } catch (_) {
      // If parsing fails, use default message
    }

    return ApiException._(
      statusCode: response.statusCode,
      message: message,
      detail: detail,
    );
  }

  @override
  String toString() => message;
}

/// Helper class for API operations
class ApiHelper {
  /// Parse a list response from API
  static List<T> parseList<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode != 200) {
      throw ApiException.fromResponse(response);
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! List) return [];
      return decoded
          .map((json) => json is Map<String, dynamic> ? fromJson(json) : null)
          .whereType<T>()
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Parse a single object response from API
  static T parseSingle<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException.fromResponse(response);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Response is not a valid object');
    }

    return fromJson(decoded);
  }

  /// Parse a response that may return empty body (e.g., DELETE)
  static void parseEmpty(http.Response response) {
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ApiException.fromResponse(response);
    }
  }
}
