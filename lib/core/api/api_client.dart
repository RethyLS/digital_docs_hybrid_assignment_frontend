import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/utils/image_utils.dart';

final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final dioProvider = Provider<Dio>((ref) {
  final sharedPrefsAsync = ref.watch(sharedPrefsProvider);

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
              // Create a temporary Dio instance to "ping" the emulator host IP
              final pingDio = Dio(BaseOptions(
                connectTimeout: const Duration(milliseconds: 1500),
              ));
              
              // If we are on an emulator, 10.0.2.2 will respond or at least not "Refuse Connection" instantly.
              // We just check if the host is reachable.
              await pingDio.get('http://10.0.2.2:8000/api/login');
              globalResolvedBaseUrl = 'http://10.0.2.2:8000/api';
            } on DioException catch (e) {
              // If the server responded with an HTTP error (like 405 Method Not Allowed),
              // it means the server IS there, so we are on an emulator!
              if (e.response != null || e.type == DioExceptionType.badResponse) {
                globalResolvedBaseUrl = 'http://10.0.2.2:8000/api';
              } else {
                // If it fails with ConnectionTimeout or ConnectionRefused, we are on a physical device
                // Since you are using Wireless ADB, we must hit your PC's actual Wi-Fi IP address instead of localhost.
                globalResolvedBaseUrl = 'http://192.168.1.103:8000/api';
              }
              } catch (e) {
              // Any other unknown error -> fallback to physical device 
              globalResolvedBaseUrl = 'http://192.168.1.103:8000/api';
              }
              } else {
              // iOS, Web, and Desktop
              globalResolvedBaseUrl = 'http://127.0.0.1:8000/api';
              }
              }

              options.baseUrl = globalResolvedBaseUrl!;
        final sharedPrefs = await ref.read(sharedPrefsProvider.future);
        final token = sharedPrefs.getString('auth_token');
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
