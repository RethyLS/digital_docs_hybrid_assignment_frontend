import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/api/api_client.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/models/document_response.dart';

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
}
