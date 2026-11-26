import '../../domain/entities/event_entity.dart';

class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.name,
    required super.eventDate,
    super.endDate,
    required super.status,
    required super.joinedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      name: json['name'] as String,
      eventDate: DateTime.parse(json['event_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      status: json['status'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'event_date': eventDate.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
    'status': status,
    'joined_at': joinedAt.toIso8601String(),
  };

  EventEntity toEntity() => EventEntity(
    id: id,
    name: name,
    eventDate: eventDate,
    endDate: endDate,
    status: status,
    joinedAt: joinedAt,
  );
}
