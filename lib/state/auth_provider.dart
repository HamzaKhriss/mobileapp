import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final String? userName;
  final String? userEmail;

  AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.userName,
    this.userEmail,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    String? userName,
    String? userEmail,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<bool> signUp(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'All fields are required',
      );
      return false;
    }

    state = state.copyWith(
      isAuthenticated: true,
      isLoading: false,
      userName: name,
      userEmail: email,
    );
    return true;
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Allow empty credentials for easy testing
    state = state.copyWith(
      isAuthenticated: true,
      isLoading: false,
      userName: email.isEmpty ? 'Test User' : 'User',
      userEmail: email.isEmpty ? 'test@casawonders.com' : email,
    );
    return true;
  }

  void logout() {
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
