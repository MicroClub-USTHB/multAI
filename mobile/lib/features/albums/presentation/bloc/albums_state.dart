part of 'albums_bloc.dart';

abstract class AlbumsState {}

class AlbumsInitial extends AlbumsState {}

class AlbumsLoading extends AlbumsState {}

class AlbumsLoaded extends AlbumsState {
  final List<AlbumEntity> albums;
  AlbumsLoaded({required this.albums});
}

class AlbumPhotosLoaded extends AlbumsState {
  final String albumName;
  final List<String> photoPaths;
  AlbumPhotosLoaded({required this.albumName, required this.photoPaths});
}

class AlbumsError extends AlbumsState {
  final ErrorPresentation errorPresentation;
  AlbumsError({required this.errorPresentation});
}

class AlbumsOperationSuccess extends AlbumsState {
  final String message;
  final List<AlbumEntity>? albums;
  AlbumsOperationSuccess({required this.message, this.albums});
}

class AlbumsPhotoAdding extends AlbumsState {
  final String albumName;
  AlbumsPhotoAdding({required this.albumName});
}
