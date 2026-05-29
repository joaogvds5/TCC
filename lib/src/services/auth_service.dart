// lib/src/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  static AuthService get instance => _instance;
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    debugPrint('🔑 AuthService - Tentando login: $email');

    final response = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );

    debugPrint(
      '🔑 AuthService - Resposta: user=${response.user != null}, session=${response.session != null}',
    );

    return response;
  }

  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabaseClient.auth.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  Future<void> updateEmail(String newEmail) async {
    await _supabaseClient.auth.updateUser(UserAttributes(email: newEmail));
  }

  Future<void> updatePassword(String newPassword) async {
    await _supabaseClient.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  Future<void> resetPassword(String email) async {
    await _supabaseClient.auth.resetPasswordForEmail(email);
  }

  String? getCurrentUserEmail() {
    return _supabaseClient.auth.currentUser?.email;
  }

  String? getCurrentUserId() {
    return _supabaseClient.auth.currentUser?.id;
  }

  bool get isLoggedIn => _supabaseClient.auth.currentSession != null;

  User? get currentUser => _supabaseClient.auth.currentUser;
}
