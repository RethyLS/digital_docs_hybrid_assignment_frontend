import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/dashboard/models/dashboard_data.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/repositories/document_repository.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/repositories/employee_repository.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/repositories/user_repository.dart';

final dashboardProvider = FutureProvider.autoDispose<DashboardData>((ref) async {
  final documentRepo = ref.watch(documentRepositoryProvider);
  final employeeRepo = ref.watch(employeeRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);

  // Fetch recent documents and total documents count (page 1, 5 items)
  final documentsResponse = await documentRepo.getDocuments(page: 1, perPage: 5);
  
  // Fetch total employees count (page 1, 1 item just to get the meta total)
  final employeesResponse = await employeeRepo.getEmployees(page: 1, perPage: 1);

  // Fetch total users count (page 1, 1 item just to get the meta total)
  final usersResponse = await userRepo.getUsers(page: 1, perPage: 1);

  return DashboardData(
    totalDocuments: documentsResponse.meta?.total ?? 0,
    totalEmployees: employeesResponse.meta?.total ?? 0,
    totalUsers: usersResponse.meta?.total ?? 0,
    recentDocuments: documentsResponse.data,
  );
});
