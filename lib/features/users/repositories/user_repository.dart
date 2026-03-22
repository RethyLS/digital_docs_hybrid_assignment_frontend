import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/api/api_client.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/user_list_response.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/user.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(dioProvider));
});

class UserRepository {
  final Dio _dio;

  UserRepository(this._dio);

  Future<UserListResponse> getUsers({
    int page = 1,
    int perPage = 15,
    String? searchQuery,
    String? statusFilter,
    String? roleFilter,
  }) async {
    try {
      final response = await _dio.get('/users', queryParameters: {
        'page': page,
        'per_page': perPage,
        if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery,
        if (statusFilter != null && statusFilter.isNotEmpty) 'status': statusFilter,
        if (roleFilter != null && roleFilter.isNotEmpty) 'role': roleFilter,
      });
      return UserListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

  Future<bool> createUser(User user, {String? password}) async {
    try {
      final data = user.toJson();
      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }
      final response = await _dio.post('/users', data: data);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<bool> updateUser(int id, User user) async {
    try {
      final response = await _dio.put('/users/$id', data: user.toJson());
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      final response = await _dio.delete('/users/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
}

