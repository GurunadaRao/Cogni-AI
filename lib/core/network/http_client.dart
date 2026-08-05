import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpApiClient {
  String baseUrl;

  HttpApiClient({this.baseUrl = 'http://localhost:8080'});

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('HTTP GET Error ${response.statusCode}: ${response.body}');
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      throw Exception('HTTP POST Error ${response.statusCode}: ${response.body}');
    } catch (e) {
      rethrow;
    }
  }
}
