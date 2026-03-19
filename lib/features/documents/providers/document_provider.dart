import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/models/document_response.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/repositories/document_repository.dart';

final documentsProvider = FutureProvider.autoDispose<DocumentResponse>((ref) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getDocuments();
});
