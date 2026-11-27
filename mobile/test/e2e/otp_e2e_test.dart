// Live E2E test of the mobile OTP / registration flow against the backend.
//
// Prereq: backend at BASE_URL running with DEV_OTP_BYPASS_CODE=000000.
//
// NOTE ON RATE LIMITS: register and resend-otp share one IP-scoped budget of
// 5 requests / 60s (settings.RATE_LIMIT_LOGIN_MAX_ATTEMPTS, keyed rate:ip:...).
// This file is deliberately budgeted to stay within that limit: the "wrong
// OTP", "replay" and "verify without register" cases only hit /register/verify,
// which has no service-level IP counter.
//
// Run:
//   flutter test test/e2e/otp_e2e_test.dart \
//     --dart-define=E2E_ENABLED=true --dart-define=BASE_URL=http://localhost:8000
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:multai_mobile/core/errors/app_exception.dart';
import 'package:multai_mobile/core/errors/failure.dart';

import 'helpers/e2e_harness.dart';

/// Retries [op] until it returns a Right, up to ~2s.
///
/// Works around the backend's post-response commit race on first
/// read-after-write. See the comment in test 1.
Future<Either<Failure, T>> _eventually<T>(
  Future<Either<Failure, T>> Function() op,
) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    final result = await op();
    if (result.isRight()) return result;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  return op();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadE2EConfig);

  if (!e2eEnabled) {
    test(
      'OTP live backend E2E (skipped)',
      () {},
      skip: 'Pass --dart-define=E2E_ENABLED=true to run live backend E2E',
    );
    return;
  }

  setUp(allowRealNetwork);

  late E2EStack stack;
  // Must be a valid UUID: the backend types `physical_device_id` as UUID and
  // rejects anything else with a 422.
  const device = '99999999-aaaa-bbbb-cccc-0000000000b1';

  setUpAll(() {
    stack = buildStack();
  });

  test('1) register -> resend -> verify(000000) creates a real session',
      () async {
    final email = uniqueEmail('otp-ok');
    final params = loginParamsFor(email, deviceId: device);

    final register = await stack.repo.register(params);
    register.fold(
      (f) => fail('register failed: $f'),
      (pendingToken) {
        // The repository surfaces the registration identity as the "pending
        // token"; the backend returns the normalized email.
        expect(pendingToken, email,
            reason: 'register must return the registered email identity');
      },
    );

    final resend = await stack.repo.resendOtp(email);
    expect(resend.isRight(), isTrue, reason: 'resend failed: $resend');

    final verify = await stack.repo.verifyRegister(params, e2eDevOtp);
    verify.fold(
      (f) => fail('verify with dev OTP failed: $f'),
      (auth) {
        expect(auth.accessToken, isNotEmpty);
        expect(auth.refreshToken, isNotEmpty);
        expect(auth.userId, isNotEmpty);
      },
    );

    expect(stack.accessToken, isNotNull,
        reason: 'verify must persist an access token');
    expect(stack.refreshToken, isNotNull,
        reason: 'verify must persist a refresh token');

    // The brand-new user must be usable immediately.
    //
    // KNOWN BACKEND BUG (multAI-back): `get_db()` yields a connection inside
    // `engine.begin()`, and on FastAPI >= 0.106 that transaction is committed
    // only AFTER the response is sent. So the client receives its tokens
    // before the user row is visible, and the very first read-after-write
    // races the commit (measured: 404 at +21ms, 200 by +81ms).
    //
    // We therefore poll rather than assert a single shot: the invariant under
    // test is "verify creates a usable account", not "the commit is atomic".
    final me = await _eventually(() => stack.repo.getMe());
    expect(me.isRight(), isTrue,
        reason: 'getMe after verify must succeed: $me');
  });

  test('2) wrong OTP is rejected WITHOUT consuming the pending OTP; '
      'correct OTP then works; replaying it afterwards is rejected', () async {
    final email = uniqueEmail('otp-bad');
    final params = loginParamsFor(email, deviceId: device);
    await stack.repo.register(params);

    final wrong = await stack.repo.verifyRegister(params, '999999');
    expect(wrong.isLeft(), isTrue,
        reason: 'a wrong OTP must be rejected by the backend');
    // Assert on the TYPE, not the message: /register/verify answers a wrong
    // OTP with 401, and ApiClient._throwForStatus flattens every 401 into
    // UnauthorizedFailure('Session expired. Please log in again.'). See the
    // summary for the user-facing consequence of that.
    wrong.fold(
      (f) => expect(f.appException, isA<AuthenticationException>(),
          reason: 'expected an auth rejection, got: $f'),
      (_) => fail('verify with a wrong OTP must fail'),
    );

    // The wrong attempt must NOT burn the real OTP (no brute-force penalty in
    // the dev contract), so the correct code still works.
    final good = await stack.repo.verifyRegister(params, e2eDevOtp);
    expect(good.isRight(), isTrue,
        reason: 'correct OTP must still work after a failed attempt: $good');

    // Verify deletes the OTP, so an immediate replay must be rejected.
    final replay = await stack.repo.verifyRegister(params, e2eDevOtp);
    expect(replay.isLeft(), isTrue,
        reason: 'OTP must be single-use: a replay must fail');
    replay.fold(
      (f) => expect(
        f.appException,
        isA<AuthenticationException>(),
        reason: 'expected the OTP to be consumed, got: $f',
      ),
      (_) => fail('the OTP must be single-use'),
    );
  });

  test('3) registering an already-used email is rejected', () async {
    final params = loginParamsFor(
      'alice@example.com',
      password: 'Alice123!',
      deviceId: device,
    );
    final result = await stack.repo.register(params);
    expect(result.isLeft(), isTrue,
        reason: 'registering an existing email must conflict');
    // Assert on the message so a stray 422/429 cannot pass this by accident.
    result.fold(
      (f) => expect(
        f.message,
        contains('already in use'),
        reason: 'expected the duplicate-email conflict, got: $f',
      ),
      (_) => fail('register must fail for an existing email'),
    );
  });

  test('4) resend-otp for an email with no pending registration is rejected',
      () async {
    final result = await stack.repo.resendOtp(uniqueEmail('otp-none'));
    expect(result.isLeft(), isTrue,
        reason: 'resend with no pending registration must fail');
    result.fold(
      (f) => expect(
        f.message,
        contains('No pending registration'),
        reason: 'expected the pending-registration error, got: $f',
      ),
      (_) => fail('resend must fail without a pending registration'),
    );
  });

  test('5) verify with no pending registration is rejected', () async {
    final params = loginParamsFor(uniqueEmail('otp-ghost'), deviceId: device);
    final result = await stack.repo.verifyRegister(params, e2eDevOtp);
    expect(result.isLeft(), isTrue,
        reason: 'verify without a preceding register must fail');
    result.fold(
      (f) => expect(
        f.appException,
        isA<AuthenticationException>(),
        reason: 'expected an auth rejection, got: $f',
      ),
      (_) => fail('verify must fail without a preceding register'),
    );
  });
}
