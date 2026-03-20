import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/api/api_client.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/models/document_response.dart';
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

  Future<bool> uploadDocument({
    required String filePath,
    String? title,
    String? description,
    int? categoryId,
    int? branchId,
    String? status,
  }) async {
    try {
      final formData = FormData.fromMap({
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (categoryId != null) 'category_id': categoryId,
        if (branchId != null) 'branch_id': branchId,
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
      throw Exception('Failed to upload document: $e');
    }
  }

  Future<String> downloadDocument(String url, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      
      await _dio.download(url, filePath);
      return filePath;
    } catch (e) {
      throw Exception('Failed to download document: $e');
    }
  }
}

