import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/models/employee_response.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/models/employee.dart';
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

class PaginatedEmployeesState {
  final List<Employee> employees;
  final bool hasMore;
  final bool isLoadingMore;
  final int page;
  final String? error;

  PaginatedEmployeesState({
    this.employees = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.page = 1,
    this.error,
  });

  PaginatedEmployeesState copyWith({
    List<Employee>? employees,
    bool? hasMore,
    bool? isLoadingMore,
    int? page,
    String? error,
  }) {
    return PaginatedEmployeesState(
      employees: employees ?? this.employees,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      page: page ?? this.page,
      error: error ?? this.error,
    );
  }
}

final employeesProvider = AsyncNotifierProvider<EmployeesNotifier, PaginatedEmployeesState>(() {
  return EmployeesNotifier();
});

class EmployeesNotifier extends AsyncNotifier<PaginatedEmployeesState> {
  @override
  Future<PaginatedEmployeesState> build() async {
    final repository = ref.read(employeeRepositoryProvider);
    final searchQuery = ref.watch(employeeSearchQueryProvider);
    final departmentFilter = ref.watch(employeeDepartmentFilterProvider);
    final branchFilter = ref.watch(employeeBranchFilterProvider);

    final response = await repository.getEmployees(
      page: 1,
      perPage: 15,
      search: searchQuery,
      departmentId: departmentFilter,
      branchId: branchFilter,
    );

    final hasMore = response.meta?.currentPage != null && 
                    response.meta?.lastPage != null && 
                    response.meta!.currentPage! < response.meta!.lastPage!;

    return PaginatedEmployeesState(
      employees: response.data,
      hasMore: hasMore,
      page: 1,
    );
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore || currentState.isLoadingMore) {
      return;
    }

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final repository = ref.read(employeeRepositoryProvider);
      final searchQuery = ref.read(employeeSearchQueryProvider);
      final departmentFilter = ref.read(employeeDepartmentFilterProvider);
      final branchFilter = ref.read(employeeBranchFilterProvider);

      final nextPage = currentState.page + 1;
      final response = await repository.getEmployees(
        page: nextPage,
        perPage: 15,
        search: searchQuery,
        departmentId: departmentFilter,
        branchId: branchFilter,
      );

      final hasMore = response.meta?.currentPage != null && 
                      response.meta?.lastPage != null && 
                      response.meta!.currentPage! < response.meta!.lastPage!;

      state = AsyncData(currentState.copyWith(
        employees: [...currentState.employees, ...response.data],
        hasMore: hasMore,
        page: nextPage,
        isLoadingMore: false,
      ));
    } catch (e) {
      state = AsyncData(currentState.copyWith(isLoadingMore: false, error: e.toString()));
    }
  }
}
