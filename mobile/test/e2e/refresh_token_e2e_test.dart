// Live end-to-end test of the mobile refresh-token logic against the running
// backend. Exercises the REAL auto-refresh path (ApiClient._doRefreshToken),
// not just the explicit AuthRepository.refreshToken() path.
//
// Prereq: backend running at BASE_URL (default http://localhost:8000) with
// seeded data (alice@example.com / Alice123!).
//
// NOTE: the access-token JWT payload is only {session_id, exp} with second
// granularity, so two access tokens minted for the same session inside the
// same second are byte-identical. These tests therefore assert on the refresh
// token, the refresh call count and the in-memory token — never on
// "the access token changed".
//
// Run:
//   flutter test test/e2e/refresh_token_e2e_test.dart \
//     --dart-define=E2E_ENABLED=true \
//     --dart-define=BASE_URL=http://localhost:8000
import 'package:flutter_test/flutter_test.dart';
import 'package:multai_mobile/core/constants/storage_keys.dart';

import 'helpers/e2e_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadE2EConfig);

  if (!e2eEnabled) {
    test(
      'refresh token live backend E2E (skipped)',
      () {},
      skip: 'Pass --dart-define=E2E_ENABLED=true to run live backend E2E',
    );
    return;
  }

  // One login for the whole file: the backend rate-limits login to 5/60s, so
  // tests share a single real session instead of re-authenticating.
  const deviceId = '99999999-aaaa-bbbb-cccc-0000000000f1';

  late E2EStack stack;

  setUp(allowRealNetwork);

  setUpAll(() async {
    stack = buildStack();
    await loginAs(
      stack,
      'alice@example.com',
      'Alice123!',
      deviceId: deviceId,
      deviceName: 'E2E Refresh Runner',
    );
  });

  setUp(() {
    stack.unauthorizedFired = false;
    stack.apiClient.onUnauthorized = () => stack.unauthorizedFired = true;
  });

  test('1) login persists access + refresh and seeds the in-memory token',
      () async {
    final access = stack.storage.secure[StorageKeys.accessToken];
    final refresh = stack.storage.secure[StorageKeys.refreshToken];
    expect(access, isNotNull, reason: 'login must persist an access token');
    expect(access, isNotEmpty);
    expect(refresh, isNotNull, reason: 'login must persist a refresh token');
    expect(refresh, isNotEmpty);
    expect(stack.apiClient.currentAccessToken, access,
        reason: 'in-memory access token must be set on login');
  });

  test('2) a fresh client hydrates the stored access token (no wasted 401)',
      () async {
    // New ApiClient over the SAME storage: simulates a cold start where a
    // valid access token is already persisted. The first authed call must use
    // it directly — no 401, no refresh.
    final coldStack = buildStack(storage: stack.storage);

    final list = await coldStack.events.getUserEvents();
    expect(list, isNotEmpty, reason: 'authed call must succeed');
    expect(coldStack.client.refreshCalls, 0,
        reason: 'a valid stored access token must be reused, not refreshed');
    expect(coldStack.apiClient.currentAccessToken, stack.accessToken);
  });

  test('3) an expired access token triggers auto-refresh and rotates the '
      'refresh token', () async {
    // Simulate expiry: poison the in-memory access token so the next authed
    // call 401s.
    stack.apiClient.setAccessToken('expired.access.token');
    final oldRefresh = stack.refreshToken;
    final before = stack.client.refreshCalls;

    final list = await stack.events.getUserEvents();
    expect(list, isNotEmpty, reason: 'authed call must succeed after refresh');
    expect(stack.client.refreshCalls, before + 1,
        reason: 'exactly one refresh expected');

    expect(stack.refreshToken, isNot(oldRefresh),
        reason: 'refresh token must rotate');
    expect(stack.apiClient.currentAccessToken, isNot('expired.access.token'),
        reason: 'in-memory token must be replaced after refresh');
    expect(stack.unauthorizedFired, isFalse,
        reason: 'a successful refresh must not trigger logout');
  });

  test('4) a burst of concurrent 401s dedupes into a SINGLE refresh', () async {
    stack.apiClient.setAccessToken('expired.access.token');
    final before = stack.client.refreshCalls;

    final results = await Future.wait([
      stack.events.getUserEvents(),
      stack.events.getUserEvents(),
      stack.events.getUserEvents(),
      stack.events.getUserEvents(),
      stack.events.getUserEvents(),
    ]);

    for (final r in results) {
      expect(r, isNotEmpty);
    }
    expect(stack.client.refreshCalls, before + 1,
        reason: 'concurrent requests must share one refresh (dedupe)');
    expect(stack.unauthorizedFired, isFalse);
  });

  test('5) rotating again works and dedupe resets between expiries', () async {
    final before = stack.client.refreshCalls;

    // First expiry -> refresh #1
    stack.apiClient.setAccessToken('expired.access.token');
    await stack.events.getUserEvents();
    final refreshAfterFirst = stack.refreshToken;

    // Second expiry -> refresh #2 (proves the dedupe state resets)
    stack.apiClient.setAccessToken('expired.access.token');
    await stack.events.getUserEvents();
    final refreshAfterSecond = stack.refreshToken;

    expect(stack.client.refreshCalls, before + 2,
        reason: 'each new expiry must trigger a new refresh');
    expect(refreshAfterSecond, isNot(refreshAfterFirst),
        reason: 'each refresh must rotate the refresh token');
  });

  test('6) reuse of a just-used refresh token replays the same rotation '
      '(idempotent within the grace window)', () async {
    final originalRefresh = stack.refreshToken;

    // Use it once via the real auto-refresh path.
    stack.apiClient.setAccessToken('expired.access.token');
    await stack.events.getUserEvents();
    final rotated = stack.refreshToken;
    expect(rotated, isNot(originalRefresh));

    // Present the now-used original token again (well inside the 30s grace
    // window). The backend must replay the cached rotation, returning the
    // SAME new refresh token rather than minting yet another one.
    final replay = await stack.repo.refreshToken(originalRefresh!);
    replay.fold(
      (f) => fail('grace-window replay should succeed, got: $f'),
      (auth) {
        expect(auth.refreshToken, rotated,
            reason: 'replay must return the previously issued token');
        expect(auth.accessToken, isNotEmpty);
      },
    );
    expect(stack.refreshToken, rotated,
        reason: 'replay must not advance the stored refresh token');
  });

  test('7) an unknown refresh token fails auth and fires onUnauthorized',
      () async {
    // Self-contained: no login, just a bogus refresh token. The client sends
    // the request without a valid access token, gets a 401, tries to refresh
    // with the bogus token, fails, and must force a logout.
    final bogusStorage = MemStorage()
      ..secure[StorageKeys.refreshToken] = 'not-a-real-refresh-token';
    final bogusStack = buildStack(storage: bogusStorage);
    var fired = false;
    bogusStack.apiClient.onUnauthorized = () => fired = true;

    final result = await bogusStack.repo.getMe();
    expect(result.isLeft(), isTrue, reason: 'bogus refresh must fail');
    expect(fired, isTrue,
        reason: 'refresh failure must notify onUnauthorized (force logout)');
    bogusStack.client.close();
  });

  test('8) after logout, authenticated calls are rejected', () async {
    final logout = await stack.repo.logout();
    expect(logout.isRight(), isTrue);
    expect(stack.storage.secure[StorageKeys.accessToken], isNull);
    expect(stack.storage.secure[StorageKeys.refreshToken], isNull);
    expect(stack.apiClient.currentAccessToken, isNull);

    final result = await stack.repo.getMe();
    expect(result.isLeft(), isTrue, reason: 'no session left, getMe must fail');
  });
}
