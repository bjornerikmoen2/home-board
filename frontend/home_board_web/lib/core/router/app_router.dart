import 'package:flutter/material.dart';
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
import '../../features/leaderboard/screens/leaderboard_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authNotifier.value != null;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        return '/';
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
        path: '/admin/settings',
        name: 'admin-settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        name: 'leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
    ],
  );
}
