import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_handler.dart';
import '../../../../core/errors/error_presentation.dart';
import '../../../../core/network/connectivity_service.dart';
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
  final ConnectivityService _connectivityService;
  final FailureHandler _failureHandler;
  StreamSubscription<bool>? _connectivitySub;
  final Set<String> _loadingImageIds = {};

  GalleryBloc({
    required GetMyPhotosUseCase getMyPhotos,
    required GetEventPhotosUseCase getEventPhotos,
    required GetPhotoImageUseCase getPhotoImage,
    required ConnectivityService connectivityService,
    FailureHandler? failureHandler,
  }) : _getMyPhotos = getMyPhotos,
       _getEventPhotos = getEventPhotos,
       _getPhotoImage = getPhotoImage,
       _connectivityService = connectivityService,
       _failureHandler = failureHandler ?? FailureHandler.instance,
       super(GalleryInitial()) {
    on<LoadAllPhotos>(_onLoadAll);
    on<LoadEventPhotos>(_onLoadEvent);
    on<LoadPhotoImage>(_onLoadImage);
    on<RefreshGallery>(_onRefresh);
    _connectivitySub = _connectivityService.onStatusChanged.listen((online) {
      if (online) add(LoadAllPhotos());
    });
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
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
      (failure) {
        if (failure is NetworkFailure) {
          emit(GalleryOffline());
        } else {
          _failureHandler.logFailure(failure, 'GalleryBloc');
          emit(
            GalleryError(
              errorPresentation: _failureHandler.getErrorPresentation(failure),
            ),
          );
        }
      },
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
    if (current is! GalleryLoaded) {
      emit(GalleryLoading());
    }

    final result = await _getEventPhotos(
      GetEventPhotosParams(
        eventId: event.eventId,
        limit: event.limit,
        offset: event.offset,
      ),
    );

    result.fold(
      (failure) {
        if (failure is NetworkFailure) {
          emit(GalleryOffline());
        } else {
          _failureHandler.logFailure(failure, 'GalleryBloc');
          emit(
            GalleryError(
              errorPresentation: _failureHandler.getErrorPresentation(failure),
            ),
          );
        }
      },
      (data) {
        emit(
          current is GalleryLoaded
              ? current.copyWith(
                  eventPhotos: data.items,
                  eventTotal: data.total,
                )
              : GalleryLoaded(
                  allPhotos: const [],
                  eventPhotos: data.items,
                  eventTotal: data.total,
                ),
        );
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
    if (_loadingImageIds.contains(event.photoId)) return;
    _loadingImageIds.add(event.photoId);

    try {
      final result = await _getPhotoImage(
        GetPhotoImageParams(photoId: event.photoId),
      );

      final latest = state;
      if (latest is! GalleryLoaded) return;

      result.fold((_) {}, (localPath) {
        final updated = Map<String, String>.from(latest.cachedPaths)
          ..[event.photoId] = localPath;
        emit(latest.copyWith(cachedPaths: updated));
      });
    } finally {
      _loadingImageIds.remove(event.photoId);
    }
  }

  Future<void> _onRefresh(
    RefreshGallery event,
    Emitter<GalleryState> emit,
  ) async {
    add(LoadAllPhotos());
  }
}
