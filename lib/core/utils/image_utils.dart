import 'dart:io';
import 'package:flutter/foundation.dart';

String getFullImageUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  
  // Utilizing adb reverse tcp:8000 tcp:8000 
  final String baseUrl = 'http://127.0.0.1:8000/storage/';
      
  // Clean up path if it starts with a slash
  final cleanPath = path.startsWith('/') ? path.substring(1) : path;
  return '$baseUrl$cleanPath';
}
