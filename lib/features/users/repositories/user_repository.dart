import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/api/api_client.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/user_list_response.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/user.dart';

import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/role.dart';

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

  Future<bool> createUser(User user, {String? password, String? passwordConfirmation}) async {
    try {
      final data = user.toJson();
      if (password != null && password.isNotEmpty) {
        data['password'] = password;
      }
      if (passwordConfirmation != null && passwordConfirmation.isNotEmpty) {
        data['password_confirmation'] = passwordConfirmation;
      }
      
      // Spatie expects an array of role names, not role objects
      if (data.containsKey('roles') && data['roles'] != null) {
        final rolesList = data['roles'] as List;
        if (rolesList.isNotEmpty) {
          if (rolesList.first is Map) {
            data['roles'] = rolesList.map((r) => (r as Map)['name']).toList();
          } else if (rolesList.first is Role) {
            data['roles'] = rolesList.map((r) => (r as Role).name).toList();
          }
        } else if (rolesList.isEmpty) {
           data.remove('roles');
        }
      }

      final response = await _dio.post('/users', data: data);
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
      throw Exception('Failed to create user: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<bool> updateUser(int id, User user) async {
    try {
      final data = user.toJson();

      // Spatie expects an array of role names, not role objects
      if (data.containsKey('roles') && data['roles'] != null) {
        final rolesList = data['roles'] as List;
        if (rolesList.isNotEmpty) {
          if (rolesList.first is Map) {
            data['roles'] = rolesList.map((r) => (r as Map)['name']).toList();
          } else if (rolesList.first is Role) {
            data['roles'] = rolesList.map((r) => (r as Role).name).toList();
          }
        } else if (rolesList.isEmpty) {
           data.remove('roles'); // Don't wipe roles if empty array is passed inadvertently
        }
      }

      final response = await _dio.put('/users/$id', data: data);
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
      throw Exception('Failed to update user: ${e.message}');
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

