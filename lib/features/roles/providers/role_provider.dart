import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/models/permission_list_response.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/models/role_list_response.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/roles/repositories/role_repository.dart';

final rolesProvider = FutureProvider.autoDispose<RoleListResponse>((ref) async {
  final repository = ref.watch(roleRepositoryProvider);
  return repository.getRoles();
});

final permissionsProvider = FutureProvider.autoDispose<PermissionListResponse>((ref) async {
  final repository = ref.watch(roleRepositoryProvider);
  return repository.getPermissions();
});
