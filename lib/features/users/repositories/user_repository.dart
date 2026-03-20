import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/api/api_client.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/user_list_response.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(dioProvider));
});

class UserRepository {
  final Dio _dio;

  UserRepository(this._dio);

  Future<UserListResponse> getUsers({int page = 1, int perPage = 15}) async {
    try {
      final response = await _dio.get('/users', queryParameters: {
        'page': page,
        'per_page': perPage,
      });
      return UserListResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }
}
