import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/models/employee_response.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/repositories/employee_repository.dart';

final employeesProvider = FutureProvider.autoDispose<EmployeeResponse>((ref) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return repository.getEmployees();
});
