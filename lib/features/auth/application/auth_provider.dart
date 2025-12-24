import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/auth_service.dart';
import '../models/auth_models.dart';

/// Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Provider for Auth State
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService) : super(AuthState.initial()) {
    _checkAuthStatus();
  }

  final AuthService _authService;

  /// Check if user is already logged in on app start
  Future<void> _checkAuthStatus() async {
    state = AuthState.loading();

    try {
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          state = AuthState.authenticated(user);
          return;
        }
      }

      state = AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.unauthenticated(e.toString());
    }
  }

  /// Login with credentials
  Future<void> login(String email, String password) async {
    if (state.isLoading) return;

    state = AuthState.loading();

    try {
      final credentials = LoginCredentials(email: email, password: password);
      final authResponse = await _authService.login(credentials);

      state = AuthState.authenticated(authResponse.user);
    } catch (e) {
      state = AuthState.unauthenticated(e.toString());
      // Re-throw to allow UI to show error
      rethrow;
    }
  }

  /// Signup with credentials
  Future<void> signup(String email, String password, String displayName) async {
    if (state.isLoading) return;

    state = AuthState.loading();

    try {
      final credentials = SignupCredentials(
        email: email,
        password: password,
        displayName: displayName,
      );
      final authResponse = await _authService.signup(credentials);

      state = AuthState.authenticated(authResponse.user);
    } catch (e) {
      state = AuthState.unauthenticated(e.toString());
      // Re-throw to allow UI to show error
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    state = AuthState.unauthenticated();
  }

  /// Refresh user data
  Future<void> refreshUser() async {
    try {
      final user = await _authService.refreshUser();
      state = AuthState.authenticated(user);
    } catch (e) {
      // If refresh fails, keep current state
      print('Failed to refresh user: $e');
    }
  }
}
