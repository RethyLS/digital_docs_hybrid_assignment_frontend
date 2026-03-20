import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/api/api_client.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/models/employee_response.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/models/employee.dart';

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

  Future<bool> createEmployee(Employee employee) async {
    try {
      final response = await _dio.post('/employees', data: employee.toJson());
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to create employee: $e');
    }
  }

  Future<bool> updateEmployee(int id, Employee employee) async {
    try {
      final response = await _dio.put('/employees/$id', data: employee.toJson());
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Failed to update employee: $e');
    }
  }

  Future<bool> deleteEmployee(int id) async {
    try {
      final response = await _dio.delete('/employees/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Failed to delete employee: $e');
    }
  }
}

