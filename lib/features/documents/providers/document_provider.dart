import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/models/document_response.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/repositories/document_repository.dart';
import 'package:hybrid_digital_docs_assignment_frontend/shared/models/category.dart';

final documentSearchQueryProvider = NotifierProvider<DocumentSearchQueryNotifier, String>(() {
  return DocumentSearchQueryNotifier();
});

class DocumentSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  
  void updateQuery(String query) {
    state = query;
  }
}

final documentStatusFilterProvider = NotifierProvider<DocumentStatusFilterNotifier, String>(() {
  return DocumentStatusFilterNotifier();
});

class DocumentStatusFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All Statuses';
  
  void updateStatus(String status) {
    state = status;
  }
}

final documentCategoryFilterProvider = NotifierProvider<DocumentCategoryFilterNotifier, int?>(() {
  return DocumentCategoryFilterNotifier();
});

class DocumentCategoryFilterNotifier extends Notifier<int?> {
  @override
  int? build() => null;
  
  void updateCategory(int? categoryId) {
    state = categoryId;
  }
}

final categoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  final repository = ref.watch(documentRepositoryProvider);
  return repository.getCategories();
});

final documentsProvider = FutureProvider.autoDispose<DocumentResponse>((ref) async {
  final repository = ref.watch(documentRepositoryProvider);
  final searchQuery = ref.watch(documentSearchQueryProvider);
  final statusFilter = ref.watch(documentStatusFilterProvider);
  final categoryFilter = ref.watch(documentCategoryFilterProvider);

  String? apiStatus;
  if (statusFilter != 'All Statuses') {
    apiStatus = statusFilter.toLowerCase();
  }

  return repository.getDocuments(
    search: searchQuery,
    status: apiStatus,
    categoryId: categoryFilter,
  );
});
