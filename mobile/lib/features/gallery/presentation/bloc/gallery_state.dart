part of 'gallery_bloc.dart';

abstract class GalleryState {}

class GalleryInitial extends GalleryState {}

class GalleryLoading extends GalleryState {}

class GalleryLoaded extends GalleryState {
  final List<PhotoEntity> allPhotos;
  final List<PhotoEntity> eventPhotos;
  final int eventTotal;
  final Map<String, String> cachedPaths;

  GalleryLoaded({
    required this.allPhotos,
    this.eventPhotos = const [],
    this.eventTotal = 0,
    this.cachedPaths = const {},
  });

  GalleryLoaded copyWith({
    List<PhotoEntity>? allPhotos,
    List<PhotoEntity>? eventPhotos,
    int? eventTotal,
    Map<String, String>? cachedPaths,
  }) {
    return GalleryLoaded(
      allPhotos: allPhotos ?? this.allPhotos,
      eventPhotos: eventPhotos ?? this.eventPhotos,
      eventTotal: eventTotal ?? this.eventTotal,
      cachedPaths: cachedPaths ?? this.cachedPaths,
    );
  }
}

class GalleryOffline extends GalleryState {
  final List<PhotoEntity> cachedPhotos;

  GalleryOffline({this.cachedPhotos = const []});
}

class GalleryError extends GalleryState {
  final ErrorPresentation errorPresentation;
  GalleryError({required this.errorPresentation});
}
