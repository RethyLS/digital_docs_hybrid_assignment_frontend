import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/api/api_client.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      
      final data = response.data['data'];
      final token = data['token'];
      
      if (token == null) {
        throw Exception('Token not found in response');
      }

      return token as String;
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
      throw Exception(e.message ?? 'An unknown error occurred');
    } catch (e) {
      throw Exception('Failed to log in: $e');
    }
  }
}
