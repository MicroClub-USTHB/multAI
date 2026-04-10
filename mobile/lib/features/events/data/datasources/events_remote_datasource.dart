import '../../../../core/network/api_client.dart';
import '../../../../core/constants/end_points.dart';
import '../models/event_model.dart';

abstract class EventsRemoteDataSource {
  Future<List<EventModel>> getUserEvents();
  Future<void> joinEvent(String eventCode);
}

class EventsRemoteDataSourceImpl implements EventsRemoteDataSource {
  final ApiClient apiClient;

  EventsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<EventModel>> getUserEvents() async {
    final response = await apiClient.get(EndPoints.userEvents);
    final List<dynamic> items = response as List<dynamic>;
    return items
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> joinEvent(String eventCode) async {
    await apiClient.post(
      EndPoints.joinEvent,
      body: {'event_code': eventCode},
      requiresAuth: true,
    );
  }
}
