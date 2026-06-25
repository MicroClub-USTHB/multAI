import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:multai_mobile/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:multai_mobile/features/auth/presentation/screens/register/register_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(
      SendOtpRequested(email: 'test@test.com', password: 'Password1!'),
    );
    registerFallbackValue(
      VerifyOtpRequested(
        email: 'test@test.com',
        password: 'Password1!',
        otp: '123456',
      ),
    );
  });

  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const RegisterPage(),
      ),
    );
  }

  testWidgets('renders email, password, confirm password fields initially', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('shows OTP input when AuthOtpSent state is emitted', (
    WidgetTester tester,
  ) async {
    whenListen(
      mockAuthBloc,
      Stream.fromIterable([AuthOtpSent(email: 'test@test.com')]),
      initialState: AuthOtpSent(email: 'test@test.com'),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Check your email.'), findsOneWidget);
    expect(find.text('Verify'), findsOneWidget);
    expect(find.text('Resend code'), findsOneWidget);
    expect(find.text('Go back'), findsOneWidget);
  });

  testWidgets('shows loading indicator when AuthLoading state is emitted', (
    WidgetTester tester,
  ) async {
    whenListen(
      mockAuthBloc,
      Stream.fromIterable([AuthLoading()]),
      initialState: AuthLoading(),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });

  testWidgets('sends SendOtpRequested when Continue button is tapped',
      (WidgetTester tester) async {
    when(() => mockAuthBloc.state).thenReturn(AuthInitial());

    await tester.pumpWidget(buildTestWidget());
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(0), 'test@test.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'Password1!');
    await tester.enterText(find.byType(TextFormField).at(2), 'Password1!');

    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pump();

    verify(() => mockAuthBloc.add(any<SendOtpRequested>())).called(1);
  });

  testWidgets('sends VerifyOtpRequested when Verify is tapped',
      (WidgetTester tester) async {
    whenListen(
      mockAuthBloc,
      Stream.fromIterable([AuthOtpSent(email: 'test@test.com')]),
      initialState: AuthOtpSent(email: 'test@test.com'),
    );

    await tester.pumpWidget(buildTestWidget());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(find.byType(TextFormField).first, '123456');

    await tester.tap(find.text('Verify'));
    await tester.pump();

    verify(() => mockAuthBloc.add(any<VerifyOtpRequested>())).called(1);
  });
}
