import 'package:flutter_test/flutter_test.dart';
import 'package:multai_mobile/features/notifications/services/notification_navigation_service.dart';

void main() {
  late NotificationNavigationService navigationService;

  setUp(() {
    navigationService = NotificationNavigationService();
  });

  group('NotificationNavigationService', () {
    test('can be instantiated', () {
      expect(navigationService, isNotNull);
    });

    test('handles deep link for photo approval', () {
      final uri = Uri.parse('/photo-approval?photoId=123');
      // Should not throw when router is not initialized
      expect(() => navigationService.handleDeepLink(uri), returnsNormally);
    });

    test('handles deep link for gallery', () {
      final uri = Uri.parse('/gallery');
      expect(() => navigationService.handleDeepLink(uri), returnsNormally);
    });

    test('handles deep link for events', () {
      final uri = Uri.parse('/events');
      expect(() => navigationService.handleDeepLink(uri), returnsNormally);
    });

    test('handles deep link for notifications', () {
      final uri = Uri.parse('/notifications');
      expect(() => navigationService.handleDeepLink(uri), returnsNormally);
    });

    test('handles deep link for face match (hyphenated)', () {
      final uri = Uri.parse('/face-match');
      expect(() => navigationService.handleDeepLink(uri), returnsNormally);
    });

    test('handles deep link for face match (underscore normalized)', () {
      final uri = Uri.parse('/face_match');
      expect(() => navigationService.handleDeepLink(uri), returnsNormally);
    });
  });
}
