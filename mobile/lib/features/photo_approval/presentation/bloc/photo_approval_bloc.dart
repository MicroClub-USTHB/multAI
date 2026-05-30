import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/photo_approval_entity.dart';
import '../../domain/usecases/get_approvals_usecase.dart';
import '../../domain/usecases/decide_photo_approval_usecase.dart';

part 'photo_approval_event.dart';
part 'photo_approval_state.dart';

class PhotoApprovalBloc extends Bloc<PhotoApprovalEvent, PhotoApprovalState> {
  final GetApprovalsUsecase _getApprovals;
  final DecidePhotoApprovalUseCase _decideApproval;

  PhotoApprovalBloc({
    required GetApprovalsUsecase getApprovals,
    required DecidePhotoApprovalUseCase decideApproval,
  }) : _getApprovals = getApprovals,
       _decideApproval = decideApproval,
       super(PhotoApprovalInitial()) {
    on<LoadApprovals>(_onLoadApprovals);
    on<LoadPendingApprovals>(_onLoadPending);
    on<ApprovePhoto>(_onApprove);
    on<RejectPhoto>(_onReject);
  }

  Future<void> _onLoadApprovals(
    LoadApprovals event,
    Emitter<PhotoApprovalState> emit,
  ) async {
    emit(PhotoApprovalLoading());

    final result = await _getApprovals(
      GetApprovalsParams(status: event.status),
    );

    result.fold(
      (failure) => emit(PhotoApprovalError(message: failure.message)),
      (approvals) {
        final pending = approvals.where((a) => a.decision.isPending).toList();
        final history = approvals.where((a) => !a.decision.isPending).toList();
        emit(PhotoApprovalLoaded(pending: pending, history: history));
      },
    );
  }

  Future<void> _onLoadPending(
    LoadPendingApprovals event,
    Emitter<PhotoApprovalState> emit,
  ) async {
    add(LoadApprovals(status: 'pending'));
  }

  Future<void> _onApprove(
    ApprovePhoto event,
    Emitter<PhotoApprovalState> emit,
  ) async {
    emit(PhotoApprovalDeciding(photoId: event.photoId));

    final result = await _decideApproval(
      DecidePhotoParams(photoId: event.photoId, decision: 'approved'),
    );

    result.fold(
      (failure) => emit(PhotoApprovalError(message: failure.message)),
      (photoStatus) {
        emit(
          PhotoApprovalDecisionSuccess(
            photoId: event.photoId,
            decision: 'approved',
            photoStatus: photoStatus,
          ),
        );
        add(LoadApprovals());
      },
    );
  }

  Future<void> _onReject(
    RejectPhoto event,
    Emitter<PhotoApprovalState> emit,
  ) async {
    emit(PhotoApprovalDeciding(photoId: event.photoId));

    final result = await _decideApproval(
      DecidePhotoParams(photoId: event.photoId, decision: 'rejected'),
    );

    result.fold(
      (failure) => emit(PhotoApprovalError(message: failure.message)),
      (photoStatus) {
        emit(
          PhotoApprovalDecisionSuccess(
            photoId: event.photoId,
            decision: 'rejected',
            photoStatus: photoStatus,
          ),
        );
        add(LoadApprovals());
      },
    );
  }
}
