import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/today/screens/today_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/admin/screens/admin_screen.dart';
import '../../features/admin/screens/user_management_screen.dart';
import '../../features/admin/screens/task_definition_management_screen.dart';
import '../../features/admin/screens/task_assignment_management_screen.dart';
import '../../features/admin/screens/verification_queue_screen.dart';
import '../../features/admin/screens/settings_screen.dart';
import '../../features/admin/screens/payout_screen.dart';
import '../../features/leaderboard/screens/leaderboard_screen.dart';
import '../../features/scoreboard/screens/scoreboard_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final location = state.uri.path;
      final isLoggingIn = location == '/login';
      final isScoreboard = location == '/scoreboard';

      if (kDebugMode) {
        print('Router redirect: location=$location, isScoreboard=$isScoreboard, isLoggingIn=$isLoggingIn, authLoading=${authState.isLoading}, authValue=${authState.value}');
      }

      // Allow access to scoreboard without authentication
      if (isScoreboard) {
        if (kDebugMode) {
          print('Router: Allowing access to scoreboard');
        }
        return null;
      }

      // While auth is loading, don't redirect (except for scoreboard which is handled above)
      if (authState.isLoading) {
        if (kDebugMode) {
          print('Router: Auth is loading, not redirecting');
        }
        return null;
      }

      final isAuthenticated = authState.value != null;

      if (!isAuthenticated && !isLoggingIn) {
        if (kDebugMode) {
          print('Router: Not authenticated and not logging in, redirecting to /login');
        }
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        if (kDebugMode) {
          print('Router: Authenticated and on login page, redirecting to /');
        }
        return '/';
      }

      if (kDebugMode) {
        print('Router: No redirect needed');
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/today',
        name: 'today',
        builder: (context, state) => const TodayScreen(),
      ),
      GoRoute(
        path: '/calendar',
        name: 'calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'admin-users',
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/admin/tasks',
        name: 'admin-tasks',
        builder: (context, state) => const TaskDefinitionManagementScreen(),
      ),
      GoRoute(
        path: '/admin/assignments',
        name: 'admin-assignments',
        builder: (context, state) => const TaskAssignmentManagementScreen(),
      ),
      GoRoute(
        path: '/admin/verification-queue',
        name: 'admin-verification-queue',
        builder: (context, state) => const VerificationQueueScreen(),
      ),
      GoRoute(
        path: '/admin/payout',
        name: 'admin-payout',
        builder: (context, state) => const PayoutScreen(),
      ),
      GoRoute(
        path: '/admin/settings',
        name: 'admin-settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        name: 'leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: '/scoreboard',
        name: 'scoreboard',
        builder: (context, state) => const ScoreboardScreen(),
      ),
    ],
  );
}
