import 'package:go_router/go_router.dart';
 
import '../../features/auth/presentation/screens/login/login_page.dart';
import '../../features/home/presentation/screens/home_shell.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/gallery/presentation/screens/gallery_screen.dart';
import '../../features/account/presentation/screens/account_screen.dart';
import 'app_routes.dart';
 
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
 
    // ── Auth ──────────────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
 
    // ── Home shell with bottom nav ─────────────────────────────────────────
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
      ],
    ),
  ],
);