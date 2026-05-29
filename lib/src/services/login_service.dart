import 'package:nearu/src/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class LoginResult {
  final bool success;
  final String message;

  LoginResult({required this.success, required this.message});
}

class LoginService {
  Future<LoginResult> login(String email, String password) async {
    try {
      final response = await AuthService.instance.signInWithEmailPassword(
        email,
        password,
      );

      if (response.user != null) {
        // ✅ Força refresh da sessão para garantir que o Stream emita
        await Supabase.instance.client.auth.refreshSession();

        debugPrint(
          '🔑 LoginService - Sessão após login: ${response.session != null ? "ATIVA" : "NULA"}',
        );

        return LoginResult(success: true, message: 'Login bem-sucedido!');
      } else {
        return LoginResult(
          success: false,
          message: 'Email ou senha inválidos.',
        );
      }
    } catch (e) {
      debugPrint('🔑 LoginService - Erro: $e');
      return LoginResult(
        success: false,
        message: 'Erro ao fazer login: ${e.toString()}',
      );
    }
  }
}
