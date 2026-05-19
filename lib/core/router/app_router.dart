import 'package:flutter/material.dart';
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
import '../../data/models/injury_model.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

class AppRouter {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/onboarding',
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
        builder: (context, state) => const AddInjuryScreen(),
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
}
