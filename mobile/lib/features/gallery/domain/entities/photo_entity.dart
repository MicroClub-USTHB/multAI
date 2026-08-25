enum PhotoVisibility {
  public,
  private,
  unknown;

  static PhotoVisibility fromString(String? value) {
    switch (value) {
      case 'public':
        return PhotoVisibility.public;
      case 'private':
        return PhotoVisibility.private;
      default:
        return PhotoVisibility.unknown;
    }
  }
}

enum PhotoStatus {
  pending,
  approved,
  rejected,
  distributed,
  unknown;

  static PhotoStatus fromString(String? value) {
    switch (value) {
      case 'pending':
        return PhotoStatus.pending;
      case 'approved':
        return PhotoStatus.approved;
      case 'rejected':
        return PhotoStatus.rejected;
      case 'distributed':
        return PhotoStatus.distributed;
      default:
        return PhotoStatus.unknown;
    }
  }
}

class PhotoEntity {
  final String id;
  final String eventId;
  final PhotoVisibility visibility;
  final PhotoStatus status;
  final DateTime? takenAt;
  final int? dayNumber;
  final DateTime createdAt;
  final int faceCount;

  // local cache path — set after download
  final String? localPath;

  const PhotoEntity({
    required this.id,
    required this.eventId,
    required this.visibility,
    required this.status,
    this.takenAt,
    this.dayNumber,
    required this.createdAt,
    this.faceCount = 0,
    this.localPath,
  });

  bool get isCached => localPath != null;
  bool get isSolo => faceCount == 1;
  bool get isGroup => faceCount > 1;
}
