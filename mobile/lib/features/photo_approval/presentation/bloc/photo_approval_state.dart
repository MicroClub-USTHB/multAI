part of 'photo_approval_bloc.dart';

abstract class PhotoApprovalState {}

class PhotoApprovalInitial extends PhotoApprovalState {}

class PhotoApprovalLoading extends PhotoApprovalState {}

class PhotoApprovalLoaded extends PhotoApprovalState {
  final List<PhotoApprovalEntity> pending;
  final List<PhotoApprovalEntity> history;

  PhotoApprovalLoaded({required this.pending, required this.history});
}

class PhotoApprovalDeciding extends PhotoApprovalState {
  final String photoId;
  PhotoApprovalDeciding({required this.photoId});
}

class PhotoApprovalDecisionSuccess extends PhotoApprovalState {
  final String photoId;
  final String decision;
  final String photoStatus;
  PhotoApprovalDecisionSuccess({
    required this.photoId,
    required this.decision,
    required this.photoStatus,
  });
}

class PhotoApprovalError extends PhotoApprovalState {
  final String message;
  PhotoApprovalError({required this.message});
}
