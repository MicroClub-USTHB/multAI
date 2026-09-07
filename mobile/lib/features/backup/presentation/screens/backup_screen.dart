import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/snackbar_extensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import '../../../../core/theme/theme.dart';
import '../../../../di/injection_container.dart' as di;
import '../../domain/usecases/create_backup_usecase.dart';
import '../bloc/backup_bloc.dart';
import '../widgets/backup_stats_card.dart';
import '../widgets/backup_progress_view.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BackupBloc(
        createBackup: di.sl<CreateBackupUseCase>(),
        repository: di.sl(),
      )..add(LoadBackupInfo()),
      child: const _BackupView(),
    );
  }
}

class _BackupView extends StatelessWidget {
  const _BackupView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BackupBloc, BackupState>(
      listener: (context, state) {
        if (state is BackupError) {
          context.showErrorSnackBar(state.errorPresentation.description);
        }
      },
      builder: (context, state) {
        final tt = context.textTheme;
        final cs = context.theme.colorScheme;

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppTheme.backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: context.iconSize(),
                color: AppTheme.primaryTextColor,
              ),
              onPressed: () => context.pop(),
            ),
            title: Text('Backup Photos', style: tt.headlineMedium),
          ),
          body: state is BackupProgress
              ? Center(
                  child: BackupProgressView(
                    percent: state.percent,
                    photoCount: state.photoCount,
                  ),
                )
              : state is BackupCompleted
                  ? _buildCompleted(context, state, cs)
                  : state is BackupLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: cs.primary,
                          ),
                        )
                      : _buildContent(context, state, cs),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    BackupState state,
    ColorScheme cs,
  ) {
    final tt = context.textTheme;
    final photoCount =
        state is BackupInfoLoaded ? state.photoCount : 0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: context.hPadding(),
        vertical: context.heightCalculated(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Hero Icon ──────────────────────────────────────────────
          Center(
            child: Container(
              padding: EdgeInsets.all(context.widthCalculated(24)),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.backup_outlined,
                size: context.iconSize() * 2.5,
                color: cs.primary,
              ),
            ),
          ),
          SizedBox(height: context.heightCalculated(24)),

          // ── Title ──────────────────────────────────────────────────
          Text(
            'Download Your Photos',
            style: tt.headlineMedium?.copyWith(
              color: AppTheme.primaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.heightCalculated(8)),
          Text(
            'Create a ZIP archive of all your cached photos. '
            'You can share it or save it to your device.',
            style: tt.bodyMedium?.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.heightCalculated(32)),

          // ── Stats Card ─────────────────────────────────────────────
          BackupStatsCard(photoCount: photoCount),
          SizedBox(height: context.heightCalculated(32)),

          // ── Backup Button ──────────────────────────────────────────
          SizedBox(
            height: context.heightCalculated(56),
            child: FilledButton(
              onPressed: photoCount > 0
                  ? () => context.read<BackupBloc>().add(StartBackup())
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                disabledBackgroundColor: cs.primary.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppThemeMetrics.radiusMd),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.download_outlined,
                    size: context.iconSize(),
                    color: photoCount > 0
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                  SizedBox(width: context.widthCalculated(8)),
                  Text(
                    'Create Backup',
                    style: tt.titleMedium?.copyWith(
                      color: photoCount > 0
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: context.heightCalculated(16)),

          // ── Empty state hint ───────────────────────────────────────
          if (photoCount == 0)
            Text(
              'No cached photos to backup. Photos are cached when you view them in the gallery.',
              style: tt.bodySmall?.copyWith(
                color: AppTheme.hintTextColor,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  Widget _buildCompleted(
    BuildContext context,
    BackupCompleted state,
    ColorScheme cs,
  ) {
    final tt = context.textTheme;
    final fileSize = state.zipFile.lengthSync();
    final fileSizeStr = _formatFileSize(fileSize);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: context.hPadding(),
        vertical: context.heightCalculated(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Success Icon ───────────────────────────────────────────
          Center(
            child: Container(
              padding: EdgeInsets.all(context.widthCalculated(24)),
              decoration: BoxDecoration(
                color: AppThemeColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: context.iconSize() * 2.5,
                color: AppThemeColors.success,
              ),
            ),
          ),
          SizedBox(height: context.heightCalculated(24)),

          Text(
            'Backup Ready!',
            style: tt.headlineMedium?.copyWith(
              color: AppTheme.primaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.heightCalculated(8)),
          Text(
            '${state.photoCount} photos · $fileSizeStr',
            style: tt.bodyMedium?.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.heightCalculated(8)),
          Text(
            state.zipFile.path.split('/').last,
            style: tt.bodySmall?.copyWith(
              color: AppTheme.hintTextColor,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.heightCalculated(32)),

          // ── Share Button ───────────────────────────────────────────
          SizedBox(
            height: context.heightCalculated(56),
            child: FilledButton(
              onPressed: () => context
                  .read<BackupBloc>()
                  .add(ShareBackup(zipFile: state.zipFile)),
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppThemeMetrics.radiusMd),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.share_outlined,
                    size: context.iconSize(),
                    color: Colors.white,
                  ),
                  SizedBox(width: context.widthCalculated(8)),
                  Text(
                    'Share ZIP',
                    style: tt.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: context.heightCalculated(12)),

          // ── New Backup Button ──────────────────────────────────────
          SizedBox(
            height: context.heightCalculated(56),
            child: OutlinedButton(
              onPressed: () =>
                  context.read<BackupBloc>().add(LoadBackupInfo()),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: cs.primary),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppThemeMetrics.radiusMd),
                ),
              ),
              child: Text(
                'New Backup',
                style: tt.titleMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
