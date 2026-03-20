import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/user.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/repositories/user_profile_repository.dart';

final userProfileProvider = FutureProvider.autoDispose<User>((ref) async {
  final repository = ref.watch(userProfileRepositoryProvider);
  return repository.getUserProfile();
});
