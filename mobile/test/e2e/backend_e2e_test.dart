// Live end-to-end test of the mobile data layer against the running backend.
//
// Prereq: backend running at BASE_URL (default http://localhost:8000) with
// DEV_OTP_BYPASS_CODE=000000 and seeded data (alice@example.com / Alice123!).
//
// Run:
//   flutter test test/e2e/backend_e2e_test.dart \
//     --dart-define=BASE_URL=http://localhost:8000
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multai_mobile/core/constants/storage_keys.dart';
import 'package:multai_mobile/core/network/api_client.dart';
import 'package:multai_mobile/core/network/network_info.dart';
import 'package:multai_mobile/core/storage/app_local_storage.dart';
import 'package:multai_mobile/features/auth/data/datasource/auth_local_datasource.dart';
import 'package:multai_mobile/features/auth/data/datasource/remote_data.dart';
import 'package:multai_mobile/features/auth/data/models/me_model.dart';
import 'package:multai_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:multai_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:multai_mobile/features/events/data/datasources/events_remote_datasource.dart';
import 'package:multai_mobile/features/gallery/data/datasources/photo_remote_datasource.dart';
import 'package:multai_mobile/features/notifications/data/datasources/notifications_remote_datasource.dart';
import 'package:multai_mobile/features/photo_approval/data/datasources/photo_approval_remote_datasource.dart';

const _baseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'http://localhost:8000',
);

// Live-backend E2E is excluded from the default `flutter test` run so the
// unit-test suite never depends on a running server. Enable explicitly with:
//   flutter test test/e2e/backend_e2e_test.dart \
//     --dart-define=E2E_ENABLED=true \
//     --dart-define=BASE_URL=http://localhost:8000
const _e2eEnabled = bool.fromEnvironment('E2E_ENABLED');

class _AlwaysOnNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;

  @override
  Stream<bool> get onConnectivityChanged => const Stream.empty();
}

class _MemStorage implements LocalStorage {
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

class _MemAuthLocalDataSource implements AuthLocalDataSource {
  MeResponseModel? me;

  @override
  Future<void> cacheMe(MeResponseModel me) async => this.me = me;
  @override
  Future<MeResponseModel?> getCachedMe() async => me;
  @override
  Future<void> clearCachedMe() async => me = null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    dotenv.loadFromString(envString: 'BASE_URL=$_baseUrl\n');
  });

  if (!_e2eEnabled) {
    // Skip the live-backend E2E during the default unit-test suite.
    test(
      'live backend E2E (skipped)',
      () {},
      skip: 'Pass --dart-define=E2E_ENABLED=true to run live backend E2E',
    );
    return;
  }

  late _MemStorage storage;
  late _MemAuthLocalDataSource authLocal;
  late ApiClient apiClient;
  late AuthRepositoryImpl repo;

  final deviceId = '99999999-aaaa-bbbb-cccc-000000000001';
  const deviceName = 'E2E Runner';
  const deviceType = 'linux';

  setUpAll(() {
    // flutter_test installs an HttpOverrides that returns 400 for every
    // request. E2E tests need real network access, so disable it.
    HttpOverrides.global = null;
  });

  setUp(() {
    HttpOverrides.global = null;
    storage = _MemStorage();
    authLocal = _MemAuthLocalDataSource();
    apiClient = ApiClient(
      networkInfo: _AlwaysOnNetworkInfo(),
      localStorage: storage,
    );
    repo = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(apiClient: apiClient),
      apiClient: apiClient,
      localStorage: storage,
      localDataSource: authLocal,
    );
  });

  test('AUTH: register -> resend -> verify -> me -> refresh -> logout', () async {
    final email = 'e2e+${DateTime.now().millisecondsSinceEpoch}@example.com';
    final params = LoginParams(
      email: email,
      password: 'Str0ngPass!23',
      deviceName: deviceName,
      deviceType: deviceType,
      deviceId: deviceId,
    );

    final registerResult = await repo.register(params);
    registerResult.fold(
      (f) => fail('REGISTER failed against backend: $f'),
      (identifier) {
        expect(identifier, isNotEmpty, reason: 'register returned empty id');
        expect(identifier, contains('@'), reason: 'expected email identity');
      },
    );

    await Future.delayed(const Duration(milliseconds: 200));

    final resend = await repo.resendOtp(email);
    expect(resend.isRight(), isTrue, reason: 'resend failed: $resend');

    final verify = await repo.verifyRegister(params, '000000');
    expect(verify.isRight(), isTrue, reason: 'verify failed: $verify');

    final me = await repo.getMe();
    expect(me.isRight(), isTrue, reason: 'me failed: $me');

    final refreshTokenValue = storage.secure[StorageKeys.refreshToken];
    expect(
      refreshTokenValue,
      isNotNull,
      reason: 'verify should have persisted a refresh token',
    );
    final refresh = await repo.refreshToken(refreshTokenValue!);
    expect(refresh.isRight(), isTrue, reason: 'refresh failed: $refresh');

    final logout = await repo.logout();
    expect(logout.isRight(), isTrue, reason: 'logout failed: $logout');
  });

  group('SEEDED USER (alice): real data parsing', () {
    late ApiClient aliceClient;

    setUpAll(() async {
      aliceClient = ApiClient(
        networkInfo: _AlwaysOnNetworkInfo(),
        localStorage: _MemStorage(),
      );
      final aliceRepo = AuthRepositoryImpl(
        remoteDataSource: AuthRemoteDataSourceImpl(apiClient: aliceClient),
        apiClient: aliceClient,
        localStorage: _MemStorage(),
        localDataSource: _MemAuthLocalDataSource(),
      );
      final login = await aliceRepo.login(
        const LoginParams(
          email: 'alice@example.com',
          password: 'Alice123!',
          deviceName: deviceName,
          deviceType: deviceType,
          deviceId: '99999999-aaaa-bbbb-cccc-000000000002',
        ),
      );
      login.fold((f) => fail('alice login failed: $f'), (_) {});
    });

    test('EVENTS: /user/event/me parses', () async {
      final events = EventsRemoteDataSourceImpl(apiClient: aliceClient);
      final list = await events.getUserEvents();
      expect(list, isNotEmpty, reason: 'seeded alice should have events');
      for (final e in list) {
        expect(e.id, isNotEmpty);
        expect(e.name, isNotEmpty);
      }
    });

    test('GALLERY: /user/photos parses', () async {
      final photos = PhotoRemoteDataSourceImpl(apiClient: aliceClient);
      final list = await photos.getMyPhotos(limit: 10, offset: 0);
      expect(list, isNotEmpty, reason: 'seeded alice should have photos');
      for (final p in list) {
        expect(p.id, isNotEmpty);
      }
    });

    test('APPROVALS: /user/photos/approvals parses', () async {
      final approvals = PhotoApprovalRemoteDataSourceImpl(apiClient: aliceClient);
      final list = await approvals.getApprovals(limit: 10, offset: 0);
      expect(list, isNotEmpty, reason: 'seeded alice should have approvals');
    });

    test('NOTIFICATIONS: /user/notifications parses', () async {
      final notifications = NotificationRemoteDataSourceImpl(
        apiClient: aliceClient,
      );
      final list = await notifications.getNotifications();
      expect(list, isNotEmpty, reason: 'seeded alice should have notifications');
    });
  });
}
