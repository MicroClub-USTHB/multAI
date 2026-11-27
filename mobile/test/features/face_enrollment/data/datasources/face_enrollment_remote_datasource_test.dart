import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:multai_mobile/core/constants/end_points.dart';
import 'package:multai_mobile/core/errors/failure.dart';
import 'package:multai_mobile/core/network/api_client.dart';
import 'package:multai_mobile/features/face_enrollment/data/datasources/face_enrollment_remote_datasource.dart';
import 'package:multai_mobile/features/face_enrollment/data/models/face_photo_model.dart';
import 'package:multai_mobile/features/face_enrollment/domain/entities/face_photo_entity.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApiClient;
  late FaceEnrollmentRemoteDataSourceImpl dataSource;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = FaceEnrollmentRemoteDataSourceImpl(
      apiClient: mockApiClient,
      // File validation/compression is covered separately; these tests only
      // exercise the upload contract (endpoint, fields, retry policy).
      validatePhoto: (path) async => Right(File(path)),
    );
  });

  group('uploadFacePhotos', () {
    test('calls postMultipart with correct endpoint and auth flag', () async {
      final photos = [
        FacePhotoModel(type: FacePhotoType.frontal, filePath: '/tmp/f.jpg'),
        FacePhotoModel(type: FacePhotoType.leftProfile, filePath: '/tmp/l.jpg'),
        FacePhotoModel(type: FacePhotoType.rightProfile, filePath: '/tmp/r.jpg'),
      ];

      when(
        () => mockApiClient.postMultipart(
          any(),
          files: any(named: 'files'),
          fieldNames: any(named: 'fieldNames'),
          requiresAuth: any(named: 'requiresAuth'),
        ),
      ).thenAnswer((_) async => <String, dynamic>{});

      await dataSource.uploadFacePhotos(photos);

      verify(
        () => mockApiClient.postMultipart(
          EndPoints.faceEnrollment,
          files: any(named: 'files', that: hasLength(3)),
          fieldNames: any(named: 'fieldNames', that: hasLength(3)),
          requiresAuth: true,
        ),
      ).called(1);
    });

    test('sends all files under the multipart field name "files"', () async {
      final photos = [
        FacePhotoModel(type: FacePhotoType.frontal, filePath: '/tmp/f.jpg'),
        FacePhotoModel(type: FacePhotoType.leftProfile, filePath: '/tmp/l.jpg'),
        FacePhotoModel(type: FacePhotoType.rightProfile, filePath: '/tmp/r.jpg'),
      ];

      when(
        () => mockApiClient.postMultipart(
          any(),
          files: any(named: 'files'),
          fieldNames: captureAny(named: 'fieldNames'),
          requiresAuth: any(named: 'requiresAuth'),
        ),
      ).thenAnswer((_) async => <String, dynamic>{});

      await dataSource.uploadFacePhotos(photos);

      final captured = verify(
        () => mockApiClient.postMultipart(
          any(),
          files: any(named: 'files', that: hasLength(3)),
          fieldNames: captureAny(named: 'fieldNames'),
          requiresAuth: any(named: 'requiresAuth'),
        ),
      );

      final fieldNames = captured.captured.first as List<String>;
      expect(fieldNames, ['files', 'files', 'files']);
      expect(fieldNames, everyElement('files'));
    });

    test('field name count matches file count for 5 photos', () async {
      final photos = [
        FacePhotoModel(type: FacePhotoType.frontal, filePath: '/tmp/f.jpg'),
        FacePhotoModel(type: FacePhotoType.leftProfile, filePath: '/tmp/l.jpg'),
        FacePhotoModel(type: FacePhotoType.rightProfile, filePath: '/tmp/r.jpg'),
        FacePhotoModel(type: FacePhotoType.extra1, filePath: '/tmp/e1.jpg'),
        FacePhotoModel(type: FacePhotoType.extra2, filePath: '/tmp/e2.jpg'),
      ];

      when(
        () => mockApiClient.postMultipart(
          any(),
          files: captureAny(named: 'files'),
          fieldNames: captureAny(named: 'fieldNames'),
          requiresAuth: any(named: 'requiresAuth'),
        ),
      ).thenAnswer((_) async => <String, dynamic>{});
      await dataSource.uploadFacePhotos(photos);

      final captured = verify(
        () => mockApiClient.postMultipart(
          any(),
          files: captureAny(named: 'files'),
          fieldNames: captureAny(named: 'fieldNames'),
          requiresAuth: any(named: 'requiresAuth'),
        ),
      );

      final capturedList = captured.captured;
      expect(capturedList, hasLength(2));
      final files = capturedList[0] as List<File>;
      final fieldNames = capturedList[1] as List<String>;
      expect(files, hasLength(5));
      expect(fieldNames, hasLength(5));
      expect(fieldNames, everyElement('files'));
    });

    test('retries on NetworkFailure', () async {
      final photos = [
        FacePhotoModel(type: FacePhotoType.frontal, filePath: '/tmp/f.jpg'),
        FacePhotoModel(type: FacePhotoType.leftProfile, filePath: '/tmp/l.jpg'),
        FacePhotoModel(type: FacePhotoType.rightProfile, filePath: '/tmp/r.jpg'),
      ];

      when(
        () => mockApiClient.postMultipart(
          any(),
          files: any(named: 'files'),
          fieldNames: any(named: 'fieldNames'),
          requiresAuth: any(named: 'requiresAuth'),
        ),
      ).thenAnswer((_) async => throw const NetworkFailure());

      await expectLater(
        dataSource.uploadFacePhotos(photos),
        throwsA(isA<NetworkFailure>()),
      );

      verify(
        () => mockApiClient.postMultipart(
          any(),
          files: any(named: 'files'),
          fieldNames: any(named: 'fieldNames'),
          requiresAuth: any(named: 'requiresAuth'),
        ),
      ).called(3);
    });

    test('does not retry on non-network failures', () async {
      final photos = [
        FacePhotoModel(type: FacePhotoType.frontal, filePath: '/tmp/f.jpg'),
        FacePhotoModel(type: FacePhotoType.leftProfile, filePath: '/tmp/l.jpg'),
        FacePhotoModel(type: FacePhotoType.rightProfile, filePath: '/tmp/r.jpg'),
      ];

      when(
        () => mockApiClient.postMultipart(
          any(),
          files: any(named: 'files'),
          fieldNames: any(named: 'fieldNames'),
          requiresAuth: any(named: 'requiresAuth'),
        ),
      ).thenAnswer((_) async => throw const ServerFailure('Upload failed', 400));

      await expectLater(
        dataSource.uploadFacePhotos(photos),
        throwsA(isA<ServerFailure>()),
      );

      verify(
        () => mockApiClient.postMultipart(
          any(),
          files: any(named: 'files'),
          fieldNames: any(named: 'fieldNames'),
          requiresAuth: any(named: 'requiresAuth'),
        ),
      ).called(1);
    });
  });

  group('isEnrollmentDoneOnServer', () {
    test('reads is_onboarded from GET /user/auth/me', () async {
      when(() => mockApiClient.get(EndPoints.me)).thenAnswer(
        (_) async => {
          'user': {'id': 'u1', 'email': 'a@b.c', 'is_onboarded': true},
          'devices': <dynamic>[],
        },
      );

      expect(await dataSource.isEnrollmentDoneOnServer(), isTrue);
      verify(() => mockApiClient.get(EndPoints.me)).called(1);
    });

    test('returns false when the account has no enrollment', () async {
      when(() => mockApiClient.get(EndPoints.me)).thenAnswer(
        (_) async => {
          'user': {'id': 'u1', 'email': 'a@b.c', 'is_onboarded': false},
          'devices': <dynamic>[],
        },
      );

      expect(await dataSource.isEnrollmentDoneOnServer(), isFalse);
    });

    test('propagates failures from the API', () async {
      when(
        () => mockApiClient.get(EndPoints.me),
      ).thenAnswer((_) async => throw const NetworkFailure());

      await expectLater(
        dataSource.isEnrollmentDoneOnServer(),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}
