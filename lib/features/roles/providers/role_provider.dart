import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/models/permission_list_response.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/models/role_list_response.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/repositories/role_repository.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/role.dart';

final roleSearchQueryProvider = NotifierProvider<RoleSearchQueryNotifier, String>(() {
  return RoleSearchQueryNotifier();
});

class RoleSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }
}

final permissionsProvider = FutureProvider.autoDispose<PermissionListResponse>((ref) async {
  final repository = ref.watch(roleRepositoryProvider);
  return repository.getPermissions();
});

class PaginatedRolesState {
  final List<Role> roles;
  final bool hasMore;
  final bool isLoadingMore;
  final int page;
  final String? error;

  PaginatedRolesState({
    this.roles = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.page = 1,
    this.error,
  });

  PaginatedRolesState copyWith({
    List<Role>? roles,
    bool? hasMore,
    bool? isLoadingMore,
    int? page,
    String? error,
  }) {
    return PaginatedRolesState(
      roles: roles ?? this.roles,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      page: page ?? this.page,
      error: error ?? this.error,
    );
  }
}

final rolesProvider = AsyncNotifierProvider<RolesNotifier, PaginatedRolesState>(() {
  return RolesNotifier();
});

class RolesNotifier extends AsyncNotifier<PaginatedRolesState> {
  @override
  Future<PaginatedRolesState> build() async {
    final repository = ref.read(roleRepositoryProvider);
    final searchQuery = ref.watch(roleSearchQueryProvider);

    final response = await repository.getRoles(
      page: 1,
      perPage: 15,
      search: searchQuery,
    );

    final hasMore = response.meta?.currentPage != null && 
                    response.meta?.lastPage != null && 
                    response.meta!.currentPage! < response.meta!.lastPage!;

    return PaginatedRolesState(
      roles: response.data,
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
      final repository = ref.read(roleRepositoryProvider);
      final searchQuery = ref.read(roleSearchQueryProvider);

      final nextPage = currentState.page + 1;
      final response = await repository.getRoles(
        page: nextPage,
        perPage: 15,
        search: searchQuery,
      );

      final hasMore = response.meta?.currentPage != null && 
                      response.meta?.lastPage != null && 
                      response.meta!.currentPage! < response.meta!.lastPage!;

      state = AsyncData(currentState.copyWith(
        roles: [...currentState.roles, ...response.data],
        hasMore: hasMore,
        page: nextPage,
        isLoadingMore: false,
      ));
    } catch (e) {
      state = AsyncData(currentState.copyWith(isLoadingMore: false, error: e.toString()));
    }
  }
}
