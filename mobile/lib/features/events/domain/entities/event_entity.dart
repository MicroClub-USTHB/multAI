class EventEntity {
  final String id;
  final String name;
  final DateTime eventDate;
  final DateTime? endDate;
  final String status;
  final DateTime joinedAt;

  const EventEntity({
    required this.id,
    required this.name,
    required this.eventDate,
    this.endDate,
    required this.status,
    required this.joinedAt,
  });
}
