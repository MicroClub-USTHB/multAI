import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure_handler.dart';
import '../../domain/entities/photo_entity.dart';
import '../../domain/usecases/get_my_photos_usecase.dart';
import '../../domain/usecases/get_event_photos_usecase.dart';
import '../../domain/usecases/get_photo_image_usecase.dart';


part 'gallery_event.dart';
part 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final GetMyPhotosUseCase _getMyPhotos;
  final GetEventPhotosUseCase _getEventPhotos;
  final GetPhotoImageUseCase _getPhotoImage;
  final FailureHandler _failureHandler;

  GalleryBloc({
    required GetMyPhotosUseCase getMyPhotos,
    required GetEventPhotosUseCase getEventPhotos,
    required GetPhotoImageUseCase getPhotoImage,
    FailureHandler? failureHandler,
  }) : _getMyPhotos = getMyPhotos,
       _getEventPhotos = getEventPhotos,
       _getPhotoImage = getPhotoImage,
       _failureHandler = failureHandler ?? FailureHandler.instance,
       super(GalleryInitial()) {
    on<LoadAllPhotos>(_onLoadAll);
    on<LoadEventPhotos>(_onLoadEvent);
    on<LoadPhotoImage>(_onLoadImage);
    on<RefreshGallery>(_onRefresh);
  }

  Future<void> _onLoadAll(
    LoadAllPhotos event,
    Emitter<GalleryState> emit,
  ) async {
    emit(GalleryLoading());

    final result = await _getMyPhotos(
      GetMyPhotosParams(limit: event.limit, offset: event.offset),
    );

    result.fold(
      (failure) => emit(GalleryError(message: _failureHandler.getUserFriendlyMessage(failure))),
      (photos) {
        emit(GalleryLoaded(allPhotos: photos));
        for (final photo in photos.take(20)) {
          add(LoadPhotoImage(photoId: photo.id));
        }
      },
    );
  }

  Future<void> _onLoadEvent(
    LoadEventPhotos event,
    Emitter<GalleryState> emit,
  ) async {
    final current = state;
    if (current is! GalleryLoaded) return;

    final result = await _getEventPhotos(
      GetEventPhotosParams(
        eventId: event.eventId,
        limit: event.limit,
        offset: event.offset,
      ),
    );

    result.fold(
      (failure) => emit(GalleryError(message: _failureHandler.getUserFriendlyMessage(failure))),
      (data) {
        emit(current.copyWith(eventPhotos: data.items, eventTotal: data.total));
        for (final photo in data.items.take(20)) {
          add(LoadPhotoImage(photoId: photo.id));
        }
      },
    );
  }

  Future<void> _onLoadImage(
    LoadPhotoImage event,
    Emitter<GalleryState> emit,
  ) async {
    final current = state;
    if (current is! GalleryLoaded) return;

    if (current.cachedPaths.containsKey(event.photoId)) return;

    final result = await _getPhotoImage(
      GetPhotoImageParams(photoId: event.photoId),
    );

    result.fold(
      (_) {},
      (localPath) {
        final updated = Map<String, String>.from(current.cachedPaths)
          ..[event.photoId] = localPath;
        emit(current.copyWith(cachedPaths: updated));
      },
    );
  }

  Future<void> _onRefresh(
    RefreshGallery event,
    Emitter<GalleryState> emit,
  ) async {
    add(LoadAllPhotos());
  }
}
