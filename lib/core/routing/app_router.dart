import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/auth/auth_provider.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/auth/screens/login_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/dashboard/screens/dashboard_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/screens/documents_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/screens/document_detail_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/screens/upload_document_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/models/document.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/screens/employees_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/screens/employee_detail_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/screens/employee_form_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/models/employee.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/main_navigation/screens/main_navigation_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/settings_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/about_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/appearance_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/language_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/my_profile_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/security_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/screens/user_management_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/screens/user_form_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/screens/user_detail_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/user.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/screens/roles_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/screens/role_form_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/screens/role_detail_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/document_configuration/document_configuration_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/document_configuration/document_prefix_form_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/settings/screens/document_configuration/document_prefix_detail_screen.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/document_prefix.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/role.dart';
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
        path: '/profile',
        builder: (context, state) => const MyProfileScreen(),
      ),
      GoRoute(
        path: '/security',
        builder: (context, state) => const SecurityScreen(),
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
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const UserFormScreen(),
          ),
          GoRoute(
            path: 'detail',
            builder: (context, state) {
              final user = state.extra as User;
              return UserDetailScreen(user: user);
            },
          ),
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final user = state.extra as User;
              return UserFormScreen(user: user);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/roles',
        builder: (context, state) => const RolesScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const RoleFormScreen(),
          ),
          GoRoute(
            path: 'detail',
            builder: (context, state) {
              final role = state.extra as Role;
              return RoleDetailScreen(role: role);
            },
          ),
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final role = state.extra as Role;
              return RoleFormScreen(role: role);
            },
          ),
        ],
      ),      GoRoute(
        path: '/document-configuration',
        builder: (context, state) => const DocumentConfigurationScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const DocumentPrefixFormScreen(),
          ),
          GoRoute(
            path: 'detail',
            builder: (context, state) {
              final prefix = state.extra as DocumentPrefix;
              return DocumentPrefixDetailScreen(prefix: prefix);
            },
          ),
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final prefix = state.extra as DocumentPrefix;
              return DocumentPrefixFormScreen(prefix: prefix);
            },
          ),
        ],
      ),
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
                routes: [
                  GoRoute(
                    path: 'upload',
                    builder: (context, state) => const UploadDocumentScreen(),
                  ),
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) {
                      final document = state.extra as Document;
                      return DocumentDetailScreen(document: document);
                    },
                  ),
                ],
              ),            ],
          ),
          StatefulShellBranch(
            navigatorKey: _employeesNavigatorKey,
            routes: [
              GoRoute(
                path: '/employees',
                builder: (context, state) => const EmployeesScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const EmployeeFormScreen(),
                  ),
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) {
                      final employee = state.extra as Employee;
                      return EmployeeDetailScreen(employee: employee);
                    },
                  ),
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final employee = state.extra as Employee;
                      return EmployeeFormScreen(employee: employee);
                    },
                  ),
                ],
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
