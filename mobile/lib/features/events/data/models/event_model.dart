import '../../domain/entities/event_entity.dart';

class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.name,
    required super.eventDate,
    required super.status,
    required super.joinedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      eventDate: DateTime.parse(json['event_date'] as String),
      status: json['status'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  EventEntity toEntity() => EventEntity(
    id: id,
    name: name,
    eventDate: eventDate,
    status: status,
    joinedAt: joinedAt,
  );
}
