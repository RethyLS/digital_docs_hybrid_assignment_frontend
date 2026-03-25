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
    // Increased timeouts to 30 seconds to handle Laravel slow responses or emulator lag
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
    },
  ));

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Smart URL Resolver: Automatically figure out the right IP for Emulators vs Physical devices
        if (globalResolvedBaseUrl == null) {
          if (!kIsWeb && Platform.isAndroid) {
            try {
              // Quick 2-second ping to 10.0.2.2 (The standard Android Emulator magic IP)
              final pingDio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 2), receiveTimeout: const Duration(seconds: 2)));
              await pingDio.head('http://10.0.2.2:8000/api');
              
              // If it connects instantly without error, we are on an Emulator
              globalResolvedBaseUrl = 'http://10.0.2.2:8000/api';
            } catch (e) {
              // If it fails (Timeout/Connection Refused), we are on a Physical Device using adb reverse
              globalResolvedBaseUrl = 'http://127.0.0.1:8000/api';
            }
          } else {
            // iOS Simulators, Web, Desktop all use 127.0.0.1
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
