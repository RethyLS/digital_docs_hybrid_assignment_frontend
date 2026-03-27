import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/repositories/role_repository.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/role.dart';

final allRolesProvider = FutureProvider.autoDispose<List<Role>>((ref) async {
  final repo = ref.watch(roleRepositoryProvider);
  final response = await repo.getRoles(page: 1, perPage: 100);
  return response.data;
});
