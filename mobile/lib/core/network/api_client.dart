import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../errors/failure.dart';
import 'network_info.dart';
import '../constants/end_points.dart';
import '../constants/storage_keys.dart';
import '../storage/app_local_storage.dart';

class ApiClient {
  final http.Client _client;
  final NetworkInfo _networkInfo;
  final LocalStorage? _localStorage;

  String? _accessToken;
  void Function()? onUnauthorized;

  ApiClient({
    http.Client? client,
    required NetworkInfo networkInfo,
    LocalStorage? localStorage,
  }) : _client = client ?? http.Client(),
       _networkInfo = networkInfo,
       _localStorage = localStorage;

  String get baseUrl => EndPoints.baseUrl;

  void setAccessToken(String token) => _accessToken = token;
  void clearAccessToken() => _accessToken = null;

  String? get currentAccessToken => _accessToken;

  Future<Map<String, String>> _getHeaders({
    bool requiresAuth = false,
    String? accessToken,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final token = accessToken ?? _accessToken;
    if (token != null && requiresAuth) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final info = await PackageInfo.fromPlatform();
      headers['X-App-Version'] = '${info.version}+${info.buildNumber}';
    } catch (_) {}

    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        headers['X-Device-Info'] = '${androidInfo.brand}/${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        headers['X-Device-Info'] = '${iosInfo.name}/${iosInfo.model}';
      }
    } catch (_) {}

    return headers;
  }

  static const _requestTimeout = Duration(seconds: 30);

  Future<void> checkConnection() async {
    if (!await _networkInfo.isConnected) {
      throw const NetworkFailure();
    }
  }

  Future<bool> _hasValidCredentials() async {
    if (_accessToken != null) return true;
    final storage = _localStorage;
    if (storage == null) return false;
    // Hydrate the in-memory access token from secure storage on first use so a
    // cold start can go straight to an authenticated request instead of
    // forcing a guaranteed 401 -> refresh round-trip on every launch.
    final access = await storage.getSecureString(StorageKeys.accessToken);
    if (access != null && access.isNotEmpty) {
      _accessToken = access;
      return true;
    }
    final refreshToken = await storage.getSecureString(
      StorageKeys.refreshToken,
    );
    return refreshToken != null && refreshToken.isNotEmpty;
  }

  Future<dynamic> get(String endpoint, {bool requiresAuth = true}) async {
    if (requiresAuth && !await _hasValidCredentials()) {
      throw const UnauthorizedFailure('No access token');
    }
    return _executeWithAuth(() async {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      return _client.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
    });
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    if (requiresAuth && !await _hasValidCredentials()) {
      throw const UnauthorizedFailure('No access token');
    }
    final requestBody = body != null ? jsonEncode(body) : null;
    return _executeWithAuth(() async {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      return _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: requestBody,
      );
    });
  }

  Future<dynamic> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    if (requiresAuth && !await _hasValidCredentials()) {
      throw const UnauthorizedFailure('No access token');
    }
    final requestBody = body != null ? jsonEncode(body) : null;
    return _executeWithAuth(() async {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      return _client.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: requestBody,
      );
    });
  }

  Future<void> postVoid(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    if (requiresAuth && !await _hasValidCredentials()) {
      throw const UnauthorizedFailure('No access token');
    }
    final requestBody = body != null ? jsonEncode(body) : null;
    await _executeWithAuthVoid(() async {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      return _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: requestBody,
      );
    });
  }

  /// Fire-and-forget POST authenticated with an explicit token.
  ///
  /// Unlike [postVoid] it never refreshes tokens or reports unauthorized: it
  /// is meant for best-effort server cleanup (e.g. revoking a session during
  /// sign-out) after the local credentials have already been cleared.
  Future<void> postVoidDetached(
    String endpoint, {
    required String accessToken,
  }) async {
    final headers = await _getHeaders(
      requiresAuth: true,
      accessToken: accessToken,
    );
    await _client
        .post(Uri.parse('$baseUrl$endpoint'), headers: headers)
        .timeout(_requestTimeout);
  }

  Future<void> delete(String endpoint, {bool requiresAuth = true}) async {
    if (requiresAuth && !await _hasValidCredentials()) {
      throw const UnauthorizedFailure('No access token');
    }
    await _executeWithAuthVoid(() async {
      final headers = await _getHeaders(requiresAuth: requiresAuth);
      return _client.delete(Uri.parse('$baseUrl$endpoint'), headers: headers);
    });
  }

  void _handleVoidResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 204) return;
    _throwForStatus(response);
  }

  Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    required List<File> files,
    required List<String> fieldNames,
    bool requiresAuth = false,
  }) async {
    // Goes through _executeWithAuthRaw so an expired access token triggers the
    // usual refresh-and-retry instead of failing the upload outright.
    final response = await _executeWithAuthRaw(
      () => _sendMultipart(
        endpoint,
        files: files,
        fieldNames: fieldNames,
        requiresAuth: requiresAuth,
      ),
    );
    return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  }

  /// Builds a FRESH multipart request on every invocation: an
  /// [http.MultipartRequest] cannot be sent twice, and the auth wrapper may
  /// retry after refreshing the access token.
  Future<http.Response> _sendMultipart(
    String endpoint, {
    required List<File> files,
    required List<String> fieldNames,
    required bool requiresAuth,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', uri);

    if (_accessToken != null && requiresAuth) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }

    try {
      final info = await PackageInfo.fromPlatform();
      request.headers['X-App-Version'] = '${info.version}+${info.buildNumber}';
    } catch (_) {}

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
      final ext = file.path.split('.').last.toLowerCase();

      request.files.add(
        http.MultipartFile(
          fieldNames[i],
          stream,
          length,
          filename: file.path.split('/').last,
          contentType: MediaType('image', _mimeTypeFromExtension(ext)),
        ),
      );
    }

    final streamedResponse = await request.send().timeout(_requestTimeout);
    return http.Response.fromStream(streamedResponse);
  }

  String _mimeTypeFromExtension(String ext) {
    switch (ext) {
      case 'png':
        return 'png';
      case 'heic':
      case 'heif':
        return 'heic';
      case 'webp':
        return 'webp';
      default:
        return 'jpeg';
    }
  }

  Future<Uint8List> getBytes(String url) async {
    if (!await _hasValidCredentials()) {
      throw const UnauthorizedFailure('No access token');
    }
    final response = await _executeWithAuthRaw(() async {
      final headers = await _getHeaders(requiresAuth: true);
      return _client.get(Uri.parse('$baseUrl$url'), headers: headers);
    });
    if (response.statusCode == 200) return response.bodyBytes;
    throw ServerFailure(
      'Failed to fetch bytes: ${response.statusCode}',
      response.statusCode,
    );
  }

  Future<dynamic> _executeWithAuth(
    Future<http.Response> Function() request,
  ) async {
    await checkConnection();
    final tokenUsed = _accessToken;
    try {
      final response = await request().timeout(_requestTimeout);
      return _handleResponse(response);
    } on UnauthorizedFailure {
      final response = await _recoverFromUnauthorized(tokenUsed, request);
      return _handleResponse(response);
    } on TimeoutException {
      throw const NetworkFailure('Request timed out');
    }
  }

  Future<void> _executeWithAuthVoid(
    Future<http.Response> Function() request,
  ) async {
    await checkConnection();
    final tokenUsed = _accessToken;
    try {
      final response = await request().timeout(_requestTimeout);
      _handleVoidResponse(response);
    } on UnauthorizedFailure {
      final response = await _recoverFromUnauthorized(tokenUsed, request);
      _handleVoidResponse(response);
    } on TimeoutException {
      throw const NetworkFailure('Request timed out');
    }
  }

  Future<http.Response> _executeWithAuthRaw(
    Future<http.Response> Function() request,
  ) async {
    await checkConnection();
    final tokenUsed = _accessToken;
    try {
      final response = await request().timeout(_requestTimeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }
      _throwForStatus(response);
    } on UnauthorizedFailure {
      final response = await _recoverFromUnauthorized(tokenUsed, request);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }
      _throwForStatus(response);
    } on TimeoutException {
      throw const NetworkFailure('Request timed out');
    }
  }

  /// Recovers from a 401.
  ///
  /// If another in-flight request already rotated the access token while this
  /// one was in flight, we simply retry with the new token instead of
  /// refreshing again. This keeps a burst of concurrent 401s down to a single
  /// refresh (the first refresh wins; later 401s see a changed token).
  ///
  /// Otherwise we refresh once and retry. On failure we notify
  /// [onUnauthorized] and rethrow so callers can surface a session-expired
  /// error.
  Future<http.Response> _recoverFromUnauthorized(
    String? tokenUsed,
    Future<http.Response> Function() request,
  ) async {
    final tokenAlreadyRotated =
        _accessToken != null && _accessToken != tokenUsed;
    if (!tokenAlreadyRotated && !await _tryRefreshToken()) {
      onUnauthorized?.call();
      throw const UnauthorizedFailure('Session expired. Please log in again.');
    }
    return request().timeout(_requestTimeout);
  }

  Future<bool>? _refreshInFlight;

  Future<bool> _tryRefreshToken() {
    return _refreshInFlight ??= _doRefreshToken().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<bool> _doRefreshToken() async {
    final storage = _localStorage;
    if (storage == null) return false;
    try {
      final refreshToken = await storage.getSecureString(
        StorageKeys.refreshToken,
      );
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final response = await _client
          .post(
            Uri.parse('$baseUrl${EndPoints.refresh}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccessToken = json['access_token'] as String?;
        final newRefreshToken = json['refresh_token'] as String?;
        if (newAccessToken != null) {
          _accessToken = newAccessToken;
          await storage.setSecureString(
            StorageKeys.accessToken,
            newAccessToken,
          );
        }
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await storage.setSecureString(
            StorageKeys.refreshToken,
            newRefreshToken,
          );
        }
        return newAccessToken != null;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    _throwForStatus(response);
  }

  Never _throwForStatus(http.Response response) {
    switch (response.statusCode) {
      case 400:
      case 422:
        throw ServerFailure(_parseError(response), response.statusCode);
      case 401:
        throw const UnauthorizedFailure(
          'Session expired. Please log in again.',
        );
      case 403:
        throw const ServerFailure('Access denied.');
      case 404:
        throw NotFoundFailure(_parseError(response));
      case 429:
        throw const RateLimitFailure('Too many attempts. Try again later.');
      case 500:
        throw ServerFailure(_parseError(response), response.statusCode);
      default:
        throw ServerFailure(_parseError(response), response.statusCode);
    }
  }

  String _parseError(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        if (body['message'] != null) return body['message'] as String;
        if (body['error'] != null) return body['error'] as String;
        if (body['detail'] != null) {
          final detail = body['detail'];
          if (detail is String) return detail;
          if (detail is List && detail.isNotEmpty) {
            final first = detail[0];
            if (first is Map<String, dynamic>) {
              return first['msg'] as String? ?? 'Unknown server error';
            }
          }
        }
      }
      return 'Unknown server error';
    } catch (_) {
      return 'Server error ${response.statusCode}';
    }
  }
}
