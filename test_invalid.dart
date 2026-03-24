import 'package:dio/dio.dart';

void main() async {
  try {
    await Dio().get('http://127.0.0.1:8000/api/me', options: Options(headers: {'Accept': 'application/json', 'Authorization': 'Bearer 1|invalid'}));
  } on DioException catch (e) {
    print('Status: ${e.response?.statusCode}');
    print('Data: ${e.response?.data}');
  }
}