import 'dart:convert';
import '../../../../core/storage/app_local_storage.dart';
import '../../domain/entities/photo_entity.dart';

class PhotoLocalDataSource {
  final AppLocalStorage localStorage;

  PhotoLocalDataSource({required this.localStorage});

  static const _allPhotosKey = 'cached_all_photos';
  static const _eventPhotosPrefix = 'cached_event_photos_';

  Future<void> cacheAllPhotos(List<PhotoEntity> photos) async {
    final jsonList = photos.map(_photoToJson).toList();
    await localStorage.setString(
      _allPhotosKey,
      jsonEncode({'photos': jsonList}),
    );
  }

  List<PhotoEntity>? getCachedAllPhotos() {
    final raw = localStorage.getString(_allPhotosKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final list = json['photos'] as List<dynamic>?;
      if (list == null || list.isEmpty) return null;
      return list
          .map((e) => _photoFromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheEventPhotos(
    String eventId,
    List<PhotoEntity> photos,
    int total,
  ) async {
    final jsonList = photos.map(_photoToJson).toList();
    await localStorage.setString(
      '$_eventPhotosPrefix$eventId',
      jsonEncode({'photos': jsonList, 'total': total}),
    );
  }

  ({List<PhotoEntity> items, int total})? getCachedEventPhotos(String eventId) {
    final raw = localStorage.getString('$_eventPhotosPrefix$eventId');
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final list = json['photos'] as List<dynamic>?;
      final total = json['total'] as int? ?? 0;
      if (list == null || list.isEmpty) return (items: [], total: total);
      return (
        items: list
            .map((e) => _photoFromJson(e as Map<String, dynamic>))
            .toList(),
        total: total,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clearCache() async {
    await localStorage.remove(_allPhotosKey);
  }

  static Map<String, dynamic> _photoToJson(PhotoEntity p) => {
    'id': p.id,
    'event_id': p.eventId,
    'visibility': p.visibility.name,
    'status': p.status.name,
    'taken_at': p.takenAt?.toIso8601String(),
    'day_number': p.dayNumber,
    'created_at': p.createdAt.toIso8601String(),
  };

  static PhotoEntity _photoFromJson(Map<String, dynamic> json) => PhotoEntity(
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
