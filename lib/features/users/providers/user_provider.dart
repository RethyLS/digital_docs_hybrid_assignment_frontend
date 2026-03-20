import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/user_list_response.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/repositories/user_repository.dart';

final usersProvider = FutureProvider.autoDispose<UserListResponse>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUsers();
});
