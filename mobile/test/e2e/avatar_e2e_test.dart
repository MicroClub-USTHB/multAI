// Live E2E test of the account avatar flow against the backend.
//
// Covers: upload -> persisted avatar_url -> image bytes are fetchable, and the
// URL handed to the widget layer is ABSOLUTE (CachedNetworkImage cannot load a
// backend-relative path such as "/user/auth/me/avatar/image").
//
// Run:
//   flutter test test/e2e/avatar_e2e_test.dart \
//     --dart-define=E2E_ENABLED=true --dart-define=BASE_URL=http://localhost:8000
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:multai_mobile/core/constants/end_points.dart';

import 'helpers/e2e_harness.dart';

/// A real 128x128 PNG (the backend requires >= MIN_IMAGE_DIM=64 px and a format
/// filetype/PIL can decode, so a synthetic byte blob is not enough).
const String _validPngBase64 =
    'iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAIAAABMXPacAAABYUlEQVR4nO3bwQmDQBBAUddqtpyUYBkp'
    'x3IsIeWkg8BC4Cu8d17n8pmLMGO+r23F+TmW3h/zNP+Hfek1fydATICYADEBYgLEBIgJEBMgJkBMgJgA'
    'MQFiAsQEiI3rNZc+ePr/97vNtwExAWICxASICRATICZATICYADEBYgLEBIgJEBMgJkBsuA9o59uAmAA'
    'xAWICxASICRATICZATICYADEBYgLEBIgJEBMg5j4gnm8DYgLEBIgJEBMgJkBMgJgAMQFiAsQEiAkQEyAm'
    'QEyAmPuAeL4NiAkQEyAmQEyAmAAxAWICxASICRATICZATICYADEBYu4D4vk2ICZATICYADEBYgLEBIgJ'
    'EBMgJkBMgJgAMQFiAsQEiLkPiOfbgJgAMQFiAsQEiAkQEyAmQEyAmAAxAWICxASICRATIOY+IJ5vA2IC'
    'xASICRATICZATICYADEBYgLEBIgJEBMgJkBMgNgXtiFfmfJ0KlYAAAAASUVORK5CYII=';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadE2EConfig);

  if (!e2eEnabled) {
    test(
      'avatar live backend E2E (skipped)',
      () {},
      skip: 'Pass --dart-define=E2E_ENABLED=true to run live backend E2E',
    );
    return;
  }

  setUp(allowRealNetwork);

  late E2EStack stack;
  late Directory tempDir;
  late File validPng;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('e2e_avatar');
    validPng = File('${tempDir.path}/avatar.png');
    await validPng.writeAsBytes(base64Decode(_validPngBase64));

    stack = buildStack();
    await loginAs(
      stack,
      'alice@example.com',
      'Alice123!',
      deviceId: '99999999-aaaa-bbbb-cccc-0000000000a1',
      deviceName: 'E2E Avatar Runner',
    );
  });

  tearDownAll(() async {
    try {
      await tempDir.delete(recursive: true);
    } catch (_) {}
  });

  test('1) upload avatar -> absolute avatar_url -> image bytes are fetchable',
      () async {
    final avatarUrl = await stack.account.uploadAvatar(validPng.path);
    expect(avatarUrl, isNotEmpty, reason: 'upload returned no avatar_url');

    // The bug this guards: the backend returns "/user/auth/me/avatar/image",
    // which CachedNetworkImage cannot load. The data layer must absolutize it.
    expect(avatarUrl, startsWith('http'),
        reason: 'avatar_url must be an absolute URL, got: $avatarUrl');
    expect(
      avatarUrl,
      '${EndPoints.baseUrl}/user/auth/me/avatar/image',
      reason: 'avatar_url must resolve against the API base',
    );

    // The app must actually be able to fetch the pixels behind that URL.
    final bytes = await stack.apiClient.getBytes('/user/auth/me/avatar/image');
    expect(bytes.length, greaterThan(100),
        reason: 'avatar image fetch returned too few bytes');
    expect(bytes.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47],
        reason: 'response must start with the PNG magic bytes');
  });

  test('2) a cold-start account fetch surfaces the same absolute avatar URL',
      () async {
    // New ApiClient over the same storage: simulates an app restart.
    final coldStack = buildStack(storage: stack.storage);
    final account = await coldStack.account.fetchAccountData();
    expect(account.avatarUrl, isNotNull,
        reason: 'avatar must survive a cold start');
    expect(account.avatarUrl, startsWith('http'),
        reason: 'cold-start avatar_url must be absolute, got: '
            '${account.avatarUrl}');
    expect(
      account.avatarUrl,
      '${EndPoints.baseUrl}/user/auth/me/avatar/image',
    );
  });

  test('3) the backend reports the avatar as set for this user', () async {
    final json =
        await stack.apiClient.get(EndPoints.me) as Map<String, dynamic>;
    final userJson = json['user'] as Map<String, dynamic>;
    expect(userJson['avatar_url'], '/user/auth/me/avatar/image',
        reason: 'backend must report the avatar as set');

    final me = await stack.repo.getMe();
    me.fold((f) => fail('getMe failed: $f'), (user) {
      expect(user.devices, isNotEmpty,
          reason: 'getMe must still return the device list');
    });
  });

  test('4) avatar image is served with an image content-type to its owner',
      () async {
    final response = await http.get(
      Uri.parse('${EndPoints.baseUrl}/user/auth/me/avatar/image'),
      headers: {'Authorization': 'Bearer ${stack.accessToken!}'},
    );
    expect(response.statusCode, 200,
        reason: 'avatar image endpoint must return 200 for the owner');
    expect(response.headers['content-type'], contains('image'),
        reason: 'avatar response must be an image, got: '
            '${response.headers['content-type']}');
    expect(response.bodyBytes.length, greaterThan(100));
  });

  test('5) a non-image upload is rejected', () async {
    final bogus = File('${tempDir.path}/fake.png');
    await bogus.writeAsString('this is not an image at all');
    await expectLater(
      stack.account.uploadAvatar(bogus.path),
      throwsA(isA<Object>()),
      reason: 'uploading a non-image must be rejected by the backend',
    );
  });

  test('6) avatar upload recovers from an expired access token', () async {
    // Poison the in-memory token; the multipart upload must refresh and retry
    // instead of failing with "Session expired".
    stack.apiClient.setAccessToken('expired.access.token');
    final url = await stack.account.uploadAvatar(validPng.path);
    expect(url, startsWith('http'),
        reason: 'multipart upload must survive an expired access token');
  });
}
