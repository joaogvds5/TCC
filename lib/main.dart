import 'package:flutter/material.dart';
import 'package:nearu/src/services/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  // ✅ VERIFICA SE JÁ EXISTE SESSÃO AO INICIAR
  final currentSession = Supabase.instance.client.auth.currentSession;
  debugPrint(
    '🔑 MAIN - Sessão inicial: ${currentSession != null ? "ATIVA" : "NULA"}',
  );
  debugPrint('🔑 MAIN - User: ${currentSession?.user.email ?? "nenhum"}');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NearU',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A0A23)),
      ),
      home: const AuthGate(),
    );
  }
}
