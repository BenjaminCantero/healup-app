import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/screens/main_wrapper.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/injuries_screen.dart';
import '../../presentation/screens/progress_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/add_injury_screen.dart';
import '../../presentation/screens/achievements_screen.dart';
import '../../presentation/screens/onboarding_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/body_map_screen.dart';
import '../../presentation/screens/exercise_detail_screen.dart';
import '../../presentation/screens/pain_log_screen.dart';
import '../../presentation/screens/injury_detail_screen.dart';
import '../../presentation/screens/routine_screen.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../data/models/injury_model.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

// ─── Public routes (no auth needed) ──────────────────────────────────────────
const _publicRoutes = ['/onboarding', '/login', '/register'];

// ─── Router provider (uses Riverpod for auth state) ──────────────────────────
final appRouterProvider = Provider<GoRouter>((ref) {
  // Listen to auth changes so the router refreshes when login/logout happens
  final authListenable = _AuthStateListenable(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/onboarding',
    refreshListenable: authListenable,
    redirect: (context, state) async {
      final authState = ref.read(authProvider);
      final onboardingState = ref.read(onboardingCompletedProvider);

      // While auth or onboarding are loading, don't redirect yet
      if (authState.isLoading || onboardingState.isLoading) return null;

      final isAuthenticated = authState.value?.isAuthenticated ?? false;
      final onboardingDone = onboardingState.value ?? false;
      final currentPath = state.matchedLocation;
      final isPublic = _publicRoutes.contains(currentPath);

      // 1. If onboarding not done, always send to onboarding
      if (!onboardingDone && currentPath != '/onboarding') {
        return '/onboarding';
      }

      // 2. If authenticated and trying to access public routes, send home
      if (isAuthenticated && isPublic) {
        return '/home';
      }

      // 3. If NOT authenticated and trying to access protected routes
      if (!isAuthenticated && !isPublic) {
        return '/login';
      }

      // No redirect needed
      return null;
    },
    routes: [
      // ─── Auth flow (no shell) ────────────────────────────────────────────
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),

      // ─── Main shell (bottom nav) ─────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/injuries',
                builder: (context, state) => const InjuriesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ─── Full-screen routes (no shell) ───────────────────────────────────
      GoRoute(
        path: '/add_injury',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final slug = state.uri.queryParameters['slug'];
          return AddInjuryScreen(bodyPartSlug: slug);
        },
      ),
      GoRoute(
        path: '/achievements',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/body_map',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BodyMapScreen(),
      ),
      GoRoute(
        path: '/exercise_detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final exercise = state.extra as Map<String, dynamic>;
          return ExerciseDetailScreen(exercise: exercise);
        },
      ),
      GoRoute(
        path: '/pain_log',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PainLogScreen(),
      ),
      GoRoute(
        path: '/injury_detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final injury = state.extra as InjuryModel;
          return InjuryDetailScreen(injury: injury);
        },
      ),
      GoRoute(
        path: '/routine',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RoutineScreen(),
      ),
    ],
  );
});

// ─── Compatibility shim — kept for screens that still reference AppRouter.router
class AppRouter {
  static GoRouter get router => throw UnimplementedError(
    'Use ref.watch(appRouterProvider) or ProviderScope instead of AppRouter.router directly.',
  );
}

// ─── Listenable that notifies GoRouter when auth state changes ─────────────
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
    ref.listen(onboardingCompletedProvider, (_, __) => notifyListeners());
  }
}
