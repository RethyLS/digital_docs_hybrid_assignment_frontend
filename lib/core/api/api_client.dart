import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/utils/image_utils.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);

  final dio = Dio(BaseOptions(
    // 60-second timeouts to give the single-threaded Laravel server plenty of time
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    headers: {
      'Accept': 'application/json',
    },
  ));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (globalResolvedBaseUrl == null) {
          if (!kIsWeb && Platform.isAndroid) {
            try {
              final androidInfo = await DeviceInfoPlugin().androidInfo;
              if (androidInfo.isPhysicalDevice) {
                // Physical device connected via USB (adb reverse)
                globalResolvedBaseUrl = 'http://127.0.0.1:8000/api';
              } else {
                // Android Emulator mapping to Host PC
                globalResolvedBaseUrl = 'http://10.0.2.2:8000/api';
              }
            } catch (e) {
              // Failsafe
              globalResolvedBaseUrl = 'http://10.0.2.2:8000/api';
            }
          } else {
            // iOS Simulators, Web, Desktop
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
