part of 'gallery_bloc.dart';

abstract class GalleryEvent {}

class LoadAllPhotos extends GalleryEvent {
  final int limit;
  final int offset;
  LoadAllPhotos({this.limit = 50, this.offset = 0});
}

class LoadEventPhotos extends GalleryEvent {
  final String eventId;
  final int limit;
  final int offset;
  LoadEventPhotos({required this.eventId, this.limit = 50, this.offset = 0});
}

class LoadPhotoImage extends GalleryEvent {
  final String photoId;
  LoadPhotoImage({required this.photoId});
}

class RefreshGallery extends GalleryEvent {}

class ResetGallery extends GalleryEvent {}
