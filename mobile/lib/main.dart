import 'dart:async';
import 'dart:ui' show PlatformDispatcher;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/cubits/locale_cubit.dart';
import 'core/cubits/theme_cubit.dart';
import 'core/router/app_router.dart';
import 'core/security/env_validator.dart';
import 'core/security/device_security.dart';
import 'core/security/secure_logger.dart';
import 'core/security/session_manager.dart';
import 'core/storage/app_local_storage.dart';
import 'core/theme/theme.dart';
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'features/events/presentation/bloc/events_bloc.dart';
import 'features/account/presentation/bloc/account_bloc.dart';
import 'features/notifications/presentation/bloc/notifications_bloc.dart';
import 'features/notifications/services/push_notification_service.dart';
import 'features/notifications/services/notification_navigation_service.dart';
import 'features/gallery/presentation/bloc/gallery_bloc.dart';
import 'di/injection_container.dart' as di;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

late final SessionManager sessionManager;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialising from the generated options keeps FCM available on builds
    // that do not ship android/app/google-services.json; without this the
    // default app is never created and no push token is ever requested.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization skipped: $e');
  }

  if (DeviceSecurity.isDebugMode()) {
    SecureLogger.warning('App', 'Running in debug mode');
  }

  _setupGlobalErrorHandlers();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    SecureLogger.error('App', 'Could not load .env file', e);
  }

  final missingVars = EnvValidator.validate();
  if (missingVars.isNotEmpty) {
    SecureLogger.error('App', 'Missing env vars: $missingVars');
  }

  if (!EnvValidator.isBaseUrlValid()) {
    SecureLogger.error('App', 'Invalid or missing BASE_URL in .env');
  }

  if (!EnvValidator.isProduction()) {
    SecureLogger.warning('App', 'Using non-HTTPS base URL');
  }

  sessionManager = SessionManager(timeoutDuration: const Duration(minutes: 15));

  di.registerSessionManager(sessionManager);

  sessionManager.setOnSessionExpired(() {
    SecureLogger.info('App', 'Session expired due to inactivity');
  });

  await di.init();

  // Wire push notification lifecycle
  final pushService = di.sl<PushNotificationService>();
  await pushService.init();
  di.sl<NotificationNavigationService>().init(appRouter);

  await _preloadFonts();

  runApp(MyApp());
}

/// Fonts are bundled under `assets/google_fonts` so the UI never waits for a
/// network round-trip (or re-lays out text when the font swaps in) on the
/// onboarding, login or logout screens. Queue the variants used by both
/// themes, then wait for them before the first frame.
Future<void> _preloadFonts() async {
  GoogleFonts.config.allowRuntimeFetching = false;
  try {
    for (final weight in const [
      FontWeight.w400,
      FontWeight.w500,
      FontWeight.w600,
      FontWeight.w700,
    ]) {
      GoogleFonts.dmSans(fontWeight: weight);
      GoogleFonts.raleway(fontWeight: weight);
    }
    GoogleFonts.montserrat();
    GoogleFonts.playfairDisplay();
    GoogleFonts.playfairDisplay(fontStyle: FontStyle.italic);
    await GoogleFonts.pendingFonts().timeout(const Duration(seconds: 3));
  } catch (e) {
    debugPrint('Font preload skipped: $e');
  }
}

void _setupGlobalErrorHandlers() {
  FlutterError.onError = (details) {
    FirebaseCrashlytics.instance.recordError(
      details.exception,
      details.stack,
      fatal: true,
    );
  };

  PlatformDispatcher.instance.onError = (exception, stackTrace) {
    FirebaseCrashlytics.instance.recordError(
      exception,
      stackTrace,
      fatal: false,
    );
    return true;
  };
}

class MyApp extends StatefulWidget {
  final bool enableDeepLinks;

  const MyApp({super.key, this.enableDeepLinks = true});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.enableDeepLinks) {
      _initDeepLinks();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      sessionManager.resume();
      sessionManager.recordActivity();
    } else if (state == AppLifecycleState.paused) {
      sessionManager.pause();
    }
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      _handleDeepLink(initialUri);
    }

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    final nav = di.sl<NotificationNavigationService>();
    nav.handleDeepLink(uri);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
        BlocProvider<AccountBloc>(create: (_) => di.sl<AccountBloc>()),
        BlocProvider<EventsBloc>(create: (_) => di.sl<EventsBloc>()),
        BlocProvider<NotificationBloc>(
          create: (_) => di.sl<NotificationBloc>()..add(LoadNotifications()),
        ),
        BlocProvider<GalleryBloc>(create: (_) => di.sl<GalleryBloc>()),
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(di.sl<AppLocalStorage>()),
        ),
        BlocProvider<LocaleCubit>(
          create: (_) => LocaleCubit(di.sl<AppLocalStorage>()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocBuilder<LocaleCubit, Locale>(
            builder: (context, locale) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: !DeviceSecurity.isDebugMode(),
                title: 'MultAI',
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                locale: locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                routerConfig: appRouter,
              );
            },
          );
        },
      ),
    );
  }
}
