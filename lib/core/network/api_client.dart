import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'ApiException: $message (statusCode: $statusCode)';
}

class ApiClient {
  final String baseUrl;
  final http.Client _client;

  ApiClient({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await _client
          .get(uri, headers: _buildHeaders(headers))
          .timeout(timeout);
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network request failed: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await _client
          .post(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);
      return _processResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network request failed: $e');
    }
  }

  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final defaultHeaders = {'Content-Type': 'application/json', 'Accept': 'application/json'};
    if (customHeaders != null) {
      defaultHeaders.addAll(customHeaders);
    }
    return defaultHeaders;
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    final statusCode = response.statusCode;
    dynamic bodyJson;
    try {
      if (response.body.isNotEmpty) {
        bodyJson = jsonDecode(response.body);
      }
    } catch (_) {
      bodyJson = response.body;
    }

    if (statusCode >= 200 && statusCode < 300) {
      if (bodyJson is Map<String, dynamic>) {
        return bodyJson;
      }
      return {'data': bodyJson};
    }

    String message = 'HTTP Error $statusCode';
    if (bodyJson is Map<String, dynamic> && bodyJson.containsKey('message')) {
      message = bodyJson['message'].toString();
    }

    throw ApiException(message, statusCode: statusCode, details: bodyJson);
  }
}
