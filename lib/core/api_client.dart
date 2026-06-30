import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'constants.dart';

class ApiClient {
  final String baseUrl = AppConstants.baseUrl;

  // Headers
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // GET
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Erreur de connexion: $e');
    }
  }

  // POST
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException('Erreur de connexion: $e');
    }
  }

  // Handle response
  dynamic _handleResponse(http.Response response) {
    debugPrint('📡 ${response.statusCode}: ${response.body}');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw ApiException(error['message'] ?? 'Erreur ${response.statusCode}');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}