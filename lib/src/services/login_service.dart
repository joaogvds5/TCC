import 'package:nearu/src/services/auth_service.dart';

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
        return LoginResult(success: true, message: 'Login bem-sucedido!');
      } else {
        return LoginResult(
          success: false,
          message: 'Email ou senha inválidos.',
        );
      }
    } catch (e) {
      return LoginResult(
        success: false,
        message: 'Erro inesperado ao fazer login.',
      );
    }
  }
}
