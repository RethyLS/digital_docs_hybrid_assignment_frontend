import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/user.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8000/api',
    headers: {
      'Accept': 'application/json',
    }
  ));
  
  try {
    final loginRes = await dio.post('/login', data: {
      'email': 'superadmin@system.com',
      'password': 'password'
    });
    
    final token = loginRes.data['data']['token'];
    dio.options.headers['Authorization'] = 'Bearer $token';
    
    final response = await dio.get('/me');
    final data = response.data['data'] ?? response.data;
    final user = User.fromJson(data);
    print('User parsed successfully: ${user.fullName}');
  } on DioException catch (e) {
    print('Dio Error: ${e.response?.statusCode} - ${e.response?.data}');
  } catch (e) {
    print('Error: $e');
  }
}

