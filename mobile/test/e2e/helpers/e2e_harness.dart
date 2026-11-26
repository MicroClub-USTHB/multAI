// Shared helpers for the live-backend E2E suites.
//
// These tests drive the REAL ApiClient / repositories against the backend at
// BASE_URL. flutter_test installs an HttpOverrides that answers every request
// with a 400, so [E2E] disables it before any network call.
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:multai_mobile/core/constants/storage_keys.dart';
import 'package:multai_mobile/core/network/api_client.dart';
import 'package:multai_mobile/core/network/network_info.dart';
import 'package:multai_mobile/core/storage/app_local_storage.dart';
import 'package:multai_mobile/features/account/data/datasources/account_remote_datasource.dart';
import 'package:multai_mobile/features/auth/data/datasource/auth_local_datasource.dart';
import 'package:multai_mobile/features/auth/data/datasource/remote_data.dart';
import 'package:multai_mobile/features/auth/data/models/me_model.dart';
import 'package:multai_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:multai_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:multai_mobile/features/events/data/datasources/events_remote_datasource.dart';
import 'package:multai_mobile/features/notifications/data/datasources/notifications_remote_datasource.dart';

const String e2eBaseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'http://localhost:8000',
);

const bool e2eEnabled = bool.fromEnvironment('E2E_ENABLED');

/// Backend dev bypass OTP (settings.DEV_OTP_BYPASS_CODE).
const String e2eDevOtp = '000000';

/// Loads BASE_URL into dotenv AND disables the HttpOverrides flutter_test
/// installs (which answers every request with a 400).
///
/// Must be called from `setUpAll` before any login: `setUpAll` runs before the
/// first `setUp`, so disabling the override in `setUp` alone leaves the
/// network mocked for the login itself.
void loadE2EConfig() {
  dotenv.loadFromString(envString: 'BASE_URL=$e2eBaseUrl\n');
  allowRealNetwork();
}

/// Disables the HttpOverrides flutter_test installs so real sockets work.
void allowRealNetwork() {
  HttpOverrides.global = null;
}

class AlwaysOnNetworkInfo implements NetworkInfo {
  const AlwaysOnNetworkInfo();

  @override
  Future<bool> get isConnected async => true;

  @override
  Stream<bool> get onConnectivityChanged => const Stream.empty();
}

class MemStorage implements LocalStorage {
  final Map<String, String> secure = {};
  final Map<String, bool> bools = {};
  final Map<String, String> strings = {};

  @override
  Future<void> setBool(String key, bool value) async => bools[key] = value;
  @override
  bool? getBool(String key) => bools[key];
  @override
  Future<void> setString(String key, String value) async =>
      strings[key] = value;
  @override
  String? getString(String key) => strings[key];
  @override
  Future<void> setSecureString(String key, String value) async =>
      secure[key] = value;
  @override
  Future<String?> getSecureString(String key) async => secure[key];
  @override
  Future<void> remove(String key) async => strings.remove(key);
  @override
  Future<void> removeSecure(String key) async => secure.remove(key);
}

class MemAuthLocalDataSource implements AuthLocalDataSource {
  MeResponseModel? me;

  @override
  Future<void> cacheMe(MeResponseModel me) async => this.me = me;
  @override
  Future<MeResponseModel?> getCachedMe() async => me;
  @override
  Future<void> clearCachedMe() async => me = null;
}

/// Counts requests, so tests can assert how many times the client refreshed.
class CountingClient extends http.BaseClient {
  CountingClient(this._inner);

  final http.Client _inner;
  int refreshCalls = 0;
  int totalCalls = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    totalCalls++;
    if (request.url.path.contains('/user/auth/refresh')) {
      refreshCalls++;
    }
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}

/// A fully wired slice of the app's data layer (real ApiClient, real
/// repositories/data sources, in-memory storage).
class E2EStack {
  E2EStack({
    required this.storage,
    required this.client,
    required this.apiClient,
    required this.repo,
    required this.events,
    required this.account,
    required this.notifications,
  });

  final MemStorage storage;
  final CountingClient client;
  final ApiClient apiClient;
  final AuthRepositoryImpl repo;
  final EventsRemoteDataSource events;
  final AccountRemoteDataSource account;
  final NotificationRemoteDataSource notifications;

  bool unauthorizedFired = false;
  set onUnauthorized(void Function() cb) => apiClient.onUnauthorized = cb;

  String? get accessToken => storage.secure[StorageKeys.accessToken];
  String? get refreshToken => storage.secure[StorageKeys.refreshToken];
}

E2EStack buildStack({MemStorage? storage, CountingClient? client}) {
  final s = storage ?? MemStorage();
  final c = client ?? CountingClient(http.Client());
  final apiClient = ApiClient(
    networkInfo: const AlwaysOnNetworkInfo(),
    localStorage: s,
    client: c,
  );
  final repo = AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSourceImpl(apiClient: apiClient),
    apiClient: apiClient,
    localStorage: s,
    localDataSource: MemAuthLocalDataSource(),
  );
  final stack = E2EStack(
    storage: s,
    client: c,
    apiClient: apiClient,
    repo: repo,
    events: EventsRemoteDataSourceImpl(apiClient: apiClient),
    account: AccountRemoteDataSourceImpl(apiClient: apiClient),
    notifications: NotificationRemoteDataSourceImpl(apiClient: apiClient),
  );
  apiClient.onUnauthorized = () => stack.unauthorizedFired = true;
  return stack;
}

/// Log in as [email] on [stack] and fail the test if the backend rejects it.
Future<void> loginAs(
  E2EStack stack,
  String email,
  String password, {
  required String deviceId,
  String deviceName = 'E2E Runner',
  String deviceType = 'linux',
}) async {
  final result = await stack.repo.login(
    LoginParams(
      email: email,
      password: password,
      deviceName: deviceName,
      deviceType: deviceType,
      deviceId: deviceId,
    ),
  );
  result.fold((f) => fail('login failed for $email: $f'), (_) {});
}

LoginParams loginParamsFor(
  String email, {
  required String deviceId,
  String password = 'Str0ngPass!23',
  String deviceName = 'E2E Runner',
  String deviceType = 'linux',
}) {
  return LoginParams(
    email: email,
    password: password,
    deviceName: deviceName,
    deviceType: deviceType,
    deviceId: deviceId,
  );
}

/// Unique-per-run email so registrations never collide with a previous run.
String uniqueEmail([String prefix = 'e2e']) =>
    '$prefix+${DateTime.now().microsecondsSinceEpoch}@example.com';
