import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/models/employee_response.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/repositories/employee_repository.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/branch.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/department.dart';

final employeeSearchQueryProvider = NotifierProvider<EmployeeSearchQueryNotifier, String>(() {
  return EmployeeSearchQueryNotifier();
});

class EmployeeSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  
  void updateQuery(String query) {
    state = query;
  }
}

final employeeDepartmentFilterProvider = NotifierProvider<EmployeeDepartmentFilterNotifier, int?>(() {
  return EmployeeDepartmentFilterNotifier();
});

class EmployeeDepartmentFilterNotifier extends Notifier<int?> {
  @override
  int? build() => null;
  
  void updateDepartment(int? departmentId) {
    state = departmentId;
  }
}

final employeeBranchFilterProvider = NotifierProvider<EmployeeBranchFilterNotifier, int?>(() {
  return EmployeeBranchFilterNotifier();
});

class EmployeeBranchFilterNotifier extends Notifier<int?> {
  @override
  int? build() => null;
  
  void updateBranch(int? branchId) {
    state = branchId;
  }
}

final employeeBranchesProvider = FutureProvider.autoDispose<List<Branch>>((ref) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getBranches();
});

final employeeDepartmentsProvider = FutureProvider.autoDispose<List<Department>>((ref) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getDepartments();
});

final employeesProvider = FutureProvider.autoDispose<EmployeeResponse>((ref) async {
  final repository = ref.watch(employeeRepositoryProvider);
  final searchQuery = ref.watch(employeeSearchQueryProvider);
  final departmentFilter = ref.watch(employeeDepartmentFilterProvider);
  final branchFilter = ref.watch(employeeBranchFilterProvider);

  return repository.getEmployees(
    search: searchQuery,
    departmentId: departmentFilter,
    branchId: branchFilter,
  );
});
