import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<AuthResponse> signInWithEmailPassword(
    dynamic email,
    dynamic password,
  ) async {
    return await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpWithEmailPassword(
    dynamic email,
    dynamic passowrd,
  ) async {
    return await _supabaseClient.auth.signUp(email: email, password: passowrd);
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  /*
  Future<void> googleSignIn() async {
    await _supabaseClient.auth.signInWithOAuth(
      Provider.google,
      options: AuthOptions(redirectTo: 'io.supabase.nearu://login-callback/'),
    );
  }

  Future<void> githubSignIn() async {
    await _supabaseClient.auth.signInWithOAuth(
      Provider.github,
      options: AuthOptions(redirectTo: 'io.supabase.nearu://login-callback/'),
    );
  }
*/

  Future<void> updateEmail(String newEmail) async {
    final session = _supabaseClient.auth.currentSession;
    if (session != null) {
      await _supabaseClient.auth.updateUser(UserAttributes(email: newEmail));
    }
  }

  Future<void> updatePassword(String newPassword) async {
    final session = _supabaseClient.auth.currentSession;
    if (session != null) {
      await _supabaseClient.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    }
  }

  Future<void> resetPassword(String email) async {
    await _supabaseClient.auth.resetPasswordForEmail(email);
  }

  String? getCurrentUserEmail() {
    final session = _supabaseClient.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  User? get currentUser => _supabaseClient.auth.currentUser;
}
