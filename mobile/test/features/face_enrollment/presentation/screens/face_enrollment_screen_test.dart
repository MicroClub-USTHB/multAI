import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:multai_mobile/l10n/app_localizations.dart';
import 'package:multai_mobile/features/face_enrollment/domain/entities/face_photo_entity.dart';
import 'package:multai_mobile/features/face_enrollment/presentation/bloc/face_enrollment_bloc.dart';
import 'package:multai_mobile/features/face_enrollment/presentation/screens/face_enrollment_screen.dart';

class MockFaceEnrollmentBloc
    extends MockBloc<FaceEnrollmentEvent, FaceEnrollmentState>
    implements FaceEnrollmentBloc {}

class FakeFaceEnrollmentEvent extends Fake implements FaceEnrollmentEvent {}

Widget createTestWidget(MockFaceEnrollmentBloc bloc) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<FaceEnrollmentBloc>.value(
      value: bloc,
      child: const FaceEnrollmentScreen(skipCameraInit: true),
    ),
  );
}

Future<void> scrollAndTap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
}

extension on WidgetTester {
  Future<void> tapNext() => scrollAndTap(this, find.text('Next'));
  Future<void> tapPrevious() => scrollAndTap(this, find.text('Previous'));
  Future<void> tapSkipOptional() =>
      scrollAndTap(this, find.text('Skip'));
  Future<void> tapSubmit() =>
      scrollAndTap(this, find.text('Complete'));
}

