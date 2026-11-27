import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multai_mobile/core/errors/failure.dart';
import 'package:multai_mobile/features/face_enrollment/data/datasources/face_enrollment_local_datasource.dart';
import 'package:multai_mobile/features/face_enrollment/data/datasources/face_enrollment_remote_datasource.dart';
import 'package:multai_mobile/features/face_enrollment/data/repositories/face_enrollment_repository_impl.dart';

class MockFaceEnrollmentRemoteDataSource extends Mock
    implements FaceEnrollmentRemoteDataSource {}

class MockFaceEnrollmentLocalDataSource extends Mock
    implements FaceEnrollmentLocalDataSource {}

void main() {
  late MockFaceEnrollmentRemoteDataSource remote;
  late MockFaceEnrollmentLocalDataSource local;
  late FaceEnrollmentRepositoryImpl repository;

  setUp(() {
    remote = MockFaceEnrollmentRemoteDataSource();
    local = MockFaceEnrollmentLocalDataSource();
    repository = FaceEnrollmentRepositoryImpl(
      remoteDataSource: remote,
      localDataSource: local,
    );
  });

  group('isEnrollmentDone', () {
    test('uses the local flag without hitting the network', () async {
      when(() => local.isEnrollmentDone()).thenAnswer((_) async => true);

      expect(await repository.isEnrollmentDone(), isTrue);
      verifyNever(() => remote.isEnrollmentDoneOnServer());
    });

    test('recognises an account enrolled elsewhere via the server', () async {
      when(() => local.isEnrollmentDone()).thenAnswer((_) async => false);
      when(
        () => remote.isEnrollmentDoneOnServer(),
      ).thenAnswer((_) async => true);
      when(() => local.saveEnrollmentDone()).thenAnswer((_) async {});

      expect(await repository.isEnrollmentDone(), isTrue);
      verify(() => local.saveEnrollmentDone()).called(1);
    });

    test('returns false when the server reports no enrollment', () async {
      when(() => local.isEnrollmentDone()).thenAnswer((_) async => false);
      when(
        () => remote.isEnrollmentDoneOnServer(),
      ).thenAnswer((_) async => false);

      expect(await repository.isEnrollmentDone(), isFalse);
      verifyNever(() => local.saveEnrollmentDone());
    });

    test('falls back to false when the server check fails', () async {
      when(() => local.isEnrollmentDone()).thenAnswer((_) async => false);
      when(
        () => remote.isEnrollmentDoneOnServer(),
      ).thenAnswer((_) async => throw const NetworkFailure());

      expect(await repository.isEnrollmentDone(), isFalse);
      verifyNever(() => local.saveEnrollmentDone());
    });
  });
}
