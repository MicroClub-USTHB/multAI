import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/failure.dart';
import 'network_info.dart';
import '../constants/end_points.dart';

class ApiClient {
  final http.Client _client;
  final NetworkInfo _networkInfo;
  final String baseUrl;
 
  String? _accessToken;
 
  ApiClient({
    required http.Client client,
    required NetworkInfo networkInfo,
  })  : _client = client,
        _networkInfo = networkInfo,
        baseUrl = EndPoints.baseUrl;
 
  void setAccessToken(String token) => _accessToken = token;
 
  void clearAccessToken() => _accessToken = null;
 
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };
 
  // ── GET ────────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> get(String endpoint) async {
    await _checkConnection();
    final response = await _client.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }
 
  // ── POST ───────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    await _checkConnection();
    final response = await _client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: requiresAuth ? _headers : {'Content-Type': 'application/json'},
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }
 
  // ── POST void (no response body needed) ───────────────────────────────────
  Future<void> postVoid(
    String endpoint, {
    bool requiresAuth = false,
  }) async {
    await _checkConnection();
    final response = await _client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: requiresAuth ? _headers : {'Content-Type': 'application/json'},
    );
    _handleVoidResponse(response);
  }
 
  // ── DELETE ──────────────────────r───────────────────────────────────────────
  Future<void> delete(String endpoint) async {
    await _checkConnection();
    final response = await _client.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    _handleVoidResponse(response);
  }
 
  // ── Helpers ────────────────────────────────────────────────────────────────
  Future<void> _checkConnection() async {
    if (!await _networkInfo.isConnected) {
      throw const NetworkFailure(message: 'No internet connection');
    }
  }
 
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    if (response.statusCode == 401) {
      throw const UnauthorizedFailure(
          message: 'Session expired. Please log in again.');
    }
    throw ServerFailure(message: _parseError(response));
  }
 
  void _handleVoidResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 204) return;
    if (response.statusCode == 401) {
      throw const UnauthorizedFailure(
          message: 'Session expired. Please log in again.');
    }
    throw ServerFailure(message: _parseError(response));
  }
 
  String _parseError(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['message'] as String? ??
          body['error'] as String? ??
          'Unknown server error';
    } catch (_) {
      return 'Server error ${response.statusCode}';
    }
  }
}
 