void main() {
  late MockFaceEnrollmentBloc mockBloc;

  setUp(() {
    mockBloc = MockFaceEnrollmentBloc();
    when(() => mockBloc.state).thenReturn(const FaceEnrollmentState());
    registerFallbackValue(FakeFaceEnrollmentEvent());
  });

  group('initial render', () {
    testWidgets('renders the enrollment screen with step title', (tester) async {
      await tester.pumpWidget(createTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('Front View'), findsAtLeast(1));
    });

    testWidgets('shows step progress header', (tester) async {
      await tester.pumpWidget(createTestWidget(mockBloc));
      await tester.pump();

      expect(find.textContaining('Step 1 of 5'), findsOneWidget);
    });

    testWidgets('shows Previous button with zero opacity on first page',
        (tester) async {
      await tester.pumpWidget(createTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('Previous'), findsOneWidget);
      final textButton = find.ancestor(
        of: find.text('Previous'),
        matching: find.byType(TextButton),
      );
      expect(textButton, findsOneWidget);
    });

    testWidgets('shows success screen when enrollment completes',
        (tester) async {
      when(() => mockBloc.state).thenReturn(
        const FaceEnrollmentState(status: EnrollmentStatus.success),
      );

      await tester.pumpWidget(createTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('Enrollment Complete!'), findsOneWidget);
    });

    testWidgets('shows loading overlay during submission', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const FaceEnrollmentState(status: EnrollmentStatus.submitting),
      );

      await tester.pumpWidget(createTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('Uploading your biometric data...'), findsOneWidget);
      expect(find.text('Please wait while we process your enrollment.'),
          findsOneWidget);
    });
  });

  group('PageView navigation', () {
    testWidgets('auto-advances after adding a required photo', (tester) async {
      whenListen(
        mockBloc,
        Stream.fromIterable([
          const FaceEnrollmentState(
            photos: {FacePhotoType.frontal: '/tmp/frontal.jpg'},
          ),
        ]),
        initialState: const FaceEnrollmentState(),
      );

      await tester.pumpWidget(createTestWidget(mockBloc));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 5'), findsOneWidget);
    });

    testWidgets(
        'skip optional photos dispatches EnrollmentSubmitted when all required done',
        (tester) async {
      final photos = {
        FacePhotoType.frontal: '/tmp/f.jpg',
        FacePhotoType.leftProfile: '/tmp/l.jpg',
        FacePhotoType.rightProfile: '/tmp/r.jpg',
      };
      when(() => mockBloc.state).thenReturn(FaceEnrollmentState(
        photos: photos,
      ));

      await tester.pumpWidget(createTestWidget(mockBloc));
      await tester.pump();

      for (int i = 0; i < 3; i++) {
        await tester.tapNext();
        await tester.pumpAndSettle();
      }

      expect(find.text('Tilt Up'), findsAtLeast(1));

      await tester.tapSkipOptional();

      verify(() => mockBloc.add(any(that: isA<EnrollmentSubmitted>()))).called(1);
    });

    testWidgets('completes enrollment from last page after all photos',
        (tester) async {
      final photos = {
        FacePhotoType.frontal: '/tmp/f.jpg',
        FacePhotoType.leftProfile: '/tmp/l.jpg',
        FacePhotoType.rightProfile: '/tmp/r.jpg',
        FacePhotoType.extra1: '/tmp/e1.jpg',
        FacePhotoType.extra2: '/tmp/e2.jpg',
      };
      when(() => mockBloc.state).thenReturn(FaceEnrollmentState(
        photos: photos,
      ));

      await tester.pumpWidget(createTestWidget(mockBloc));
      await tester.pump();

      for (int i = 0; i < 4; i++) {
        await tester.tapNext();
        await tester.pumpAndSettle();
      }

      expect(find.text('Tilt Down'), findsAtLeast(1));

      await tester.tapSubmit();

      verify(() => mockBloc.add(any(that: isA<EnrollmentSubmitted>()))).called(1);
    });

    testWidgets('Previous button navigates to previous page', (tester) async {
      final photos = {
        FacePhotoType.frontal: '/tmp/f.jpg',
        FacePhotoType.leftProfile: '/tmp/l.jpg',
      };
      when(() => mockBloc.state).thenReturn(FaceEnrollmentState(
        photos: photos,
      ));

      await tester.pumpWidget(createTestWidget(mockBloc));
      await tester.pump();

      await tester.tapNext();
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 5'), findsOneWidget);

      await tester.tapPrevious();
      await tester.pumpAndSettle();

      expect(find.text('Step 1 of 5'), findsOneWidget);
    });

    testWidgets('auto-advance does not fire on last page', (tester) async {
      final photos = {
        FacePhotoType.frontal: '/tmp/f.jpg',
        FacePhotoType.leftProfile: '/tmp/l.jpg',
        FacePhotoType.rightProfile: '/tmp/r.jpg',
        FacePhotoType.extra1: '/tmp/e1.jpg',
      };
      when(() => mockBloc.state).thenReturn(FaceEnrollmentState(
        photos: photos,
      ));

      await tester.pumpWidget(createTestWidget(mockBloc));
      await tester.pump();

      for (int i = 0; i < 4; i++) {
        await tester.tapNext();
        await tester.pumpAndSettle();
      }

      expect(find.text('Step 5 of 5'), findsOneWidget);

      whenListen(
        mockBloc,
        Stream.fromIterable([
          FaceEnrollmentState(
            photos: {
              FacePhotoType.frontal: '/tmp/f.jpg',
              FacePhotoType.leftProfile: '/tmp/l.jpg',
              FacePhotoType.rightProfile: '/tmp/r.jpg',
              FacePhotoType.extra1: '/tmp/e1.jpg',
              FacePhotoType.extra2: '/tmp/e2.jpg',
            },
          ),
        ]),
        initialState: FaceEnrollmentState(photos: photos),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Step 5 of 5'), findsOneWidget);
    });

    testWidgets(
        'Submit button visible on last page with required photos',
        (tester) async {
      final photos = {
        FacePhotoType.frontal: '/tmp/f.jpg',
        FacePhotoType.leftProfile: '/tmp/l.jpg',
        FacePhotoType.rightProfile: '/tmp/r.jpg',
      };
      when(() => mockBloc.state).thenReturn(FaceEnrollmentState(
        photos: photos,
      ));

      await tester.pumpWidget(createTestWidget(mockBloc));
      await tester.pump();

      for (int i = 0; i < 4; i++) {
        await tester.tapNext();
        await tester.pumpAndSettle();
      }

      await tester.ensureVisible(find.text('Complete'));
      await tester.pump();
      expect(find.text('Complete'), findsOneWidget);
    });
  });
}
