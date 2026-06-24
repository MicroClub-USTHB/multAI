// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() async {
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('Mock backend running on http://localhost:8080');
  print('Endpoints:');
  print('  POST /user/auth/register');
  print('  POST /user/auth/register/verify');
  print('  POST /user/auth/login');
  print('');

  await for (final request in server) {
    handleRequest(request);
  }
}

void handleRequest(HttpRequest request) {
  final path = request.uri.path;
  final method = request.method;

  if (method == 'OPTIONS') {
    request.response.headers.set('Access-Control-Allow-Origin', '*');
    request.response.headers.set('Access-Control-Allow-Methods', 'POST, GET, OPTIONS');
    request.response.headers.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    request.response.statusCode = 204;
    request.response.close();
    return;
  }

  print('${request.method} $path');

  if (method == 'POST' && path == '/user/auth/register') {
    handleRegister(request);
  } else if (method == 'POST' && path == '/user/auth/register/verify') {
    handleVerifyRegister(request);
  } else if (method == 'POST' && path == '/user/auth/login') {
    handleLogin(request);
  } else {
    request.response.statusCode = 404;
    request.response.headers.set('Content-Type', 'application/json');
    request.response.write(jsonEncode({'detail': 'Not found'}));
    request.response.close();
  }
}

Future<void> handleRegister(HttpRequest request) async {
  final body = jsonDecode(await utf8.decodeStream(request));
  print('  Body: ${jsonEncode(body)}');

  final response = {
    'message': 'OTP sent to email',
    'status': 'pending_verification',
    'email': body['email'],
  };

  request.response.statusCode = 200;
  request.response.headers.set('Content-Type', 'application/json');
  request.response.write(jsonEncode(response));
  request.response.close();
}

Future<void> handleVerifyRegister(HttpRequest request) async {
  final body = jsonDecode(await utf8.decodeStream(request));
  print('  Body: ${jsonEncode(body)}');

  final otp = body['otp'] as String;
  if (otp != '123456') {
    request.response.statusCode = 401;
    request.response.headers.set('Content-Type', 'application/json');
    request.response.write(jsonEncode({'detail': 'Invalid or expired OTP'}));
    request.response.close();
    return;
  }

  final response = {
    'access_token': 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
    'refresh_token': 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
    'session_id': 'mock_session_id_${DateTime.now().millisecondsSinceEpoch}',
    'expires_in': 3600,
    'user_id': 'mock_user_id_${DateTime.now().millisecondsSinceEpoch}',
    'is_new_user': true,
  };

  request.response.statusCode = 200;
  request.response.headers.set('Content-Type', 'application/json');
  request.response.write(jsonEncode(response));
  request.response.close();
}

Future<void> handleLogin(HttpRequest request) async {
  final body = jsonDecode(await utf8.decodeStream(request));
  print('  Body: ${jsonEncode(body)}');

  final response = {
    'access_token': 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}',
    'refresh_token': 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
    'session_id': 'mock_session_id_${DateTime.now().millisecondsSinceEpoch}',
    'expires_in': 3600,
    'user_id': 'mock_user_id_${DateTime.now().millisecondsSinceEpoch}',
    'is_new_user': false,
  };

  request.response.statusCode = 200;
  request.response.headers.set('Content-Type', 'application/json');
  request.response.write(jsonEncode(response));
  request.response.close();
}
