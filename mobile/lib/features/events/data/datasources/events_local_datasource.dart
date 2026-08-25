import 'dart:convert';
import '../../../../core/storage/app_local_storage.dart';
import '../../domain/entities/event_entity.dart';

abstract class EventsLocalDataSource {
  Future<void> cacheEvents(List<EventEntity> events);
  Future<List<EventEntity>?> getCachedEvents();
  Future<void> clearCache();
}

class EventsLocalDataSourceImpl implements EventsLocalDataSource {
  final AppLocalStorage localStorage;

  EventsLocalDataSourceImpl({required this.localStorage});

  static const _cacheKey = 'cached_events';

  @override
  Future<void> cacheEvents(List<EventEntity> events) async {
    final jsonList = events
        .map(
          (e) => <String, dynamic>{
            'id': e.id,
            'name': e.name,
            'event_date': e.eventDate.toIso8601String(),
            'end_date': e.endDate?.toIso8601String(),
            'status': e.status,
            'joined_at': e.joinedAt.toIso8601String(),
          },
        )
        .toList();
    await localStorage.setString(_cacheKey, jsonEncode({'events': jsonList}));
  }

  @override
  Future<List<EventEntity>?> getCachedEvents() async {
    final raw = localStorage.getString(_cacheKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final list = json['events'] as List<dynamic>?;
      if (list == null || list.isEmpty) return null;
      return list.map((e) {
        final map = e as Map<String, dynamic>;
        return EventEntity(
          id: map['id'] as String,
          name: map['name'] as String,
          eventDate: DateTime.parse(map['event_date'] as String),
          endDate: map['end_date'] != null
              ? DateTime.parse(map['end_date'] as String)
              : null,
          status: map['status'] as String,
          joinedAt: DateTime.parse(map['joined_at'] as String),
        );
      }).toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    await localStorage.remove(_cacheKey);
  }
}
