import 'dart:convert';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/app_local_storage.dart';
import '../models/event_model.dart';

abstract class EventsLocalDataSource {
  Future<void> cacheEvents(List<EventModel> events);
  Future<List<EventModel>?> getCachedEvents();
  Future<void> clearCache();
}

class EventsLocalDataSourceImpl implements EventsLocalDataSource {
  final LocalStorage localStorage;

  EventsLocalDataSourceImpl({required this.localStorage});

  @override
  Future<void> cacheEvents(List<EventModel> events) async {
    final jsonList = events.map((e) => e.toJson()).toList();
    final raw = jsonEncode(jsonList);
    await localStorage.setSecureString(StorageKeys.cachedEvents, raw);
  }

  @override
  Future<List<EventModel>?> getCachedEvents() async {
    final encrypted = await localStorage.getSecureString(
      StorageKeys.cachedEvents,
    );
    if (encrypted == null || encrypted.isEmpty) return null;

    try {
      final List<dynamic> items = jsonDecode(encrypted) as List<dynamic>;
      return items
          .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    await localStorage.removeSecure(StorageKeys.cachedEvents);
  }
}
