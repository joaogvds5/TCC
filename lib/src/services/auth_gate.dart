// lib/src/screens/auth_gate.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nearu/src/screens/login_screen.dart';
import 'package:nearu/src/screens/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _hasSession = false;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    _checkCurrentSession();

    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (authState) {
        debugPrint('onAuthStateChange - Evento: ${authState.event}');
        debugPrint(
          'onAuthStateChange - Sessão: ${authState.session != null ? "ATIVA" : "NULA"}',
        );

        if (mounted) {
          setState(() {
            _hasSession = authState.session != null;
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        debugPrint('onAuthStateChange - Erro: $error');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      },
    );

    await Future.delayed(const Duration(milliseconds: 200));

    _checkCurrentSession();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _checkCurrentSession() {
    final session = Supabase.instance.client.auth.currentSession;
    debugPrint(
      '_checkCurrentSession - Sessão: ${session != null ? "ATIVA" : "NULA"}',
    );

    if (session != null) {
      _hasSession = true;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'AuthGate BUILD - isLoading: $_isLoading, hasSession: $_hasSession',
    );

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Verificando sessão..."),
            ],
          ),
        ),
      );
    }

    final currentSession = Supabase.instance.client.auth.currentSession;
    final showHome = _hasSession || currentSession != null;

    debugPrint(
      'AuthGate - Decisão final: ${showHome ? "HomePage" : "LoginPage"}',
    );

    if (showHome) {
      return const MyHomePage();
    } else {
      return const LoginPage();
    }
  }
}
