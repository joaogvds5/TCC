// lib/src/services/login_service.dart
import 'package:nearu/src/services/auth_service.dart';
import 'package:flutter/material.dart';

class LoginResult {
  final bool success;
  final String message;

  LoginResult({required this.success, required this.message});
}

class LoginService {
  final AuthService _authService;

  LoginService({AuthService? authService})
    : _authService = authService ?? AuthService.instance;

  Future<LoginResult> login(String email, String password) async {
    try {
      final response = await _authService.signInWithEmailPassword(
        email,
        password,
      );

      if (response.user != null && response.session != null) {
        debugPrint('LoginService - Sessão após login: ATIVA');
        debugPrint('LoginService - User: ${response.user!.email}');

        return LoginResult(success: true, message: 'Login bem-sucedido!');
      } else {
        return LoginResult(
          success: false,
          message: 'Email ou senha inválidos.',
        );
      }
    } catch (e) {
      debugPrint('LoginService - Erro: $e');
      return LoginResult(success: false, message: 'Email ou senha inválidos.');
    }
  }
}
