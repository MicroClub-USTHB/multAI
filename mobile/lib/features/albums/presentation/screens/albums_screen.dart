import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:multai_mobile/core/extensions/snackbar_extensions.dart';
import 'package:multai_mobile/core/extensions/context_extensions.dart';
import 'package:multai_mobile/core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/router/app_routes.dart';
import 'package:multai_mobile/core/theme/theme.dart';
import 'package:multai_mobile/di/injection_container.dart' as di;
import '../bloc/albums_bloc.dart';
import '../widgets/album_card.dart';
import '../widgets/create_album_dialog.dart';

class AlbumsScreen extends StatelessWidget {
  const AlbumsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AlbumsBloc(
        getAlbums: di.sl(),
        createAlbum: di.sl(),
        addPhotos: di.sl(),
        repository: di.sl(),
      )..add(LoadAlbums()),
      child: const _AlbumsView(),
    );
  }
}

class _AlbumsView extends StatelessWidget {
  const _AlbumsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AlbumsBloc, AlbumsState>(
      listener: (context, state) {
        if (state is AlbumsError) {
          context.showErrorSnackBar(state.errorPresentation.description);
        }
        if (state is AlbumsOperationSuccess) {
          context.showSuccessSnackBar(state.message);
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
            title: Text('My Albums', style: tt.headlineMedium),
            actions: [
              Container(
                margin: EdgeInsets.only(
                  right: context.widthCalculated(AppTheme.spacingMd),
                ),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.add,
                    size: context.iconSize(),
                    color: cs.primary,
                  ),
                  onPressed: () => _showCreateAlbumDialog(context),
                ),
              ),
            ],
          ),
          body: _buildBody(context, state, cs),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AlbumsState state,
    ColorScheme cs,
  ) {
    final tt = context.textTheme;

    if (state is AlbumsLoading) {
      return Center(
        child: CircularProgressIndicator(color: cs.primary),
      );
    }

    final albums =
        state is AlbumsLoaded ? state.albums : <dynamic>[];

    if (albums.isEmpty) {
      return _buildEmpty(context, tt, cs);
    }

    return RefreshIndicator(
      color: cs.primary,
      onRefresh: () async =>
          context.read<AlbumsBloc>().add(LoadAlbums()),
      child: GridView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: context.hPadding(),
          vertical: context.heightCalculated(16),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: context.widthCalculated(12),
          mainAxisSpacing: context.heightCalculated(12),
          childAspectRatio: 0.85,
        ),
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
          return AlbumCard(
            album: album,
            onTap: () {
              context.push(
                '${AppRoutes.albumDetail}?name=${Uri.encodeComponent(album.name)}',
              );
            },
            onDelete: () => _confirmDelete(context, album),
          );
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, TextTheme tt, ColorScheme cs) {
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
            'No albums yet',
            style: tt.titleMedium?.copyWith(
              color: AppTheme.secondaryTextColor,
            ),
          ),
          SizedBox(height: context.heightCalculated(8)),
          Text(
            'Create your first album to organize photos',
            style: tt.bodyMedium?.copyWith(
              color: AppTheme.hintTextColor,
            ),
          ),
          SizedBox(height: context.heightCalculated(24)),
          SizedBox(
            height: context.heightCalculated(48),
            child: FilledButton.icon(
              onPressed: () => _showCreateAlbumDialog(context),
              icon: Icon(Icons.add, size: context.iconSize()),
              label: Text('Create Album'),
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppThemeMetrics.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateAlbumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => CreateAlbumDialog(
        onCreate: (name) {
          context.read<AlbumsBloc>().add(CreateAlbum(name: name));
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, dynamic album) {
    final tt = context.textTheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Album'),
        content: Text(
          'Are you sure you want to delete "${album.name}"? '
          'Photos in the device gallery will not be affected.',
          style: tt.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context
                  .read<AlbumsBloc>()
                  .add(DeleteAlbum(name: album.name));
            },
            style: FilledButton.styleFrom(
              backgroundColor: context.theme.colorScheme.error,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
