import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/api/api_client.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/models/role_list_response.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/models/permission_list_response.dart';

final roleRepositoryProvider = Provider<RoleRepository>((ref) {
  return RoleRepository(ref.watch(dioProvider));
});

class RoleRepository {
  final Dio _dio;

  RoleRepository(this._dio);

  Future<RoleListResponse> getRoles({int page = 1, int perPage = 15, String? search}) async {
    try {
      final response = await _dio.get('/roles', queryParameters: {
        'page': page,
        'per_page': perPage,
        if (search != null && search.isNotEmpty) 'search': search,
      });
      return RoleListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load roles: $e');
    }
  }

  Future<PermissionListResponse> getPermissions({int page = 1, int perPage = 100}) async {
    try {
      final response = await _dio.get('/permissions', queryParameters: {
        'page': page,
        'per_page': perPage,
      });
      return PermissionListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load permissions: $e');
    }
  }

  Future<bool> createRole(String name, String? description, List<String> permissions) async {
    try {
      final response = await _dio.post('/roles', data: {
        'name': name,
        'description': description,
        'permissions': permissions,
      });
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to create role: $e');
    }
  }

  Future<bool> updateRole(int id, String name, String? description, List<String> permissions) async {
    try {
      final response = await _dio.put('/roles/$id', data: {
        'name': name,
        'description': description,
        'permissions': permissions,
      });
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Failed to update role: $e');
    }
  }

  Future<bool> deleteRole(int id) async {
    try {
      final response = await _dio.delete('/roles/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Failed to delete role: $e');
    }
  }
}

