import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multai_mobile/core/extensions/snackbar_extensions.dart';
import 'package:multai_mobile/core/extensions/context_extensions.dart';
import 'package:multai_mobile/core/extensions/responsive_extensions.dart';
import 'package:multai_mobile/core/theme/theme.dart';
import 'package:multai_mobile/di/injection_container.dart' as di;
import '../bloc/albums_bloc.dart';

class AlbumDetailScreen extends StatelessWidget {
  final String albumName;

  const AlbumDetailScreen({super.key, required this.albumName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AlbumsBloc(
        getAlbums: di.sl(),
        createAlbum: di.sl(),
        addPhotos: di.sl(),
        repository: di.sl(),
      )..add(LoadAlbumPhotos(albumName: albumName)),
      child: _AlbumDetailView(albumName: albumName),
    );
  }
}

class _AlbumDetailView extends StatelessWidget {
  final String albumName;

  const _AlbumDetailView({required this.albumName});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AlbumsBloc, AlbumsState>(
      listener: (context, state) {
        if (state is AlbumsError) {
          context.showErrorSnackBar(state.errorPresentation.description);
        }
        if (state is AlbumsOperationSuccess) {
          context.showSuccessSnackBar(state.message);
          context.read<AlbumsBloc>().add(LoadAlbumPhotos(albumName: albumName));
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
            title: Text(albumName, style: tt.headlineMedium),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _pickPhotos(context),
            backgroundColor: cs.primary,
            child: Icon(
              Icons.add_photo_alternate_outlined,
              color: Colors.white,
            ),
          ),
          body: _buildBody(context, state, cs),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, AlbumsState state, ColorScheme cs) {
    final tt = context.textTheme;

    if (state is AlbumsPhotoAdding) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: cs.primary),
            SizedBox(height: context.heightCalculated(16)),
            Text(
              'Adding photos...',
              style: tt.bodyMedium?.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    final photos = state is AlbumPhotosLoaded ? state.photoPaths : <String>[];

    if (photos.isEmpty) {
      return _buildEmpty(context, tt, cs);
    }

    return GridView.builder(
      padding: EdgeInsets.all(context.hPadding()),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: context.widthCalculated(4),
        mainAxisSpacing: context.heightCalculated(4),
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppThemeMetrics.radiusSm),
          child: Image.file(
            File(photos[index]),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => Container(
              color: AppThemeColors.surface,
              child: Icon(
                Icons.broken_image_outlined,
                color: AppThemeColors.secondaryText,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmpty(BuildContext context, TextTheme tt, ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: context.iconSize() * 3,
            color: AppTheme.secondaryTextColor.withValues(alpha: 0.4),
          ),
          SizedBox(height: context.heightCalculated(16)),
          Text(
            'This album is empty',
            style: tt.titleMedium?.copyWith(color: AppTheme.secondaryTextColor),
          ),
          SizedBox(height: context.heightCalculated(8)),
          Text(
            'Tap + to add photos from your device',
            style: tt.bodyMedium?.copyWith(color: AppTheme.hintTextColor),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhotos(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (picked.isNotEmpty && context.mounted) {
        final paths = picked.map((f) => f.path).toList();
        context.read<AlbumsBloc>().add(
          AddPhotosToAlbum(albumName: albumName, photoPaths: paths),
        );
      }
    } catch (e) {
      if (context.mounted) {
        context.showErrorSnackBar('Could not pick photos: $e');
      }
    }
  }
}
