import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:multai_mobile/l10n/app_localizations.dart';
import '../../../../core/extensions/snackbar_extensions.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../core/errors/error_presentation.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../domain/entities/photo_entity.dart';
import '../../../../core/theme/theme.dart';
import '../bloc/gallery_bloc.dart';
import 'widgets/pictures_grid.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // trigger load
    context.read<GalleryBloc>().add(LoadAllPhotos());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<GalleryBloc, GalleryState>(
      listener: (context, state) {
        if (state is GalleryError) {
          context.showErrorSnackBar(state.errorPresentation.description);
        }
      },
      builder: (context, state) {
        if (state is GalleryError) {
          final p = state.errorPresentation;
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: ErrorStateView(
                title: p.title,
                description: p.description,
                illustration: p.illustration,
                actionLabel: p.actionLabel,
                onAction: p.action == ErrorAction.retry
                    ? () => context.read<GalleryBloc>().add(LoadAllPhotos())
                    : p.action == ErrorAction.signIn
                    ? () {
                        context.read<AuthBloc>().add(LogoutRequested());
                        context.go(AppRoutes.login);
                      }
                    : p.action == ErrorAction.goBack
                    ? () => context.pop()
                    : null,
              ),
            ),
          );
        }

        final allPhotos = state is GalleryLoaded
            ? state.allPhotos
            : <PhotoEntity>[];
        final soloPhotos = allPhotos.where((p) => p.isSolo).toList();
        final groupPhotos = allPhotos.where((p) => p.isGroup).toList();
        final cachedPaths = state is GalleryLoaded
            ? state.cachedPaths
            : <String, String>{};
        final isLoading = state is GalleryLoading;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            title: Text(l10n.galleryTitle, style: tt.headlineMedium),
          ),
          body: Column(
            children: [
              // ── Tab bar ──────────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: cs.primary,
                  dividerColor: cs.outlineVariant,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelPadding: EdgeInsets.symmetric(
                    vertical: context.heightCalculated(AppTheme.spacingSm),
                  ),
                  tabs: [
                    _buildTab(l10n.allPhotos, allPhotos.length, 0),
                    _buildTab(l10n.soloPhotos, soloPhotos.length, 1),
                    _buildTab(l10n.groupPhotos, groupPhotos.length, 2),
                  ],
                ),
              ),

              // ── Content ──────────────────────────────────────────────
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: cs.primary),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          RefreshIndicator(
                            color: cs.primary,
                            onRefresh: () async => context
                                .read<GalleryBloc>()
                                .add(RefreshGallery()),
                            child: allPhotos.isEmpty
                                ? _buildEmpty(context)
                                : PicturesGrid(
                                    photos: allPhotos,
                                    cachedPaths: cachedPaths,
                                  ),
                          ),
                          soloPhotos.isEmpty
                              ? _buildEmpty(context)
                              : PicturesGrid(
                                  photos: soloPhotos,
                                  cachedPaths: cachedPaths,
                                ),
                          groupPhotos.isEmpty
                              ? _buildEmpty(context)
                              : PicturesGrid(
                                  photos: groupPhotos,
                                  cachedPaths: cachedPaths,
                                ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTab(String title, int count, int index) {
    final cs = context.theme.colorScheme;
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        final isSelected = _tabController.index == index;
        final tt = context.textTheme;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.widthCalculated(AppTheme.spacingLg),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: tt.titleLarge?.copyWith(
                  color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
                ),
              ),
              SizedBox(width: context.widthCalculated(AppTheme.spacingSm)),
              Text(
                '$count',
                style: tt.bodyMedium?.copyWith(
                  color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final tt = context.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final cs = context.theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: context.iconSize() * 3,
            color: cs.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          SizedBox(height: context.heightCalculated(16)),
          Text(l10n.noPhotosYet, style: tt.titleMedium),
        ],
      ),
    );
  }
}
