import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:multai_mobile/core/network/network_info.dart';
import 'package:multai_mobile/di/injection_container.dart' as di;
import 'package:multai_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:multai_mobile/main.dart';

/// The splash gates routing on a real connectivity ping, which always fails in
/// the headless test environment. Force "connected" so the boot flow reaches
/// onboarding deterministically.
class _FakeConnectedNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;

  @override
  Stream<bool> get onConnectivityChanged => const Stream<bool>.empty();
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await dotenv.load(fileName: '.env');
    await di.init();

    if (di.sl.isRegistered<NetworkInfo>()) {
      await di.sl.unregister<NetworkInfo>();
    }
    di.sl.registerLazySingleton<NetworkInfo>(() => _FakeConnectedNetworkInfo());
  });

  testWidgets('boots to the onboarding screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(enableDeepLinks: false));
    // Let the splash delay elapse and the router settle onto onboarding.
    // Avoid pumpAndSettle: the splash loader is an indeterminate progress bar
    // that never "settles".
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(seconds: 1));
    }

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Your events,\ncaptured.'), findsOneWidget);
  });
}
