// test/unit/services/login_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:nearu/src/services/login_service.dart';
import 'package:nearu/src/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAuthService implements AuthService {
  AuthResponse? responseToReturn;
  Exception? exceptionToThrow;
  bool signInWasCalled = false;

  @override
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    signInWasCalled = true;
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return responseToReturn!;
  }

  @override
  Future<AuthResponse> signUpWithEmailPassword(String e, String p) =>
      throw UnimplementedError();

  @override
  Future<void> signOut() => throw UnimplementedError();

  @override
  Future<void> updateEmail(String e) => throw UnimplementedError();

  @override
  Future<void> updatePassword(String p) => throw UnimplementedError();

  @override
  Future<void> resetPassword(String e) => throw UnimplementedError();

  @override
  String? getCurrentUserEmail() => null;

  @override
  String? getCurrentUserId() => null;

  @override
  bool get isLoggedIn => false;

  @override
  User? get currentUser => null;
}

AuthResponse _mockAuthResponseSuccess() {
  return AuthResponse.fromJson({
    'access_token': 'fake-access-token',
    'token_type': 'bearer',
    'expires_in': 3600,
    'refresh_token': 'fake-refresh-token',
    'user': {
      'id': 'fake-user-id',
      'aud': 'authenticated',
      'email': 'teste@email.com',
      'created_at': '2024-01-01T00:00:00Z',
      'app_metadata': <String, dynamic>{},
      'user_metadata': <String, dynamic>{},
    },
  });
}

AuthResponse _mockAuthResponseFailure() => AuthResponse();

void main() {
  late MockAuthService mockAuth;
  late LoginService loginService;

  setUp(() {
    mockAuth = MockAuthService();
    loginService = LoginService(authService: mockAuth);
  });

  group('LoginService - E-mail', () {
    test('Retorna mensagem de erro caso e-mail nulo', () async {
      mockAuth.exceptionToThrow = Exception('Email nulo');

      final result = await loginService.login('', 'senha123');

      expect(result.success, isFalse);
      expect(result.message, contains('inválidos'));
    });

    test('Retorna mensagem de erro caso e-mail inválido', () async {
      mockAuth.exceptionToThrow = Exception('Email inválido');

      final result = await loginService.login('emailsemarroba', 'senha123');

      expect(result.success, isFalse);
      expect(result.message, contains('inválidos'));
    });
  });

  group('LoginService - Senha', () {
    test('Retorna mensagem de erro caso senha nula', () async {
      mockAuth.exceptionToThrow = Exception('Senha nula');

      final result = await loginService.login('teste@email.com', '');

      expect(result.success, isFalse);
      expect(result.message, contains('inválidos'));
    });

    test('Retorna mensagem de erro caso senha curta', () async {
      mockAuth.exceptionToThrow = Exception('Senha curta');

      final result = await loginService.login('teste@email.com', '123');

      expect(result.success, isFalse);
      expect(result.message, contains('inválidos'));
    });
  });

  group('LoginService - Sucesso', () {
    test('Retorna sucesso com credenciais válidas', () async {
      mockAuth.responseToReturn = _mockAuthResponseSuccess();

      final result = await loginService.login('teste@email.com', 'senha123');

      expect(result.success, isTrue);
      expect(result.message, equals('Login bem-sucedido!'));
    });

    test('Chama AuthService com os parâmetros corretos', () async {
      mockAuth.responseToReturn = _mockAuthResponseSuccess();

      await loginService.login('teste@email.com', 'senha123');

      expect(mockAuth.signInWasCalled, isTrue);
    });
  });

  group('LoginService - Falha', () {
    test('Retorna falha quando user é nulo', () async {
      mockAuth.responseToReturn = _mockAuthResponseFailure();

      final result = await loginService.login('teste@email.com', 'senha123');

      expect(result.success, isFalse);
      expect(result.message, contains('inválidos'));
    });

    test('Retorna falha quando session é nula', () async {
      mockAuth.responseToReturn = _mockAuthResponseFailure();

      final result = await loginService.login('teste@email.com', 'senha123');

      expect(result.success, isFalse);
    });

    test('Retorna falha quando AuthService lança exceção', () async {
      mockAuth.exceptionToThrow = Exception('Erro de rede');

      final result = await loginService.login('teste@email.com', 'senha123');

      expect(result.success, isFalse);
      expect(result.message, contains('inválidos'));
    });
  });
}
