import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/auth/auth_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/auth/screens/login_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/dashboard/screens/dashboard_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/screens/documents_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/screens/employees_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/main_navigation/screens/main_navigation_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/settings_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/about_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/appearance_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/language_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/screens/user_management_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/screens/roles_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/splash/screens/splash_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _dashboardNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'dashboardNav');
final GlobalKey<NavigatorState> _documentsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'documentsNav');
final GlobalKey<NavigatorState> _employeesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'employeesNav');
final GlobalKey<NavigatorState> _settingsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settingsNav');

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(authProvider);
  final isInitialized = ref.watch(appInitializedProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isSplash = state.matchedLocation == '/splash';
      final isLoggingIn = state.matchedLocation == '/login';

      // 1. If not initialized, we MUST be on the splash screen
      if (!isInitialized) {
        return isSplash ? null : '/splash';
      }

      // 2. Once initialized, handle Auth redirection
      
      // If we've just initialized and are still on splash, decide where to go
      if (isSplash) {
        return isAuthenticated ? '/dashboard' : '/login';
      }

      // Standard Auth Guard
      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      // Redirect away from login if already authenticated
      if (isAuthenticated && isLoggingIn) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/appearance',
        builder: (context, state) => const AppearanceScreen(),
      ),
      GoRoute(
        path: '/language',
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/roles',
        builder: (context, state) => const RolesScreen(),
      ),      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainNavigationScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _dashboardNavigatorKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _documentsNavigatorKey,
            routes: [
              GoRoute(
                path: '/documents',
                builder: (context, state) => const DocumentsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _employeesNavigatorKey,
            routes: [
              GoRoute(
                path: '/employees',
                builder: (context, state) => const EmployeesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
