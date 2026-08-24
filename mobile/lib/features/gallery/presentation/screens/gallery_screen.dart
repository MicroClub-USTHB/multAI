import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
    _tabController = TabController(length: 2, vsync: this);
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
            backgroundColor: AppTheme.backgroundColor,
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
        final eventPhotos = state is GalleryLoaded
            ? state.eventPhotos
            : <PhotoEntity>[];
        final cachedPaths = state is GalleryLoaded
            ? state.cachedPaths
            : <String, String>{};
        final isLoading = state is GalleryLoading;

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: AppTheme.backgroundColor,
            elevation: 0,
            title: Text('Gallery', style: tt.headlineMedium),
            actions: [
              // ── Search ──────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.search,
                    size: context.iconSize(),
                    color: cs.primary,
                  ),
                  onPressed: () {},
                ),
              ),
              // ── Filter ──────────────────────────────────────────────
              Container(
                margin: EdgeInsets.symmetric(
                  horizontal: context.widthCalculated(AppTheme.spacingSm),
                ),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.tune,
                    size: context.iconSize(),
                    color: cs.primary,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
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
                  dividerColor: AppTheme.inputBorderColor,
                  indicatorSize: TabBarIndicatorSize.label,
                  labelPadding: EdgeInsets.symmetric(
                    vertical: context.heightCalculated(AppTheme.spacingSm),
                  ),
                  tabs: [
                    _buildTab('All', allPhotos.length, 0),
                    _buildTab('Events', eventPhotos.length, 1),
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
                          eventPhotos.isEmpty
                              ? _buildEmpty(context)
                              : PicturesGrid(
                                  photos: eventPhotos,
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
                  color: isSelected
                      ? AppTheme.primaryTextColor
                      : AppTheme.secondaryTextColor,
                ),
              ),
              SizedBox(width: context.widthCalculated(AppTheme.spacingSm)),
              Text(
                '$count',
                style: tt.bodyMedium?.copyWith(
                  color: isSelected
                      ? AppTheme.primaryTextColor
                      : AppTheme.secondaryTextColor,
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

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: context.iconSize() * 3,
            color: AppTheme.secondaryTextColor.withValues(alpha: 0.4),
          ),
          SizedBox(height: context.heightCalculated(16)),
          Text(
            'No photos yet',
            style: tt.titleMedium?.copyWith(color: AppTheme.secondaryTextColor),
          ),
        ],
      ),
    );
  }
}
