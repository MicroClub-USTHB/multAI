// ignore_for_file: unused_element

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


Map<String, String>? _pendingAuthTokens;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  final _navigatorKey = GlobalKey<NavigatorState>();
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
    return MultiBlocProvider(
      providers: [
        // to be added 
      ],
      child: MaterialApp(
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,
          home: Scaffold(),
        ));
  }
}
