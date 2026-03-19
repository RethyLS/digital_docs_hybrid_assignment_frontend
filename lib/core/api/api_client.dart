import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  // Use 10.0.2.2 for Android Emulator to connect to local backend, otherwise 127.0.0.1
  final String baseUrl = !kIsWeb && Platform.isAndroid 
      ? 'http://10.0.2.2:8000/api'
      : 'http://127.0.0.1:8000/api';

  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Accept': 'application/json',
    },
  ));

  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  return dio;
});
