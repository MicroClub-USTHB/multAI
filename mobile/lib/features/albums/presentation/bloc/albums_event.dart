part of 'albums_bloc.dart';

abstract class AlbumsEvent {}

class LoadAlbums extends AlbumsEvent {}

class CreateAlbum extends AlbumsEvent {
  final String name;
  CreateAlbum({required this.name});
}

class AddPhotosToAlbum extends AlbumsEvent {
  final String albumName;
  final List<String> photoPaths;
  AddPhotosToAlbum({required this.albumName, required this.photoPaths});
}

class DeleteAlbum extends AlbumsEvent {
  final String name;
  DeleteAlbum({required this.name});
}

class LoadAlbumPhotos extends AlbumsEvent {
  final String albumName;
  LoadAlbumPhotos({required this.albumName});
}
