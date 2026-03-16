import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/dashboard/screens/dashboard_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/screens/documents_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/screens/employees_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/main_navigation/screens/main_navigation_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/settings_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _dashboardNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'dashboardNav');
final GlobalKey<NavigatorState> _documentsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'documentsNav');
final GlobalKey<NavigatorState> _employeesNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'employeesNav');
final GlobalKey<NavigatorState> _settingsNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settingsNav');

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    StatefulShellRoute.indexedStack(
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
