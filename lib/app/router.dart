import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/library/library_screen.dart';
import '../features/onboarding/api_key_setup_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/project_setup/project_setup_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/splash/splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/setup/api-key',
      builder: (context, state) => const ApiKeySetupScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/project/setup',
      builder: (context, state) => const ProjectSetupScreen(),
    ),
    GoRoute(
      path: '/library',
      builder: (context, state) => const LibraryScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
