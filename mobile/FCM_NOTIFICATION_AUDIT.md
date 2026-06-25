# FCM Notification Architecture Audit

## Date: 2026-06-25

## Critical Issues Found

### Flutter (Critical)
1. `Firebase.initializeApp()` NEVER called - all FCM calls will crash
2. `PushNotificationService.init()` NEVER called - entire notification system is dead code
3. No Firebase config files (google-services.json / GoogleService-Info.plist)
4. `firebaseMessagingBackgroundHandler` is a no-op - background notifications silently lost
5. Push token NEVER revoked on logout
6. Deep link handler is completely empty
7. Notification tap navigation doesn't pass payload data
8. NotificationBloc has dead event handlers (PushTokenReceived, PushNotificationReceived)

### Android
1. Missing `com.google.gms.google-services` plugin in build.gradle.kts
2. Missing Android 13+ POST_NOTIFICATIONS permission
3. No google-services.json

### iOS
1. AppDelegate doesn't call FirebaseApp.configure()
2. Missing push notification background mode entitlement
3. No GoogleService-Info.plist

### Backend
1. Single-face match (face_match.py) doesn't send push notifications - `notification` parameter is None
2. No FCM platform-specific configuration
3. Token invalidation uses one DB transaction per token (not batched)
4. Notification worker not in docker-compose.staging.yml

## Architecture Ownership

- **Flutter owns**: FCM SDK initialization, token lifecycle management, local notifications (foreground display), notification tap navigation
- **Backend owns**: Token storage, notification routing, FCM API calls via firebase-admin, invalid token tracking
- **Firebase owns**: Message delivery to devices, token mapping to device instances
