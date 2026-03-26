import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hybrid_digital_docs_assignment_frontend/core/api/api_client.dart';
import 'package:hybrid_digital_docs_assignment_frontend/features/auth/repositories/auth_repository.dart';

final authProvider = NotifierProvider<AuthNotifier, bool>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<void> initialize() async {
    final sharedPrefs = await ref.read(sharedPrefsProvider.future);
    final token = sharedPrefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      state = true;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final repository = ref.read(authRepositoryProvider);
      final token = await repository.login(email, password);
      
      final sharedPrefs = await ref.read(sharedPrefsProvider.future);
      await sharedPrefs.setString('auth_token', token);
      
      state = true;
    } catch (e) {
      // Re-throw to be handled by the UI
      rethrow;
    }
  }

  Future<void> logout() async {
    final sharedPrefs = await ref.read(sharedPrefsProvider.future);
    await sharedPrefs.remove('auth_token');
    state = false;
  }
}

// Persist the initialization state using Notifier for consistency
final appInitializedProvider = NotifierProvider<AppInitializedNotifier, bool>(() {
  return AppInitializedNotifier();
});

class AppInitializedNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void setInitialized(bool value) {
    state = value;
  }
}
