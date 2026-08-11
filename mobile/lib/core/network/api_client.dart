import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient(this.baseUrl, {http.Client? client})
      : client = client ?? http.Client();
  final String baseUrl;
  final http.Client client;

  Future<Map<String, Object?>> post(String path, Object body) async {
    final response = await client
        .post(Uri.parse('$baseUrl$path'),
            headers: {'content-type': 'application/json'},
            body: jsonEncode(body))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode);
    }
    return jsonDecode(response.body) as Map<String, Object?>;
  }

  Future<List<Object?>> getList(String path) async {
    final response = await client
        .get(Uri.parse('$baseUrl$path'))
        .timeout(const Duration(seconds: 12));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode);
    }
    return jsonDecode(response.body) as List<Object?>;
  }
}

class ApiException implements Exception {
  const ApiException(this.statusCode);
  final int statusCode;
}
