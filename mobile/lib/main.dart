import 'dart:async';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/router/app_router.dart';
import 'core/security/env_validator.dart';
import 'core/theme/theme.dart';
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'features/events/presentation/bloc/events_bloc.dart';
import 'features/account/presentation/bloc/account_bloc.dart';
import 'features/notifications/presentation/bloc/notifications_bloc.dart';
import 'features/gallery/presentation/bloc/gallery_bloc.dart';
import 'di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
  }

  final missingVars = EnvValidator.validate();
  if (missingVars.isNotEmpty) {
    debugPrint('Warning: Missing env vars: $missingVars');
  }
  if (!EnvValidator.isBaseUrlValid()) {
    debugPrint('Warning: Invalid or missing BASE_URL in .env');
  }

  await di.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  final bool enableDeepLinks;

  const MyApp({super.key, this.enableDeepLinks = true});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.enableDeepLinks) {
      _initDeepLinks();
    }
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>()),
        BlocProvider<AccountBloc>(create: (_) => di.sl<AccountBloc>()),
        BlocProvider<EventsBloc>(
          create: (_) => di.sl<EventsBloc>(),
        ),
        BlocProvider<NotificationBloc>(
          create: (_) => di.sl<NotificationBloc>(),
        ),
        BlocProvider<GalleryBloc>(create: (_) => di.sl<GalleryBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
