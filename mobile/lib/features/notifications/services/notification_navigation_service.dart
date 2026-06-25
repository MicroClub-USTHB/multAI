import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';

class NotificationNavigationService {
  GoRouter? _router;

  void init(GoRouter router) {
    _router = router;
  }

  void onNotificationTap(RemoteMessage message) {
    if (_router == null) return;

    final data = message.data;
    final type = data['type'] ?? message.notification?.title;

    switch (type) {
      case 'photo_approval':
        final photoId = data['photo_id'];
        if (photoId != null) {
          _router!.push('${AppRoutes.photoApproval}?photoId=$photoId');
        } else {
          _router!.push(AppRoutes.photoApproval);
        }
      case 'face_match':
      case 'photo_distributed':
        _router!.push(AppRoutes.gallery);
      case 'event_invite':
        _router!.push(AppRoutes.events);
      default:
        _router!.push(AppRoutes.notifications);
    }
  }

  void handleDeepLink(Uri uri) {
    if (_router == null) return;

    final path = uri.path;
    final queryParams = uri.queryParameters;

    if (path.contains('photo-approval')) {
      final photoId = queryParams['photoId'];
      if (photoId != null) {
        _router!.push('${AppRoutes.photoApproval}?photoId=$photoId');
      } else {
        _router!.push(AppRoutes.photoApproval);
      }
    } else if (path.contains('gallery')) {
      _router!.push(AppRoutes.gallery);
    } else if (path.contains('events')) {
      _router!.push(AppRoutes.events);
    } else if (path.contains('notifications')) {
      _router!.push(AppRoutes.notifications);
    }
  }
}
