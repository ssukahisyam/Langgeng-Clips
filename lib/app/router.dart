import 'package:go_router/go_router.dart';

import '../features/editor/editor_screen.dart';
import '../features/home/home_screen.dart';
import '../features/library/export_detail_screen.dart';
import '../features/library/export_viewer_screen.dart';
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
    GoRoute(path: '/editor', builder: (context, state) => const EditorScreen()),
    GoRoute(
      path: '/library',
      builder: (context, state) => const LibraryScreen(),
    ),
    GoRoute(
      path: '/library/export/:id',
      builder: (context, state) {
        return ExportDetailScreen(exportId: state.pathParameters['id']!);
      },
    ),
    GoRoute(
      path: '/library/export/:id/viewer',
      builder: (context, state) {
        return ExportViewerScreen(exportId: state.pathParameters['id']!);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
