enum NotificationType {
  photoApproval,
  photoDistributed,
  eventInvite,
  system,
  unknown,
}

extension NotificationTypeX on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.photoApproval:
        return 'Photo Approval';
      case NotificationType.photoDistributed:
        return 'Photo Distributed';
      case NotificationType.eventInvite:
        return 'Event Invite';
      case NotificationType.system:
        return 'System';
      case NotificationType.unknown:
        return 'Notification';
    }
  }

  static NotificationType fromString(String value) {
    switch (value) {
      case 'photo_approval':
        return NotificationType.photoApproval;
      case 'photo_distributed':
        return NotificationType.photoDistributed;
      case 'event_invite':
        return NotificationType.eventInvite;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.unknown;
    }
  }
}

class NotificationEntity {
  final String id;
  final NotificationType type;
  final Map<String, dynamic> payload;
  final DateTime? readAt;
  final DateTime createdAt;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.payload,
    this.readAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  String get title => payload['title'] as String? ?? type.label;
  String get body => payload['body'] as String? ?? '';
}
