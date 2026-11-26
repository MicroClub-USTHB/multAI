enum ApprovalDecision {
  pending,
  approved,
  rejected;

  static ApprovalDecision fromString(String? value) {
    switch (value) {
      case 'approved':
        return ApprovalDecision.approved;
      case 'rejected':
        return ApprovalDecision.rejected;
      default:
        return ApprovalDecision.pending;
    }
  }

  String get label {
    switch (this) {
      case ApprovalDecision.pending:
        return 'Pending';
      case ApprovalDecision.approved:
        return 'Approved';
      case ApprovalDecision.rejected:
        return 'Rejected';
    }
  }

  bool get isPending => this == ApprovalDecision.pending;
  bool get isApproved => this == ApprovalDecision.approved;
  bool get isRejected => this == ApprovalDecision.rejected;
}

class PhotoApprovalEntity {
  final String id;
  final String photoId;
  final ApprovalDecision decision;
  final DateTime? decidedAt;

  const PhotoApprovalEntity({
    required this.id,
    required this.photoId,
    required this.decision,
    this.decidedAt,
  });
}
