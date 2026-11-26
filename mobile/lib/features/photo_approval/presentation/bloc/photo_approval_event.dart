part of 'photo_approval_bloc.dart';

abstract class PhotoApprovalEvent {}

class LoadApprovals extends PhotoApprovalEvent {
  final String? status; // null = all, 'pending', 'approved', 'rejected'
  LoadApprovals({this.status});
}

class LoadPendingApprovals extends PhotoApprovalEvent {}

class ApprovePhoto extends PhotoApprovalEvent {
  final String photoId;
  ApprovePhoto({required this.photoId});
}

class RejectPhoto extends PhotoApprovalEvent {
  final String photoId;
  RejectPhoto({required this.photoId});
}
