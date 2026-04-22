import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:multai_mobile/di/injection_container.dart' as di;
import 'package:multai_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:multai_mobile/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await dotenv.load(fileName: '.env');
    await di.init();
  });

  testWidgets('boots to the onboarding screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(enableDeepLinks: false));
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Discover Your'), findsOneWidget);
  });
}
