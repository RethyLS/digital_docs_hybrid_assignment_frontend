import 'dart:io';
import 'package:flutter/foundation.dart';

// This is populated by api_client.dart dynamically on the first network request
String? globalResolvedBaseUrl;

String getFullImageUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  
  // Use dynamically resolved URL, fallback to 127.0.0.1 if not yet resolved
  String baseUrl = globalResolvedBaseUrl ?? 'http://127.0.0.1:8000/api';
  
  // Replace /api with /storage/ for images
  baseUrl = baseUrl.replaceAll('/api', '/storage/');
      
  // Clean up path if it starts with a slash
  final cleanPath = path.startsWith('/') ? path.substring(1) : path;
  return '$baseUrl$cleanPath';
}
