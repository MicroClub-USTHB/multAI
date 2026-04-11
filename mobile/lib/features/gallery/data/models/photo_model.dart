import '../../domain/entities/photo_entity.dart';

class PhotoModel extends PhotoEntity {
  const PhotoModel({
    required super.id,
    required super.eventId,
    required super.visibility,
    required super.status,
    super.takenAt,
    super.dayNumber,
    required super.createdAt,
    super.localPath,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      visibility: PhotoVisibility.fromString(json['visibility'] as String?),
      status: PhotoStatus.fromString(json['status'] as String?),
      takenAt: json['taken_at'] != null
          ? DateTime.parse(json['taken_at'] as String)
          : null,
      dayNumber: json['day_number'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  PhotoModel copyWithLocalPath(String path) {
    return PhotoModel(
      id: id,
      eventId: eventId,
      visibility: visibility,
      status: status,
      takenAt: takenAt,
      dayNumber: dayNumber,
      createdAt: createdAt,
      localPath: path,
    );
  }
}
