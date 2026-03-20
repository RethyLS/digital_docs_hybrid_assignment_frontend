import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/api/api_client.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/user.dart';

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  return UserProfileRepository(ref.watch(dioProvider));
});

class UserProfileRepository {
  final Dio _dio;

  UserProfileRepository(this._dio);

  Future<User> getUserProfile() async {
    try {
      final response = await _dio.get('/me');
      // Assuming the backend returns the user object directly, or wrapped in 'data'.
      // If it's wrapped in 'data', use response.data['data']
      final data = response.data['data'] ?? response.data;
      return User.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load user profile: $e');
    }
  }
}
