import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/api/api_client.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/models/employee_response.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/employees/models/employee.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/branch.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/department.dart';

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepository(ref.watch(dioProvider));
});

class EmployeeRepository {
  final Dio _dio;

  EmployeeRepository(this._dio);

  Future<EmployeeResponse> getEmployees({
    int page = 1, 
    int perPage = 15,
    String? search,
    int? departmentId,
    int? branchId,
  }) async {
    try {
      final response = await _dio.get('/employees', queryParameters: {
        'page': page,
        'per_page': perPage,
        if (search != null && search.isNotEmpty) 'search': search,
        if (departmentId != null) 'department_id': departmentId,
        if (branchId != null) 'branch_id': branchId,
      });
      return EmployeeResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load employees: $e');
    }
  }

  Future<List<Branch>> getBranches() async {
    try {
      final response = await _dio.get('/branches', queryParameters: {'per_page': 100});
      final data = response.data['data'] as List;
      return data.map((json) => Branch.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load branches: $e');
    }
  }

  Future<List<Department>> getDepartments() async {
    try {
      final response = await _dio.get('/departments', queryParameters: {'per_page': 100});
      final data = response.data['data'] as List;
      return data.map((json) => Department.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load departments: $e');
    }
  }

  Future<bool> createEmployee(Employee employee) async {
    try {
      final response = await _dio.post('/employees', data: employee.toJson());
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          if (data.containsKey('errors')) {
            final errors = data['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first[0];
            throw Exception(firstError.toString());
          }
          if (data.containsKey('message')) {
            throw Exception(data['message']);
          }
        }
      }
      throw Exception('Failed to create employee: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create employee: $e');
    }
  }

  Future<bool> updateEmployee(int id, Employee employee) async {
    try {
      final response = await _dio.put('/employees/$id', data: employee.toJson());
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          if (data.containsKey('errors')) {
            final errors = data['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first[0];
            throw Exception(firstError.toString());
          }
          if (data.containsKey('message')) {
            throw Exception(data['message']);
          }
        }
      }
      throw Exception('Failed to update employee: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update employee: $e');
    }
  }

  Future<bool> deleteEmployee(int id) async {
    try {
      final response = await _dio.delete('/employees/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception('Failed to delete employee: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete employee: $e');
    }
  }
}

