import 'package:flutter/material.dart';
import 'package:nearu/src/screens/login_screen.dart';
import 'package:nearu/src/screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Verifica sessão atual ANTES do StreamBuilder
    final currentSession = Supabase.instance.client.auth.currentSession;
    debugPrint(
      '🔑 AuthGate BUILD - Sessão atual: ${currentSession != null ? "ATIVA" : "NULA"}',
    );
    debugPrint(
      '🔑 AuthGate BUILD - User: ${currentSession?.user.email ?? "nenhum"}',
    );

    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        debugPrint(
          '🔑 StreamBuilder - ConnectionState: ${snapshot.connectionState}',
        );
        debugPrint('🔑 StreamBuilder - HasData: ${snapshot.hasData}');
        debugPrint('🔑 StreamBuilder - HasError: ${snapshot.hasError}');

        if (snapshot.hasError) {
          debugPrint('🔑 StreamBuilder - Erro: ${snapshot.error}');
        }

        // Loading inicial
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Carregando..."),
                ],
              ),
            ),
          );
        }

        // Verifica sessão do snapshot E sessão atual (fallback)
        final session = snapshot.hasData ? snapshot.data!.session : null;
        final hasSession = session != null || currentSession != null;

        debugPrint(
          '🔑 AuthGate - Decisão: ${hasSession ? "MyHomePage" : "LoginPage"}',
        );

        if (hasSession) {
          return const MyHomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
