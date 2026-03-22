import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/models/document_response.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/documents/models/document.dart';
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

class PaginatedDocumentsState {
  final List<Document> documents;
  final bool hasMore;
  final bool isLoadingMore;
  final int page;
  final String? error;

  PaginatedDocumentsState({
    this.documents = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.page = 1,
    this.error,
  });

  PaginatedDocumentsState copyWith({
    List<Document>? documents,
    bool? hasMore,
    bool? isLoadingMore,
    int? page,
    String? error,
  }) {
    return PaginatedDocumentsState(
      documents: documents ?? this.documents,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      page: page ?? this.page,
      error: error ?? this.error,
    );
  }
}

final documentsProvider = AsyncNotifierProvider<DocumentsNotifier, PaginatedDocumentsState>(() {
  return DocumentsNotifier();
});

class DocumentsNotifier extends AsyncNotifier<PaginatedDocumentsState> {
  @override
  Future<PaginatedDocumentsState> build() async {
    final repository = ref.read(documentRepositoryProvider);
    final searchQuery = ref.watch(documentSearchQueryProvider);
    final statusFilter = ref.watch(documentStatusFilterProvider);
    final categoryFilter = ref.watch(documentCategoryFilterProvider);

    String? apiStatus;
    if (statusFilter != 'All Statuses') {
      apiStatus = statusFilter.toLowerCase();
    }

    final response = await repository.getDocuments(
      page: 1,
      perPage: 15,
      search: searchQuery,
      status: apiStatus,
      categoryId: categoryFilter,
    );

    final hasMore = response.meta?.currentPage != null && 
                    response.meta?.lastPage != null && 
                    response.meta!.currentPage! < response.meta!.lastPage!;

    return PaginatedDocumentsState(
      documents: response.data,
      hasMore: hasMore,
      page: 1,
    );
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore || currentState.isLoadingMore) {
      return;
    }

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      final repository = ref.read(documentRepositoryProvider);
      final searchQuery = ref.read(documentSearchQueryProvider);
      final statusFilter = ref.read(documentStatusFilterProvider);
      final categoryFilter = ref.read(documentCategoryFilterProvider);

      String? apiStatus;
      if (statusFilter != 'All Statuses') {
        apiStatus = statusFilter.toLowerCase();
      }

      final nextPage = currentState.page + 1;
      final response = await repository.getDocuments(
        page: nextPage,
        perPage: 15,
        search: searchQuery,
        status: apiStatus,
        categoryId: categoryFilter,
      );

      final hasMore = response.meta?.currentPage != null && 
                      response.meta?.lastPage != null && 
                      response.meta!.currentPage! < response.meta!.lastPage!;

      state = AsyncData(currentState.copyWith(
        documents: [...currentState.documents, ...response.data],
        hasMore: hasMore,
        page: nextPage,
        isLoadingMore: false,
      ));
    } catch (e) {
      state = AsyncData(currentState.copyWith(isLoadingMore: false, error: e.toString()));
    }
  }
}
