import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_theme_metrics.dart';
import '../../../../di/injection_container.dart';
import '../../../gallery/domain/usecases/get_event_photos_usecase.dart';
import '../../../gallery/domain/usecases/get_photo_image_usecase.dart';

/// Displays the first photo of an event as a small cover image.
///
/// Events do not carry a cover id in the API, so the cover is resolved by
/// fetching the event's first photo and then its cached image path.
class EventCoverImage extends StatefulWidget {
  final String eventId;
  final double width;
  final double height;
  final double borderRadius;
  final BoxFit fit;

  const EventCoverImage({
    super.key,
    required this.eventId,
    required this.width,
    required this.height,
    this.borderRadius = AppThemeMetrics.radiusSm,
    this.fit = BoxFit.cover,
  });

  @override
  State<EventCoverImage> createState() => _EventCoverImageState();
}

class _EventCoverImageState extends State<EventCoverImage> {
  late Future<String?> _pathFuture;

  @override
  void initState() {
    super.initState();
    _pathFuture = _loadCover();
  }

  @override
  void didUpdateWidget(covariant EventCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.eventId != widget.eventId) {
      _pathFuture = _loadCover();
    }
  }

  Future<String?> _loadCover() async {
    final photos = await sl<GetEventPhotosUseCase>()(
      GetEventPhotosParams(eventId: widget.eventId, limit: 1),
    );

    final photoId = photos.fold<String?>((_) => null, (data) {
      return data.items.isEmpty ? null : data.items.first.id;
    });
    if (photoId == null) return null;

    final image = await sl<GetPhotoImageUseCase>()(
      GetPhotoImageParams(photoId: photoId),
    );
    return image.fold((_) => null, (path) => path);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: FutureBuilder<String?>(
          future: _pathFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return _placeholder(
                colors,
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primaryAccent,
                  ),
                ),
              );
            }

            final path = snapshot.data;
            if (path == null) {
              return _placeholder(
                colors,
                child: Icon(
                  Icons.photo_outlined,
                  color: colors.secondaryText.withValues(alpha: 0.5),
                  size: widget.height * 0.4,
                ),
              );
            }

            return Image.file(
              File(path),
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              errorBuilder: (context, error, stackTrace) => _placeholder(
                colors,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: colors.secondaryText.withValues(alpha: 0.5),
                  size: widget.height * 0.4,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _placeholder(AppPalette colors, {required Widget child}) {
    return Container(
      color: colors.surfaceHigh,
      alignment: Alignment.center,
      child: child,
    );
  }
}
