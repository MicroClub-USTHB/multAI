import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/error_presentation.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/responsive_extensions.dart';
import '../../../../core/extensions/snackbar_extensions.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/theme/theme.dart';
import '../../../gallery/domain/entities/photo_entity.dart';
import '../../../gallery/presentation/bloc/gallery_bloc.dart';
import '../../../gallery/presentation/screens/widgets/pictures_grid.dart';
import 'package:multai_mobile/core/theme/app_palette.dart';

class EventPhotosScreen extends StatefulWidget {
  final String eventId;
  final String eventName;

  const EventPhotosScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<EventPhotosScreen> createState() => _EventPhotosScreenState();
}

class _EventPhotosScreenState extends State<EventPhotosScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GalleryBloc>().add(LoadEventPhotos(eventId: widget.eventId));
  }

  @override
  Widget build(BuildContext context) {
    final tt = context.textTheme;
    final cs = context.theme.colorScheme;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        title: Text(widget.eventName, style: tt.headlineMedium),
      ),
      body: BlocConsumer<GalleryBloc, GalleryState>(
        listener: (context, state) {
          if (state is GalleryError) {
            context.showErrorSnackBar(state.errorPresentation.description);
          }
        },
        builder: (context, state) {
          if (state is GalleryLoading) {
            return Center(child: CircularProgressIndicator(color: cs.primary));
          }

          if (state is GalleryError) {
            final p = state.errorPresentation;
            return ErrorStateView(
              title: p.title,
              description: p.description,
              illustration: p.illustration,
              actionLabel: p.actionLabel,
              onAction: p.action == ErrorAction.retry
                  ? () => context.read<GalleryBloc>().add(
                      LoadEventPhotos(eventId: widget.eventId),
                    )
                  : p.action == ErrorAction.goBack
                  ? () => Navigator.of(context).pop()
                  : null,
            );
          }

          final photos = state is GalleryLoaded
              ? state.eventPhotos
              : <PhotoEntity>[];
          final cachedPaths = state is GalleryLoaded
              ? state.cachedPaths
              : <String, String>{};

          if (photos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: context.iconSize() * 3,
                    color: context.colors.secondaryText.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No photos for this event yet',
                    style: tt.titleMedium?.copyWith(
                      color: context.colors.secondaryText,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: cs.primary,
            onRefresh: () async => context.read<GalleryBloc>().add(
              LoadEventPhotos(eventId: widget.eventId),
            ),
            child: PicturesGrid(photos: photos, cachedPaths: cachedPaths),
          );
        },
      ),
    );
  }
}
