import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:multai_mobile/core/errors/failure.dart';
import 'package:multai_mobile/core/errors/failure_handler.dart';
import 'package:multai_mobile/features/face_enrollment/domain/entities/face_photo_entity.dart';
import 'package:multai_mobile/features/face_enrollment/domain/usecases/upload_face_photos_usecase.dart';
import 'package:multai_mobile/features/face_enrollment/domain/usecases/save_enrollment_done_usecase.dart';
import 'package:multai_mobile/features/face_enrollment/presentation/bloc/face_enrollment_bloc.dart';

class MockUploadUseCase extends Mock implements UploadFacePhotosUseCase {}
class MockSaveUseCase extends Mock implements SaveEnrollmentDoneUseCase {}
class MockFailureHandler extends Mock implements FailureHandler {}

class FakeFailure extends Fake implements Failure {}

void main() {
  late MockUploadUseCase uploadUseCase;
  late MockSaveUseCase saveUseCase;
  late MockFailureHandler failureHandler;
  late FaceEnrollmentBloc bloc;

  setUpAll(() {
    registerFallbackValue(FakeFailure());
    registerFallbackValue(UploadFacePhotosParams(photos: []));
  });

  setUp(() {
    uploadUseCase = MockUploadUseCase();
    saveUseCase = MockSaveUseCase();
    failureHandler = MockFailureHandler();

    when(() => failureHandler.getUserFriendlyMessage(any()))
        .thenReturn('Something went wrong');

    bloc = FaceEnrollmentBloc(
      uploadFacePhotos: uploadUseCase,
      saveEnrollmentDone: saveUseCase,
      failureHandler: failureHandler,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('EnrollmentSubmitted', () {
    blocTest<FaceEnrollmentBloc, FaceEnrollmentState>(
      'rejects when required photos are missing',
      build: () => bloc,
      act: (bloc) => bloc.add(EnrollmentSubmitted()),
      expect: () => [],
    );

    blocTest<FaceEnrollmentBloc, FaceEnrollmentState>(
      'emits [submitting, success] on valid upload',
      seed: () => FaceEnrollmentState(photos: {
        FacePhotoType.frontal: '/tmp/frontal.jpg',
        FacePhotoType.leftProfile: '/tmp/left.jpg',
        FacePhotoType.rightProfile: '/tmp/right.jpg',
      }),
      build: () {
        when(() => uploadUseCase(any())).thenAnswer(
          (_) async => const Right(null),
        );
        when(() => saveUseCase()).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(EnrollmentSubmitted()),
      expect: () => [
        predicate<FaceEnrollmentState>(
          (s) => s.status == EnrollmentStatus.submitting,
        ),
        predicate<FaceEnrollmentState>(
          (s) => s.status == EnrollmentStatus.success,
        ),
      ],
      verify: (_) {
        verify(() => uploadUseCase(any())).called(1);
        verify(() => saveUseCase()).called(1);
      },
    );

    blocTest<FaceEnrollmentBloc, FaceEnrollmentState>(
      'emits [submitting, failure] on upload error',
      seed: () => FaceEnrollmentState(photos: {
        FacePhotoType.frontal: '/tmp/frontal.jpg',
        FacePhotoType.leftProfile: '/tmp/left.jpg',
        FacePhotoType.rightProfile: '/tmp/right.jpg',
      }),
      build: () {
        when(() => uploadUseCase(any())).thenAnswer(
          (_) async => Left(ServerFailure('Upload failed')),
        );
        return bloc;
      },
      act: (bloc) => bloc.add(EnrollmentSubmitted()),
      expect: () => [
        predicate<FaceEnrollmentState>(
          (s) => s.status == EnrollmentStatus.submitting,
        ),
        // A failed submit must stay editable so the user can retry; the
        // terminal `failure` status would disable the submit button.
        predicate<FaceEnrollmentState>(
          (s) =>
              s.status == EnrollmentStatus.editing &&
              s.submitError != null,
        ),
      ],
    );

    blocTest<FaceEnrollmentBloc, FaceEnrollmentState>(
      'emits [submitting, failure] when saveEnrollmentDone throws',
      seed: () => FaceEnrollmentState(photos: {
        FacePhotoType.frontal: '/tmp/frontal.jpg',
        FacePhotoType.leftProfile: '/tmp/left.jpg',
        FacePhotoType.rightProfile: '/tmp/right.jpg',
      }),
      build: () {
        when(() => uploadUseCase(any())).thenAnswer(
          (_) async => const Right(null),
        );
        when(() => saveUseCase()).thenThrow(Exception('Save failed'));
        return bloc;
      },
      act: (bloc) => bloc.add(EnrollmentSubmitted()),
      expect: () => [
        predicate<FaceEnrollmentState>(
          (s) => s.status == EnrollmentStatus.submitting,
        ),
        predicate<FaceEnrollmentState>(
          (s) =>
              s.status == EnrollmentStatus.editing &&
              s.submitError != null,
        ),
      ],
    );

    blocTest<FaceEnrollmentBloc, FaceEnrollmentState>(
      'rejects when already submitting',
      seed: () => FaceEnrollmentState(
        status: EnrollmentStatus.submitting,
        photos: {
          FacePhotoType.frontal: '/tmp/frontal.jpg',
          FacePhotoType.leftProfile: '/tmp/left.jpg',
          FacePhotoType.rightProfile: '/tmp/right.jpg',
        },
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(EnrollmentSubmitted()),
      expect: () => [],
    );
  });

  group('PhotoRemoved', () {
    blocTest<FaceEnrollmentBloc, FaceEnrollmentState>(
      'removes photo from state',
      seed: () => FaceEnrollmentState(photos: {
        FacePhotoType.frontal: '/tmp/frontal.jpg',
      }),
      build: () => bloc,
      act: (bloc) => bloc.add(PhotoRemoved(type: FacePhotoType.frontal)),
      expect: () => [
        predicate<FaceEnrollmentState>(
          (s) => !s.photos.containsKey(FacePhotoType.frontal),
        ),
      ],
    );

    blocTest<FaceEnrollmentBloc, FaceEnrollmentState>(
      'rejects when submitting',
      seed: () => FaceEnrollmentState(
        status: EnrollmentStatus.submitting,
        photos: {FacePhotoType.frontal: '/tmp/frontal.jpg'},
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(PhotoRemoved(type: FacePhotoType.frontal)),
      expect: () => [],
    );
  });

  group('ResetEnrollment', () {
    blocTest<FaceEnrollmentBloc, FaceEnrollmentState>(
      'resets to initial state',
      seed: () => FaceEnrollmentState(
        status: EnrollmentStatus.success,
        photos: {
          FacePhotoType.frontal: '/tmp/frontal.jpg',
          FacePhotoType.leftProfile: '/tmp/left.jpg',
          FacePhotoType.rightProfile: '/tmp/right.jpg',
        },
      ),
      build: () => bloc,
      act: (bloc) => bloc.add(ResetEnrollment()),
      expect: () => [
        const FaceEnrollmentState(),
      ],
    );
  });
}
