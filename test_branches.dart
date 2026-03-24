import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/branch.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/department.dart';

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
    
    final branchesResponse = await dio.get('/branches', queryParameters: {'per_page': 100});
    final branchesData = branchesResponse.data['data'] as List;
    final branches = branchesData.map((e) => Branch.fromJson(e)).toList();
    print('Parsed ${branches.length} branches successfully.');
    
    final departmentsResponse = await dio.get('/departments', queryParameters: {'per_page': 100});
    final deptsData = departmentsResponse.data['data'] as List;
    final depts = deptsData.map((e) => Department.fromJson(e)).toList();
    print('Parsed ${depts.length} departments successfully.');
    
  } on DioException catch (e) {
    print('Dio Error: ${e.response?.statusCode} - ${e.response?.data}');
  } catch (e) {
    print('Error: $e');
  }
}


