import 'package:flutter/material.dart';
import 'package:nearu/src/services/login_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final Color primaryColor = const Color(0xFF0A0A23);
  final Color backgroundColor = const Color(0xFFEDEBFF);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  const Text(
                    "Bem-vindo!",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const SizedBox(height: 40),

                  _inputField(
                    controller: emailController,
                    hint: "Digite seu e-mail",
                    icon: Icons.email,
                  ),

                  const SizedBox(height: 20),

                  _inputField(
                    controller: passwordController,
                    hint: "Digite sua senha",
                    icon: Icons.lock,
                    isPassword: true,
                  ),

                  const SizedBox(height: 25),

                  _loginButton(),

                  const SizedBox(height: 25),

                  _divider(),

                  const SizedBox(height: 20),

                  _socialButtons(),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _loginButton() {
    return GestureDetector(
      onTap: () async {
        if (emailController.text.isEmpty || passwordController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Preencha todos os campos')),
          );
          return;
        }

        final result = await LoginService().login(
          emailController.text,
          passwordController.text,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.message)));

        if (result.success) {
          Navigator.pop(context);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: const Text(
          "Entrar",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _divider() {
    return Row(
      children: const [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text("Não possui conta?"),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _socialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _socialButton("Google", Icons.g_mobiledata),
        const SizedBox(width: 10),

        _socialButton("GitHub", Icons.code),
      ],
    );
  }

  Widget _socialButton(String text, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon), const SizedBox(width: 8), Text(text)],
        ),
      ),
    );
  }
}
