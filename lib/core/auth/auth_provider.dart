import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = NotifierProvider<AuthNotifier, bool>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void login() {
    state = true;
  }

  void logout() {
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
