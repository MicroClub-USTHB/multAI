# FCM Notification Architecture Audit & Refactor Report

## Date: 2026-06-25

## Architecture Ownership

| Component | Owner | Responsibility |
|-----------|-------|----------------|
| FCM SDK Initialization | Flutter | `Firebase.initializeApp()` in main.dart |
| Token Lifecycle Management | Flutter | getToken, onTokenRefresh, deleteToken |
| Local Notifications (Foreground) | Flutter | flutter_local_notifications plugin |
| Notification Tap Navigation | Flutter | NotificationNavigationService |
| Deep Linking | Flutter | app_links + NotificationNavigationService |
| Token Storage | Backend | user_devices table with push_token column |
| Notification Routing | Backend | UserNotificationService |
| FCM API Calls | Backend | firebase-admin SDK via notification worker |
| Invalid Token Tracking | Backend | Redis + DB (is_invalid_token flag) |
| Message Delivery | Firebase | FCM infrastructure |

## Issues Found & Fixed

### P0 - CRITICAL (Fixed)

| Issue | Fix | Commit |
|-------|-----|--------|
| `Firebase.initializeApp()` never called | Added to main.dart after DI init | 50d96cb |
| `PushNotificationService.init()` never called | Called in main.dart after Firebase init | 50d96cb |
| `firebaseMessagingBackgroundHandler` was no-op | Now initializes Firebase + shows local notification | f00173e |
| Deep link handler was empty | Implemented with NotificationNavigationService | 50d96cb |
| Missing `com.google.gms.google-services` plugin | Added to Android build.gradle.kts | 068d1ec |
| Missing POST_NOTIFICATIONS permission (Android 13+) | Added to AndroidManifest.xml | 068d1ec |
| No FirebaseApp.configure() in iOS AppDelegate | Added Firebase import + configure() call | 6056747 |
| Missing push notification entitlements | Created Runner.entitlements with aps-environment | 6056747 |
| Missing UIBackgroundModes for remote-notification | Added to Info.plist | 6056747 |

### P1 - HIGH (Fixed)

| Issue | Fix | Commit |
|-------|-----|--------|
| Push token never revoked on logout | Added revokeToken() to AuthBloc and AccountBloc logout | 4e1a916 |
| Notification tap navigation didn't pass payload data | Updated notification screen to pass photo_id | dc29b33 |
| NotificationScreen dispatched bloc event in build() | Moved to didChangeDependencies | dc29b33 |
| Single-face match (face_match.py) no push notification | Added UnifiedNotification to create_notification call | c19b4b6 (backend) |
| No FCM platform-specific config | Added AndroidConfig and APNSConfig to firebase.py | c19b4b6 (backend) |
| Token invalidation used one DB transaction per token | Batched in single transaction | c19b4b6 (backend) |

### P2 - MEDIUM (Fixed)

| Issue | Fix | Commit |
|-------|-----|--------|
| PushTokenReceived dead event | Removed from NotificationBloc | dc29b33 |
| PushNotificationReceived dead handler | Kept with proper usage | dc29b33 |
| Duplicate push token endpoints in AuthRemoteDataSource | Removed updateDeviceToken/inactivateDevice | a1c1330 |
| flutter_local_notifications v21 API mismatch | Fixed show() to use named params | 3734431 |

### P3 - LOW (Fixed)

| Issue | Fix | Commit |
|-------|-----|--------|
| No notification service tests | Added PushNotificationService + NotificationNavigationService tests | a00aa2c |
| AuthBloc test didn't provide PushNotificationService | Added mock + constructor param | 6aa67c9 |

## Files Created

| File | Purpose |
|------|---------|
| `lib/features/notifications/services/notification_navigation_service.dart` | Handles deep links and notification tap routing |
| `ios/Runner/Runner.entitlements` | Push notification entitlement for iOS |
| `test/features/notifications/services/push_notification_service_test.dart` | Unit tests for PushNotificationService |
| `test/features/notifications/services/notification_navigation_service_test.dart` | Unit tests for NotificationNavigationService |

## Files Modified

