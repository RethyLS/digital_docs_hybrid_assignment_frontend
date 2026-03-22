import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/models/role_list_response.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/repositories/role_repository.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/user_list_response.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/user.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/repositories/user_repository.dart';

final userSearchQueryProvider = NotifierProvider<UserSearchQueryNotifier, String>(() {
  return UserSearchQueryNotifier();
});

class UserSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void updateQuery(String query) {
    state = query;
  }
}

final userStatusFilterProvider = NotifierProvider<UserStatusFilterNotifier, String>(() {
  return UserStatusFilterNotifier();
});

class UserStatusFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All Statuses';

  void updateStatus(String status) {
    state = status;
  }
}

final userRoleFilterProvider = NotifierProvider<UserRoleFilterNotifier, String?>(() {
  return UserRoleFilterNotifier();
});

class UserRoleFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void updateRole(String? roleName) {
    state = roleName;
  }
}

final userRolesProvider = FutureProvider.autoDispose<RoleListResponse>((ref) async {
  final repository = ref.watch(roleRepositoryProvider);
  return repository.getRoles(page: 1, perPage: 100); // Fetch enough roles for dropdown
});

class PaginatedUsersState {
  final List<User> users;
  final bool hasMore;
  final bool isLoadingMore;
  final int page;
  final String? error;

  PaginatedUsersState({
    this.users = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.page = 1,
    this.error,
  });

  PaginatedUsersState copyWith({
    List<User>? users,
    bool? hasMore,
    bool? isLoadingMore,
    int? page,
    String? error,
  }) {
    return PaginatedUsersState(
      users: users ?? this.users,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      page: page ?? this.page,
      error: error ?? this.error,
    );
  }
}

final usersProvider = AsyncNotifierProvider<UsersNotifier, PaginatedUsersState>(() {
  return UsersNotifier();
});

class UsersNotifier extends AsyncNotifier<PaginatedUsersState> {
  @override
  Future<PaginatedUsersState> build() async {
    final repository = ref.read(userRepositoryProvider);
    final searchQuery = ref.watch(userSearchQueryProvider);
    final statusFilter = ref.watch(userStatusFilterProvider);
    final roleFilter = ref.watch(userRoleFilterProvider);

    String? apiStatus;
    if (statusFilter != 'All Statuses') {
      apiStatus = statusFilter.toLowerCase();
    }

    final response = await repository.getUsers(
      page: 1,
      perPage: 15,
      searchQuery: searchQuery,
      statusFilter: apiStatus,
      roleFilter: roleFilter,
    );

    final hasMore = response.meta?.currentPage != null && 
                    response.meta?.lastPage != null && 
                    response.meta!.currentPage! < response.meta!.lastPage!;

    return PaginatedUsersState(
      users: response.data,
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
      final repository = ref.read(userRepositoryProvider);
      final searchQuery = ref.read(userSearchQueryProvider);
      final statusFilter = ref.read(userStatusFilterProvider);
      final roleFilter = ref.read(userRoleFilterProvider);

      String? apiStatus;
      if (statusFilter != 'All Statuses') {
        apiStatus = statusFilter.toLowerCase();
      }

      final nextPage = currentState.page + 1;
      final response = await repository.getUsers(
        page: nextPage,
        perPage: 15,
        searchQuery: searchQuery,
        statusFilter: apiStatus,
        roleFilter: roleFilter,
      );

      final hasMore = response.meta?.currentPage != null && 
                      response.meta?.lastPage != null && 
                      response.meta!.currentPage! < response.meta!.lastPage!;

      state = AsyncData(currentState.copyWith(
        users: [...currentState.users, ...response.data],
        hasMore: hasMore,
        page: nextPage,
        isLoadingMore: false,
      ));
    } catch (e) {
      state = AsyncData(currentState.copyWith(isLoadingMore: false, error: e.toString()));
    }
  }
}
