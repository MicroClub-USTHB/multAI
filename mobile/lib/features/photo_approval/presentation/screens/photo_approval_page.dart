import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_protector/screen_protector.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import '../../../../core/extensions/snackbar_extensions.dart';
import '../../../../core/errors/error_presentation.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../bloc/photo_approval_bloc.dart';
import 'widgets/header_section.dart';
import 'widgets/photo_approval_card.dart';
import 'widgets/recent_decisions_section.dart';
import 'package:multai_mobile/core/theme/app_palette.dart';

class PhotoApprovalPage extends StatefulWidget {
  const PhotoApprovalPage({super.key});

  @override
  State<PhotoApprovalPage> createState() => _PhotoApprovalPageState();
}

class _PhotoApprovalPageState extends State<PhotoApprovalPage> {
  @override
  void initState() {
    super.initState();
    ScreenProtector.preventScreenshotOn();
    ScreenProtector.protectDataLeakageOn();
  }

  @override
  void dispose() {
    ScreenProtector.preventScreenshotOff();
    ScreenProtector.protectDataLeakageOff();
    super.dispose();
  }

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
          context.showErrorSnackBar(state.errorPresentation.description);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.colors.background,
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(height: context.heightCalculated(12)),

                // ── Header ─────────────────────────────────────────────
                const HeaderSection(),

                Expanded(child: _buildBody(context, state)),
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
      return Center(child: CircularProgressIndicator(color: cs.primary));
    }

    if (state is PhotoApprovalLoading) {
      return Center(child: CircularProgressIndicator(color: cs.primary));
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
            vertical: context.heightCalculated(16),
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
                      onAccept: () => context.read<PhotoApprovalBloc>().add(
                        ApprovePhoto(photoId: approval.photoId),
                      ),
                      onReject: () => context.read<PhotoApprovalBloc>().add(
                        RejectPhoto(photoId: approval.photoId),
                      ),
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

    if (state is PhotoApprovalError) {
      final p = state.errorPresentation;
      return ErrorStateView(
        title: p.title,
        description: p.description,
        illustration: p.illustration,
        actionLabel: p.actionLabel,
        onAction: p.action == ErrorAction.retry
            ? () => context.read<PhotoApprovalBloc>().add(LoadApprovals())
            : p.action == ErrorAction.signIn
            ? () {
                context.read<AuthBloc>().add(LogoutRequested());
                context.go(AppRoutes.login);
              }
            : p.action == ErrorAction.goBack
            ? () => context.pop()
            : null,
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
                color: context.colors.secondaryText,
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
            color: context.colors.success.withValues(alpha: 0.5),
          ),
          SizedBox(height: context.heightCalculated(16)),
          Text(
            'All caught up!',
            style: tt.titleMedium?.copyWith(color: context.colors.primaryText),
          ),
          SizedBox(height: context.heightCalculated(8)),
          Text(
            'No pending photo approvals',
            style: tt.bodySmall?.copyWith(color: context.colors.secondaryText),
          ),
        ],
      ),
    );
  }
}
