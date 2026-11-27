import '../../domain/entities/photo_approval_entity.dart';

class PhotoApprovalModel extends PhotoApprovalEntity {
  const PhotoApprovalModel({
    required super.id,
    required super.photoId,
    required super.decision,
    super.decidedAt,
  });

  factory PhotoApprovalModel.fromJson(Map<String, dynamic> json) {
    return PhotoApprovalModel(
      id: json['id'] as String,
      photoId: json['photo_id'] as String,
      decision: ApprovalDecision.fromString(json['decision'] as String?),
      decidedAt: json['decided_at'] != null
          ? DateTime.parse(json['decided_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'photo_id': photoId,
    'decision': decision.name,
    'decided_at': decidedAt?.toIso8601String(),
  };
}
