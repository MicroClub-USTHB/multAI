// Live E2E test of the push-notification / device-token flow against the
// backend, plus the in-app notification list and mark-as-read round trip.
//
// The app registers its FCM token with the device identifier produced by
// DeviceUtils.getDeviceData().deviceId, which is the *physical* device id it
// also sends to the backend as `physical_device_id` at login. The backend's
// POST /user/auth/devices/token and /devices/inactivate now resolve the device
// by physical_device_id when the DB id does not match, so that identifier is
// the contract used below. See tests 4 and 5.
//
// Run:
//   flutter test test/e2e/push_notifications_e2e_test.dart \
//     --dart-define=E2E_ENABLED=true --dart-define=BASE_URL=http://localhost:8000
import 'package:flutter_test/flutter_test.dart';
import 'package:multai_mobile/core/errors/failure.dart';
import 'package:multai_mobile/features/notifications/data/models/notification_model.dart';

import 'helpers/e2e_harness.dart';

/// Runs [action] and returns the [Failure] it threw, or null if it succeeded.
Future<Failure?> failureOf(Future<void> Function() action) async {
  try {
    await action();
    return null;
  } on Failure catch (f) {
    return f;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadE2EConfig);

  if (!e2eEnabled) {
    test(
      'push notifications live backend E2E (skipped)',
      () {},
      skip: 'Pass --dart-define=E2E_ENABLED=true to run live backend E2E',
    );
    return;
  }

  setUp(allowRealNetwork);

  // The physical device id the app sends at login (and, today, to the push
  // endpoints). Kept unique per run so we always own a fresh device row.
  late String physicalDeviceId;
  late E2EStack stack;

  setUpAll(() async {
    final hex = DateTime.now()
        .microsecondsSinceEpoch
        .toRadixString(16)
        .padLeft(12, '0');
    // Valid UUID shape; unique per run so we always own a fresh device row.
    physicalDeviceId = '99999999-aaaa-bbbb-cccc-${hex.substring(0, 12)}';

    // ONE login for the whole file: the backend rate-limits login to 5/60s.
    stack = buildStack();
    await loginAs(
      stack,
      'alice@example.com',
      'Alice123!',
      deviceId: physicalDeviceId,
      deviceName: 'E2E Push Runner',
    );
  });

  /// The DB primary key the backend assigned to this run's device row, as
  /// reported by GET /user/auth/me (the only place it is exposed).
  Future<String> dbDeviceIdForThisRun() async {
    final me = await stack.repo.getMe();
    final user = me.getOrElse(() => throw StateError('getMe failed: $me'));
    final matches =
        user.devices.where((d) => d.deviceName == 'E2E Push Runner').toList();
    expect(matches, isNotEmpty,
        reason: 'login did not create the E2E Push Runner device row '
            '(devices: ${user.devices.map((d) => d.deviceName).toList()})');
    return matches.first.id;
  }

  test('1) notifications list is readable and parses the real payload',
      () async {
    final items = await stack.notifications.getNotifications();
    expect(items, isNotEmpty,
        reason: 'seeded alice account should have a welcome notification');
    final welcome = items.first;
    expect(welcome.id, isNotEmpty);
    expect(welcome.createdAt.isAfter(DateTime(2020)), isTrue);
    // The backend stores the copy under `payload.message`; the app must
    // surface it as the card body rather than dropping it.
    expect(welcome.body, isNotEmpty,
        reason: 'notification body must not be empty — payload: '
            '${welcome.payload}');
    expect(welcome.body, contains('Welcome'),
        reason: 'welcome copy lost in translation: ${welcome.payload}');
  });

  test('2) mark-as-read round trip persists read_at', () async {
    final before = await stack.notifications.getNotifications();
    expect(before, isNotEmpty);

    // alice is the shared seeded account, and scripts/seed.py gives her exactly
    // ONE notification. This test consumes it, so a second run finds nothing
    // unread. Handle both states rather than failing on repeat runs.
    final unread = before.where((n) => !n.isRead).toList();
    final target = unread.isNotEmpty ? unread.first : before.first;

    List<NotificationModel>? marked;
    Failure? markFailure;
    try {
      marked = await stack.notifications.markAsRead([target.id]);
    } on Failure catch (f) {
      markFailure = f;
    }

    if (unread.isNotEmpty) {
      expect(markFailure, isNull,
          reason: 'marking an unread item must succeed: $markFailure');
      expect(marked!.where((n) => n.id == target.id).isNotEmpty, isTrue,
          reason: 'marked item must be returned');
    } else {
      // Already-read: the backend rejects re-marking instead of no-oping.
      expect(markFailure, isA<NotFoundFailure>(),
          reason: 're-marking a read item must be rejected: $markFailure');
      expect(marked, isNull);
    }

    // And a fresh fetch agrees either way.
    final after = await stack.notifications.getNotifications();
    final refetched = after.where((n) => n.id == target.id).toList();
    expect(refetched, isNotEmpty, reason: 'marked item must still exist');
    expect(refetched.first.isRead, isTrue,
        reason: 'read state must survive a refetch');
  });

  test('3) a push token can be registered with the DB device id from /me',
      () async {
    final dbDeviceId = await dbDeviceIdForThisRun();
    expect(dbDeviceId, isNotEmpty);

    final failure = await failureOf(
      () => stack.notifications.registerPushToken(
        deviceId: dbDeviceId,
        token: 'fcm-e2e-token-${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
    expect(failure, isNull,
        reason: 'registering a push token with the DB device id must succeed '
            '(proves the backend endpoint itself is healthy): $failure');
  });

  test('4) the identifier the app actually uses (the physical device id) '
      'registers the push token', () async {
    // This is exactly what PushNotificationService.registerCurrentToken does:
    // it passes DeviceUtils.getDeviceData().deviceId, i.e. the physical id.
    final failure = await failureOf(
      () => stack.notifications.registerPushToken(
        deviceId: physicalDeviceId,
        token: 'fcm-e2e-token-${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
    expect(
      failure,
      isNull,
      reason: 'the app addresses its own device row with the physical device '
          'id, so /user/auth/devices/token must accept it: $failure',
    );
  });

  test('5) revoke (inactivate) works with both the physical and the DB id',
      () async {
    final dbDeviceId = await dbDeviceIdForThisRun();

    final withPhysical = await failureOf(
      () => stack.notifications.revokePushToken(physicalDeviceId),
    );
    expect(withPhysical, isNull,
        reason: 'inactivate with the physical device id must succeed: '
            '$withPhysical');

    final withDbId = await failureOf(
      () => stack.notifications.revokePushToken(dbDeviceId),
    );
    expect(withDbId, isNull,
        reason: 'inactivate with the DB device id must still succeed: '
            '$withDbId');
  });
}
