import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import '../../../../core/extensions/snackbar_extensions.dart'; 
import '../../../../core/theme/theme.dart';
import '../bloc/photo_approval_bloc.dart';
import 'widgets/header_section.dart';
import 'widgets/photo_approval_card.dart';
import 'widgets/recent_decisions_section.dart';
 
class PhotoApprovalPage extends StatelessWidget {
  const PhotoApprovalPage({super.key});
 
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PhotoApprovalBloc, PhotoApprovalState>(
      listener: (context, state) {
        if (state is PhotoApprovalDecisionSuccess) {
          final msg = state.decision == 'approved'
              ? 'Photo approved successfully'
              : 'Photo rejected';
          context.showSuccessSnackBar(msg);
        }
        if (state is PhotoApprovalError) {
          context.showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(height: context.heightCalculated(12)),
 
                // ── Header ─────────────────────────────────────────────
                const HeaderSection(),
 
                Expanded(
                  child: _buildBody(context, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
 
  Widget _buildBody(BuildContext context, PhotoApprovalState state) {
    final cs = context.theme.colorScheme;
 
    // ── trigger load on initial ──────────────────────────────────────────
    if (state is PhotoApprovalInitial) {
      context.read<PhotoApprovalBloc>().add(LoadApprovals());
      return Center(
        child: CircularProgressIndicator(color: cs.primary),
      );
    }
 
    if (state is PhotoApprovalLoading) {
      return Center(
        child: CircularProgressIndicator(color: cs.primary),
      );
    }
 
    if (state is PhotoApprovalLoaded) {
      return RefreshIndicator(
        color: cs.primary,
        onRefresh: () async {
          context.read<PhotoApprovalBloc>().add(LoadApprovals());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: context.hPadding(),
            vertical:   context.heightCalculated(16),
          ),
          child: Column(
            children: [
 
              // ── Pending approvals ──────────────────────────────────
              if (state.pending.isEmpty)
                _buildNoPending(context)
              else
                ...state.pending.map(
                  (approval) => Padding(
                    padding: EdgeInsets.only(
                      bottom: context.heightCalculated(16),
                    ),
                    child: PhotoApprovalCard(
                      approval: approval,
                      isDeciding: false,
                      onAccept: () => context
                          .read<PhotoApprovalBloc>()
                          .add(ApprovePhoto(photoId: approval.photoId)),
                      onReject: () => context
                          .read<PhotoApprovalBloc>()
                          .add(RejectPhoto(photoId: approval.photoId)),
                    ),
                  ),
                ),
 
              SizedBox(height: context.heightCalculated(24)),
 
              // ── History ────────────────────────────────────────────
              if (state.history.isNotEmpty)
                RecentDecisionsSection(decisions: state.history),
 
              SizedBox(height: context.heightCalculated(24)),
            ],
          ),
        ),
      );
    }
 
    // deciding state — show spinner over current content
    if (state is PhotoApprovalDeciding) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: cs.primary),
            SizedBox(height: context.heightCalculated(16)),
            Text(
              'Processing decision...',
              style: context.textTheme.bodySmall?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }
 
    return const SizedBox.shrink();
  }
 
  Widget _buildNoPending(BuildContext context) {
    final tt = context.textTheme;
 
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: context.iconSize() * 3,
            color: AppTheme.successColor.withValues(alpha: 0.5),
          ),
          SizedBox(height: context.heightCalculated(16)),
          Text(
            'All caught up!',
            style: tt.titleMedium?.copyWith(
              color: AppTheme.primaryTextColor,
            ),
          ),
          SizedBox(height: context.heightCalculated(8)),
          Text(
            'No pending photo approvals',
            style: tt.bodySmall?.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
