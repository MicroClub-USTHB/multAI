// ignore_for_file: unused_element

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
<<<<<<< HEAD
import 'core/router/app_router.dart';
import 'core/theme/theme.dart';
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'di/injection_container.dart' as di;
=======
import 'package:multai_mobile/core/theme/theme.dart';
import 'package:multai_mobile/features/splash/presentation/pages/splash_screen.dart';
>>>>>>> 583b67e (implement the firsts components of the splashscreen and add the style and the colors of the screen that we need them create the .env file for now i only worked on the ui and we have some improvment we respecte the responsive ofc after i finish it we go through the lofic of the screen)

Map<String, String>? _pendingAuthTokens;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();


  // Load .env with error handling - use defaults if file missing/corrupted
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // .env file not found or corrupted - app will use fallback values
    debugPrint('Warning: Could not load .env file: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    //to be implemented
  }

  void _processPendingTokens() {
    // to be implemented
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
        BlocProvider<OnboardingBloc>(create: (_) => di.sl<OnboardingBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
=======
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
    // return MaterialApp(
    //   navigatorKey: _navigatorKey,
    //   debugShowCheckedModeBanner: false,
    //   theme: AppTheme.darkTheme,
    //   // home: Scaffold(),
    //   home: const SplashScreen(),
    // );
>>>>>>> 583b67e (implement the firsts components of the splashscreen and add the style and the colors of the screen that we need them create the .env file for now i only worked on the ui and we have some improvment we respecte the responsive ofc after i finish it we go through the lofic of the screen)
  }
}
