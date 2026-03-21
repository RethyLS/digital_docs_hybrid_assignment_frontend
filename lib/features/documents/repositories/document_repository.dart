import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/api/api_client.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/models/document_response.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/branch.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/category.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/document_prefix.dart';
import 'package:path_provider/path_provider.dart';

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository(ref.watch(dioProvider));
});

class DocumentRepository {
  final Dio _dio;

  DocumentRepository(this._dio);

  Future<DocumentResponse> getDocuments({int page = 1, int perPage = 15}) async {
    try {
      final response = await _dio.get('/documents', queryParameters: {
        'page': page,
        'per_page': perPage,
      });
      return DocumentResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load documents: $e');
    }
  }

  Future<List<Branch>> getBranches() async {
    try {
      final response = await _dio.get('/branches');
      final data = response.data['data'] as List;
      return data.map((json) => Branch.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/document-categories');
      final data = response.data['data'] as List;
      return data.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<DocumentPrefix>> getDocumentPrefixes() async {
    try {
      // Assuming a generic endpoint to fetch all active prefixes for a dropdown
      final response = await _dio.get('/document-prefixes', queryParameters: {
        'per_page': 100, // Large number to get all for the dropdown
      });
      final data = response.data['data'] as List;
      return data.map((json) => DocumentPrefix.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> uploadDocument({
    required String filePath,
    String? title,
    String? description,
    int? categoryId,
    int? branchId,
    int? prefixId,
    String? status,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (categoryId != null) 'document_category_id': categoryId,
        if (branchId != null) 'branch_id': branchId,
        if (prefixId != null) 'document_prefix_id': prefixId,
        if (status != null) 'status': status,
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(
        '/documents',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      if (e is DioException) {
         throw Exception(e.response?.data['message'] ?? e.message);
      }
      throw Exception('Failed to upload document: $e');
    }
  }

  Future<String> downloadDocument(int id, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      
      await _dio.download(
        '/documents/$id/download', 
        filePath,
        options: Options(
          receiveTimeout: const Duration(minutes: 5),
        ),
      );
      return filePath;
    } catch (e) {
      if (e is DioException) {
         throw Exception(e.response?.data['message'] ?? e.message);
      }
      throw Exception('Failed to download document: $e');
    }
  }

  Future<bool> deleteDocument(int id) async {
    try {
      final response = await _dio.delete('/documents/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }
}



