import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/api/api_client.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/models/employee_response.dart';

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository(ref.watch(dioProvider));
});

class EmployeeRepository {
  final Dio _dio;

  EmployeeRepository(this._dio);

  Future<EmployeeResponse> getEmployees({int page = 1, int perPage = 15}) async {
    try {
      final response = await _dio.get('/employees', queryParameters: {
        'page': page,
        'per_page': perPage,
      });
      return EmployeeResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load employees: $e');
    }
  }
}
