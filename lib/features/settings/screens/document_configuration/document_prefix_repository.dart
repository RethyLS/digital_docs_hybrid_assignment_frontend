import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/api/api_client.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/document_prefix.dart';

final documentPrefixRepositoryProvider = Provider<DocumentPrefixRepository>((ref) {
  return DocumentPrefixRepository(ref.watch(dioProvider));
});

class DocumentPrefixRepository {
  final Dio _dio;

  DocumentPrefixRepository(this._dio);

  Future<List<DocumentPrefix>> getPrefixes({int page = 1, int perPage = 50}) async {
    try {
      final response = await _dio.get('/document-prefixes', queryParameters: {
        'page': page,
        'per_page': perPage,
      });
      final data = response.data['data'] as List;
      return data.map((json) => DocumentPrefix.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load prefixes: $e');
    }
  }

  Future<bool> createPrefix(DocumentPrefix prefix) async {
    try {
      final response = await _dio.post('/document-prefixes', data: prefix.toJson());
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          if (data.containsKey('errors')) {
            final errors = data['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first[0];
            throw Exception(firstError.toString());
          }
          if (data.containsKey('message')) {
            throw Exception(data['message']);
          }
        }
      }
      throw Exception('Failed to create prefix: ${e.message}');
    } catch (e) {
      throw Exception('Failed to create prefix: $e');
    }
  }

  Future<bool> updatePrefix(int id, DocumentPrefix prefix) async {
    try {
      final response = await _dio.put('/document-prefixes/$id', data: prefix.toJson());
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          if (data.containsKey('errors')) {
            final errors = data['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first[0];
            throw Exception(firstError.toString());
          }
          if (data.containsKey('message')) {
            throw Exception(data['message']);
          }
        }
      }
      throw Exception('Failed to update prefix: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update prefix: $e');
    }
  }

  Future<bool> deletePrefix(int id) async {
    try {
      final response = await _dio.delete('/document-prefixes/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          if (data.containsKey('errors')) {
            final errors = data['errors'] as Map<String, dynamic>;
            final firstError = errors.values.first[0];
            throw Exception(firstError.toString());
          }
          if (data.containsKey('message')) {
            throw Exception(data['message']);
          }
        }
      }
      throw Exception('Failed to delete prefix: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete prefix: $e');
    }
  }
}
