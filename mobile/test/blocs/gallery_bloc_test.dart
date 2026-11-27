import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multai_mobile/core/errors/failure.dart';
import 'package:multai_mobile/features/gallery/domain/usecases/get_my_photos_usecase.dart';
import 'package:multai_mobile/core/network/connectivity_service.dart';
import 'package:multai_mobile/features/gallery/domain/entities/photo_entity.dart';
import 'package:multai_mobile/features/gallery/domain/usecases/get_event_photos_usecase.dart';
import 'package:multai_mobile/features/gallery/domain/usecases/get_photo_image_usecase.dart';
import 'package:multai_mobile/features/gallery/presentation/bloc/gallery_bloc.dart';

class MockGetMyPhotos extends Mock implements GetMyPhotosUseCase {}

class MockGetEventPhotos extends Mock implements GetEventPhotosUseCase {}

class MockGetPhotoImage extends Mock implements GetPhotoImageUseCase {}

class FakeConnectivityService extends Mock implements ConnectivityService {
  final _controller = StreamController<bool>.broadcast();
  bool _connected = false;

  @override
  Stream<bool> get onStatusChanged => _controller.stream;

  @override
  bool get isConnected => _connected;

  void emitOnline(bool online) {
    _connected = online;
    _controller.add(online);
  }

  void closeStream() => _controller.close();
}

PhotoEntity _photo({String id = '1'}) => PhotoEntity(
  id: id,
  eventId: 'e1',
  visibility: PhotoVisibility.public,
  status: PhotoStatus.approved,
  createdAt: DateTime(2026, 6, 1),
);

void main() {
  late FakeConnectivityService connectivity;
  late MockGetMyPhotos mockGetMyPhotos;
  late MockGetEventPhotos mockGetEventPhotos;
  late MockGetPhotoImage mockGetPhotoImage;
  late GalleryBloc bloc;

  setUpAll(() {
    registerFallbackValue(GetMyPhotosParams());
    registerFallbackValue(GetPhotoImageParams(photoId: 'test'));
  });

  setUp(() {
    connectivity = FakeConnectivityService();
    mockGetMyPhotos = MockGetMyPhotos();
    mockGetEventPhotos = MockGetEventPhotos();
    mockGetPhotoImage = MockGetPhotoImage();
    when(
      () => mockGetPhotoImage(any()),
    ).thenAnswer((_) async => Right('/tmp/test.jpg'));
    bloc = GalleryBloc(
      getMyPhotos: mockGetMyPhotos,
      getEventPhotos: mockGetEventPhotos,
      getPhotoImage: mockGetPhotoImage,
      connectivityService: connectivity,
    );
  });

  tearDown(() async {
    await bloc.close();
    connectivity.closeStream();
  });

  group('GalleryBloc — offline scenarios', () {
    test('offline-with-cache → emits GalleryLoaded (not Offline)', () async {
      final cached = [_photo(id: '1'), _photo(id: '2')];
      when(() => mockGetMyPhotos(any())).thenAnswer((_) async => Right(cached));

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<GalleryLoading>(), isA<GalleryLoaded>()]),
      );
      bloc.add(LoadAllPhotos());
      await future;
    });

    test('offline-with-no-cache → emits GalleryOffline', () async {
      when(() => mockGetMyPhotos(any())).thenAnswer(
        (_) async => Left(const NetworkFailure('No internet connection')),
      );

      final future = expectLater(
        bloc.stream,
        emitsInOrder([isA<GalleryLoading>(), isA<GalleryOffline>()]),
      );
      bloc.add(LoadAllPhotos());
      await future;
    });

    test('reconnect triggers another load', () async {
      int callCount = 0;
      when(() => mockGetMyPhotos(any())).thenAnswer((_) async {
        callCount++;
        return Right(<PhotoEntity>[]);
      });

      final future1 = expectLater(
        bloc.stream,
        emitsInOrder([isA<GalleryLoading>(), isA<GalleryLoaded>()]),
      );
      bloc.add(LoadAllPhotos());
      await future1;
      expect(callCount, 1);

      final future2 = expectLater(
        bloc.stream,
        emitsInOrder([isA<GalleryLoading>(), isA<GalleryLoaded>()]),
      );
      connectivity.emitOnline(true);
      await future2;
      expect(callCount, 2);
    });

    test('close() cancels connectivity subscription', () async {
      int callCount = 0;
      when(() => mockGetMyPhotos(any())).thenAnswer((_) async {
        callCount++;
        return Right(<PhotoEntity>[]);
      });

      final future1 = expectLater(
        bloc.stream,
        emitsInOrder([isA<GalleryLoading>(), isA<GalleryLoaded>()]),
      );
      bloc.add(LoadAllPhotos());
      await future1;

      await bloc.close();

      connectivity.emitOnline(true);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(callCount, 1);
    });
  });
}
