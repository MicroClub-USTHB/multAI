import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failure_handler.dart';
import '../../../../core/errors/error_presentation.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/album_entity.dart';
import '../../domain/usecases/get_albums_usecase.dart';
import '../../domain/usecases/create_album_usecase.dart';
import '../../domain/usecases/add_photos_to_album_usecase.dart';
import '../../domain/repositories/album_repository.dart';

part 'albums_event.dart';
part 'albums_state.dart';

class AlbumsBloc extends Bloc<AlbumsEvent, AlbumsState> {
  final GetAlbumsUseCase _getAlbums;
  final CreateAlbumUseCase _createAlbum;
  final AddPhotosToAlbumUseCase _addPhotos;
  final AlbumRepository _repository;
  final FailureHandler _failureHandler;

  AlbumsBloc({
    required GetAlbumsUseCase getAlbums,
    required CreateAlbumUseCase createAlbum,
    required AddPhotosToAlbumUseCase addPhotos,
    required AlbumRepository repository,
    FailureHandler? failureHandler,
  }) : _getAlbums = getAlbums,
       _createAlbum = createAlbum,
       _addPhotos = addPhotos,
       _repository = repository,
       _failureHandler = failureHandler ?? FailureHandler.instance,
       super(AlbumsInitial()) {
    on<LoadAlbums>(_onLoadAlbums);
    on<CreateAlbum>(_onCreateAlbum);
    on<AddPhotosToAlbum>(_onAddPhotos);
    on<DeleteAlbum>(_onDeleteAlbum);
    on<LoadAlbumPhotos>(_onLoadAlbumPhotos);
  }

  Future<void> _onLoadAlbums(
    LoadAlbums event,
    Emitter<AlbumsState> emit,
  ) async {
    emit(AlbumsLoading());
    final result = await _getAlbums(NoParams());
    result.fold((failure) {
      emit(
        AlbumsError(
          errorPresentation: _failureHandler.getErrorPresentation(failure),
        ),
      );
    }, (albums) => emit(AlbumsLoaded(albums: albums)));
  }

  Future<void> _onCreateAlbum(
    CreateAlbum event,
    Emitter<AlbumsState> emit,
  ) async {
    final result = await _createAlbum(CreateAlbumParams(name: event.name));
    await result.fold(
      (failure) async {
        emit(
          AlbumsError(
            errorPresentation: _failureHandler.getErrorPresentation(failure),
          ),
        );
      },
      (album) async {
        final albumsResult = await _getAlbums(NoParams());
        albumsResult.fold(
          (failure) => emit(
            AlbumsError(
              errorPresentation: _failureHandler.getErrorPresentation(failure),
            ),
          ),
          (albums) => emit(
            AlbumsOperationSuccess(
              message: 'Album "${album.name}" created',
              albums: albums,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onAddPhotos(
    AddPhotosToAlbum event,
    Emitter<AlbumsState> emit,
  ) async {
    emit(AlbumsPhotoAdding(albumName: event.albumName));
    final result = await _addPhotos(
      AddPhotosParams(albumName: event.albumName, photoPaths: event.photoPaths),
    );
    await result.fold(
      (failure) async {
        emit(
          AlbumsError(
            errorPresentation: _failureHandler.getErrorPresentation(failure),
          ),
        );
      },
      (_) async {
        final albumsResult = await _getAlbums(NoParams());
        albumsResult.fold(
          (failure) => emit(
            AlbumsError(
              errorPresentation: _failureHandler.getErrorPresentation(failure),
            ),
          ),
          (albums) => emit(
            AlbumsOperationSuccess(
              message:
                  '${event.photoPaths.length} photos added to "${event.albumName}"',
              albums: albums,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onDeleteAlbum(
    DeleteAlbum event,
    Emitter<AlbumsState> emit,
  ) async {
    final result = await _repository.deleteAlbum(event.name);
    await result.fold(
      (failure) async {
        emit(
          AlbumsError(
            errorPresentation: _failureHandler.getErrorPresentation(failure),
          ),
        );
      },
      (_) async {
        final albumsResult = await _getAlbums(NoParams());
        albumsResult.fold(
          (failure) => emit(
            AlbumsError(
              errorPresentation: _failureHandler.getErrorPresentation(failure),
            ),
          ),
          (albums) => emit(
            AlbumsOperationSuccess(
              message: 'Album "${event.name}" deleted',
              albums: albums,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onLoadAlbumPhotos(
    LoadAlbumPhotos event,
    Emitter<AlbumsState> emit,
  ) async {
    final result = await _repository.getAlbumPhotos(event.albumName);
    result.fold(
      (failure) {
        emit(
          AlbumsError(
            errorPresentation: _failureHandler.getErrorPresentation(failure),
          ),
        );
      },
      (photos) => emit(
        AlbumPhotosLoaded(albumName: event.albumName, photoPaths: photos),
      ),
    );
  }
}
