import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/extensions/responsive_extensions.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/theme/theme.dart';
import '../../../domain/entities/photo_entity.dart';
import '../../bloc/gallery_bloc.dart';
import 'photo_grid_item.dart';

class PicturesGrid extends StatelessWidget {
  final List<PhotoEntity> photos;
  final Map<String, String> cachedPaths;

  const PicturesGrid({
    super.key,
    required this.photos,
    required this.cachedPaths,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = (context.width / context.widthCalculated(160))
        .floor()
        .clamp(1, 6);

    return GridView.builder(
      padding: EdgeInsets.all(AppTheme.spacingMd),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppTheme.spacingSm,
        mainAxisSpacing: AppTheme.spacingSm,
        childAspectRatio: 1,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        final localPath = cachedPaths[photo.id];

        if (localPath == null) {
          context.read<GalleryBloc>().add(LoadPhotoImage(photoId: photo.id));
        }

        return PhotoGridItem(
          photoId: photo.id,
          localPath: localPath,
          gridItemSize: context.widthCalculated(160),
        );
      },
    );
  }
}
