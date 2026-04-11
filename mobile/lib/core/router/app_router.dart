import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:multai_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:multai_mobile/features/splash/presentation/pages/splash_screen.dart';

import '../../di/injection_container.dart' as di;
import '../../features/auth/presentation/screens/login/login_page.dart';
import '../../features/face_enrollment/presentation/screens/face_enrollment_screen.dart';
import '../../features/face_enrollment/presentation/bloc/face_enrollment_bloc.dart';
import '../../features/home/presentation/screens/home_shell.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/gallery/presentation/screens/gallery_screen.dart';
import '../../features/account/presentation/screens/account_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.events,
  routes: [
    // ── Splash Screen (initial route) ───────────────────────────────────────
    GoRoute(path: AppRoutes.splash, builder: (context, state) => const SplashScreen()),
    // ── Onboarding ───────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.onboarding ,
      builder: (context, state) => const OnboardingScreen(),
    ),

    // ── Auth ──────────────────────────────────────────────────────────────────
    GoRoute(path: AppRoutes.login , builder: (context, state) => const LoginPage()),

    // ── Face Enrollment ────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.faceEnrollment,
      builder: (context, state) => BlocProvider(
        create: (_) => di.sl<FaceEnrollmentBloc>(),
        child: const FaceEnrollmentScreen(),
      ),
    ),

    // ── Home shell with bottom nav ─────────────────────────────────────────────
    ShellRoute(
      builder: (context, state, child) => HomeShell(child: child),
      routes: [
        GoRoute(
          path: AppRoutes.events,
          builder: (context, state) => const EventsScreen(),
        ),
        GoRoute(
          path: AppRoutes.gallery,
          builder: (context, state) => const GalleryScreen(),
        ),
        GoRoute(
          path: AppRoutes.account,
          builder: (context, state) => const AccountScreen(),
        ),
          GoRoute(
          path: AppRoutes.notifications,
          builder: (context, state) => const NotificationsScreen(),
        ),
      ],
    ),
  ],
);
