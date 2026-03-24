import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/models/user.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/users/repositories/user_profile_repository.dart';

final userProfileProvider = AsyncNotifierProvider<UserProfileNotifier, User>(() {
  return UserProfileNotifier();
});

class UserProfileNotifier extends AsyncNotifier<User> {
  @override
  Future<User> build() async {
    final repository = ref.read(userProfileRepositoryProvider);
    return repository.getUserProfile();
  }

  Future<bool> updateProfile(int userId, Map<String, dynamic> payload) async {
    try {
      final repository = ref.read(userProfileRepositoryProvider);
      final updatedUser = await repository.updateProfile(userId, payload);
      state = AsyncData(updatedUser);
      return true;
    } catch (e) {
      // Allow the UI to handle the error presentation
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> updateAvatar(File imageFile) async {
    try {
      final repository = ref.read(userProfileRepositoryProvider);
      final updatedUser = await repository.updateAvatar(imageFile);
      state = AsyncData(updatedUser);
      return true;
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
