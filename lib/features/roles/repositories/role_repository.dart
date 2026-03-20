import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/api/api_client.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/models/role_list_response.dart';

final roleRepositoryProvider = Provider<RoleRepository>((ref) {
  return RoleRepository(ref.watch(dioProvider));
});

class RoleRepository {
  final Dio _dio;

  RoleRepository(this._dio);

  Future<RoleListResponse> getRoles({int page = 1, int perPage = 15}) async {
    try {
      final response = await _dio.get('/roles', queryParameters: {
        'page': page,
        'per_page': perPage,
      });
      return RoleListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load roles: $e');
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
