import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  
  // Since you are using 'adb reverse tcp:8000 tcp:8000', 
  // 127.0.0.1 will work perfectly for both the physical device and web/desktop.
  final String baseUrl = 'http://127.0.0.1:8000/api';

  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Accept': 'application/json',
    },
  ));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await secureStorage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // Log request manually to avoid stream issues
        if (kDebugMode) {
          print('--> ${options.method.toUpperCase()} ${options.baseUrl}${options.path}');
        }
        
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('<-- ${response.statusCode} ${response.requestOptions.baseUrl}${response.requestOptions.path}');
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (kDebugMode) {
          print('<-- Error ${e.message}');
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
});
