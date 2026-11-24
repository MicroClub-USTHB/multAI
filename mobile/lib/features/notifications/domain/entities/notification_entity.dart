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
  // The backend stores the human-readable text under `message` (see
  // app/service/stats.py), while push payloads use `body`. Accept either so
  // notification text is not silently dropped.
  String get body =>
      payload['body'] as String? ?? payload['message'] as String? ?? '';

  NotificationEntity copyWith({
    String? id,
    NotificationType? type,
    Map<String, dynamic>? payload,
    DateTime? readAt,
    DateTime? createdAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      readAt: readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
