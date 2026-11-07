import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestSignUpPage extends StatefulWidget {
  const TestSignUpPage({super.key});

  @override
  State<TestSignUpPage> createState() => _TestSignUpPageState();
}

class _TestSignUpPageState extends State<TestSignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  String? error;

  void _validate() {
    if (nameController.text.trim().isEmpty) {
      setState(() => error = 'Digite seu nome');
    } else if (!emailController.text.contains('@')) {
      setState(() => error = 'E-mail inválido');
    } else if (passwordController.text.length < 6) {
      setState(() => error = 'Senha curta');
    } else if (passwordController.text != confirmController.text) {
      setState(() => error = 'Senhas não conferem');
    } else {
      setState(() => error = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Nome'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(hintText: 'E-mail'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(hintText: 'Senha'),
            ),
            TextField(
              controller: confirmController,
              decoration: const InputDecoration(hintText: 'Confirmar'),
            ),
            ElevatedButton(
              onPressed: _validate,
              child: const Text('Cadastrar'),
            ),
            if (error != null) Text(error!),
          ],
        ),
      ),
    );
  }
}

void main() {
  group('SignUp Screen - Renderização', () {
    testWidgets('Renderiza 4 campos', (tester) async {
      await tester.pumpWidget(const TestSignUpPage());
      expect(find.byType(TextField), findsNWidgets(4));
    });
  });

  group('SignUp Screen - Validações', () {
    testWidgets('Erro com nome vazio', (tester) async {
      await tester.pumpWidget(const TestSignUpPage());
      await tester.tap(find.text('Cadastrar'));
      await tester.pump();
      expect(find.text('Digite seu nome'), findsOneWidget);
    });

    testWidgets('Erro com email inválido', (tester) async {
      await tester.pumpWidget(const TestSignUpPage());
      await tester.enterText(find.byType(TextField).at(0), 'João');
      await tester.enterText(find.byType(TextField).at(1), 'invalido');
      await tester.tap(find.text('Cadastrar'));
      await tester.pump();
      expect(find.text('E-mail inválido'), findsOneWidget);
    });

    testWidgets('Erro com senhas diferentes', (tester) async {
      await tester.pumpWidget(const TestSignUpPage());
      await tester.enterText(find.byType(TextField).at(0), 'João');
      await tester.enterText(find.byType(TextField).at(1), 'teste@email.com');
      await tester.enterText(find.byType(TextField).at(2), 'senha123');
      await tester.enterText(find.byType(TextField).at(3), 'senha456');
      await tester.tap(find.text('Cadastrar'));
      await tester.pump();
      expect(find.text('Senhas não conferem'), findsOneWidget);
    });

    testWidgets('Sem erro com dados válidos', (tester) async {
      await tester.pumpWidget(const TestSignUpPage());
      await tester.enterText(find.byType(TextField).at(0), 'João');
      await tester.enterText(find.byType(TextField).at(1), 'teste@email.com');
      await tester.enterText(find.byType(TextField).at(2), 'senha123');
      await tester.enterText(find.byType(TextField).at(3), 'senha123');
      await tester.tap(find.text('Cadastrar'));
      await tester.pump();
      expect(find.text('Senhas não conferem'), findsNothing);
    });
  });
}