| File | Change |
|------|--------|
| `lib/main.dart` | Added Firebase.initializeApp(), PushNotificationService.init(), deep link handling |
| `lib/features/notifications/services/push_notification_service.dart` | Complete rewrite: proper init, background handler, navigation wiring |
| `lib/di/injection_container.dart` | Added NotificationNavigationService registration, updated dependencies |
| `lib/features/notifications/presentation/bloc/notifications_event.dart` | Removed PushTokenReceived dead event |
| `lib/features/notifications/presentation/bloc/notifications_bloc.dart` | Removed dead handlers, simplified constructor |
| `lib/features/notifications/presentation/screens/notifications_screen.dart` | Fixed build() side-effect, added payload to navigation |
| `lib/features/auth/presentation/blocs/auth_bloc.dart` | Added push token revocation on logout |
| `lib/features/account/presentation/bloc/account_bloc.dart` | Added push token revocation on logout |
| `lib/features/auth/data/datasource/remote_data.dart` | Removed duplicate push token methods |
| `android/app/build.gradle.kts` | Added google-services plugin |
| `android/build.gradle.kts` | Added google-services classpath |
| `android/app/src/main/AndroidManifest.xml` | Added POST_NOTIFICATIONS permission |
| `ios/Runner/AppDelegate.swift` | Added FirebaseApp.configure() |
| `ios/Runner/Info.plist` | Added UIBackgroundModes |
| `test/features/auth/presentation/blocs/auth_bloc_test.dart` | Added PushNotificationService mock |

## Files Deleted

None. Dead code was cleaned (methods removed from AuthRemoteDataSource, events removed from NotificationBloc).

## Backend Files Modified

| File | Change |
|------|--------|
| `app/service/face_match.py` | Added UnifiedNotification to create_notification for push delivery |
| `app/worker/notification/firebase.py` | Added AndroidConfig and APNSConfig platform-specific FCM settings |
| `app/worker/notification/invalid_tokens.py` | Batched token invalidation in single DB transaction |

## Complete Commit History

```
a00aa2c test: add notification service unit tests
6aa67c9 test: fix auth_bloc test after adding PushNotificationService dependency
3734431 fix: update notification show API for flutter_local_notifications v21
a1c1330 refactor: remove duplicate push token endpoints from auth datasource
6056747 fix: ios notification configuration
068d1ec fix: android notification configuration
4e1a916 fix: revoke push token on logout
dc29b33 refactor: simplify notification services and remove dead code
f00173e fix: implement token synchronization and foreground notification handling
50d96cb fix: correct firebase initialization in main.dart
ffc5e3d chore: add notification architecture audit report
```

## Security Review

1. **Push token revocation on logout**: Fixed - tokens now revoked via backend endpoint before local deletion
2. **Token ownership verification**: Verified - backend checks `device_id` belongs to authenticated user
3. **Hardcoded TOTP secret**: Noted - backend returns `totp_secret` in device list response
4. **Firebase credentials on filesystem**: Noted - uses `FIREBASE_CREDENTIALS_PATH` env var pointing to JSON file
5. **No rate limiting on `/devices/token`**: Noted - no rate limiter on push token update endpoint

## Remaining Notes

1. **google-services.json**: Must be added manually from Firebase Console to `android/app/`
2. **GoogleService-Info.plist**: Must be added manually from Firebase Console to `ios/Runner/`
3. **Notification worker deployment**: Backend notification worker not in docker-compose.staging.yml - needs separate deployment
4. **APNs environment**: iOS entitlement set to `development` - must change to `production` for App Store builds
5. **Notification preferences**: No user opt-out mechanism exists for push notification types
6. **NATS at-most-once delivery**: Notification worker uses NATS core pub/sub (not JetStream) - messages can be lost on worker crash

## Migration Guide

1. Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from Firebase Console
2. For iOS production: Change `aps-environment` in `ios/Runner/Runner.entitlements` from `development` to `production`
3. Run `flutter pub get` to fetch latest dependencies
4. Run `cd ios && pod install --repo-update` to install Firebase iOS SDK
5. Verify Firebase project has FCM enabled and APNs authentication key configured
