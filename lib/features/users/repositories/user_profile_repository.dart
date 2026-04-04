import 'dart:io';
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
      final data = response.data['data'] ?? response.data;
      return User.fromJson(data);
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message']);
        }
      }
      throw Exception(e.message ?? 'Unknown network error');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> updatePassword(String oldPassword, String newPassword, String newPasswordConfirmation) async {
    try {
      final response = await _dio.put('/me/password', data: {
        'old_password': oldPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      });
      return response.statusCode == 200;
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
      throw Exception(e.message ?? 'Unknown network error');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<User> updateProfile(int userId, Map<String, dynamic> payload) async {
    try {
      final response = await _dio.put('/users/$userId', data: payload);
      final data = response.data['data'] ?? response.data;
      return User.fromJson(data);
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
      throw Exception('Failed to update profile: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  Future<User> updateAvatar(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(imageFile.path, filename: fileName),
      });

      final response = await _dio.post('/me/avatar', data: formData);
      final data = response.data['data'] ?? response.data;
      return User.fromJson(data);
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
      throw Exception('Failed to update avatar: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update avatar: $e');
    }
  }
}
