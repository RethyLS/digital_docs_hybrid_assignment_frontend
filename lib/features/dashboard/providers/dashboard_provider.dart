import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/dashboard/models/dashboard_data.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/repositories/document_repository.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/repositories/employee_repository.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/repositories/user_repository.dart';

final dashboardProvider = FutureProvider.autoDispose<DashboardData>((ref) async {
  final documentRepo = ref.watch(documentRepositoryProvider);
  final employeeRepo = ref.watch(employeeRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);

  // Fetch data in parallel for faster dashboard loading
  final results = await Future.wait([
    documentRepo.getDocuments(page: 1, perPage: 5),
    employeeRepo.getEmployees(page: 1, perPage: 1),
    employeeRepo.getEmployees(page: 1, perPage: 1, status: 'active'),
    userRepo.getUsers(page: 1, perPage: 1),
  ]);

  final documentsResponse = results[0] as dynamic;
  final totalEmployeesResponse = results[1] as dynamic;
  final activeEmployeesResponse = results[2] as dynamic;
  final usersResponse = results[3] as dynamic;

  return DashboardData(
    totalDocuments: documentsResponse.meta?.total ?? 0,
    totalEmployees: totalEmployeesResponse.meta?.total ?? 0,
    activeEmployees: activeEmployeesResponse.meta?.total ?? 0,
    totalUsers: usersResponse.meta?.total ?? 0,                                                                                   
    recentDocuments: documentsResponse.data,
  );
});
