import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/utils/image_utils.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);

  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Accept': 'application/json',
    },
  ));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Resolve the base URL dynamically on the first request
        if (globalResolvedBaseUrl == null) {
          if (!kIsWeb && Platform.isAndroid) {
            final androidInfo = await DeviceInfoPlugin().androidInfo;
            // Emulators use 10.0.2.2, Physical devices use 127.0.0.1 (via adb reverse)
            globalResolvedBaseUrl = androidInfo.isPhysicalDevice
                ? 'http://127.0.0.1:8000/api'
                : 'http://10.0.2.2:8000/api';
          } else {
            globalResolvedBaseUrl = 'http://127.0.0.1:8000/api';
          }
        }
        
        options.baseUrl = globalResolvedBaseUrl!;

        final token = await secureStorage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
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
