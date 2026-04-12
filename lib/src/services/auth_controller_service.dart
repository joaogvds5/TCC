import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController {
  final SupabaseClient _client = Supabase.instance.client;

  bool get isLoggedIn => _client.auth.currentSession != null;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
