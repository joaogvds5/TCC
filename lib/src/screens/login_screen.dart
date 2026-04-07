import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  bool _isPasswordVisible = false;

  final Color _primaryColor = const Color.fromARGB(255, 5, 5, 12);
  final Color _darkTextColor = const Color.fromARGB(255, 0, 0, 0);
  final Color _bodyTextColor = const Color.fromARGB(255, 65, 61, 135);
  final Color _borderColor = const Color.fromARGB(255, 165, 163, 205);
  final Color _bgLight = const Color.fromARGB(255, 107, 103, 166);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: Stack(
        children: [
          _Backgrounddecoration(color: _primaryColor),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LoginHeader(darkColor: _darkTextColor, bodyColor: _bgLight),

                  const SizedBox(height: 40),

                  _LoginFormFields(
                    primaryColor: _primaryColor,
                    darkColor: _darkTextColor,
                    borderColor: _borderColor,
                    bodyColor: _bodyTextColor,
                    isPasswordVisible: _isPasswordVisible,
                    onTogglePassword: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),

                  const SizedBox(height: 30),

                  _LoginButton(primaryColor: _primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Backgrounddecoration extends StatelessWidget {
  final Color color;

  const _Backgrounddecoration({required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(top: -80, left: -60, child: _blob(280, color)),
        Positioned(bottom: -80, right: -60, child: _blob(230, color)),
      ],
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  final Color darkColor, bodyColor;

  const _LoginHeader({required this.darkColor, required this.bodyColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 70),

        Text(
          "Bem Vindo!",
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: darkColor,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          "Entre com suas credenciais",
          style: TextStyle(fontSize: 16, color: darkColor),
        ),
      ],
    );
  }
}

class _LoginFormFields extends StatelessWidget {
  final Color primaryColor, darkColor, bodyColor, borderColor;
  final bool isPasswordVisible;
  final VoidCallback onTogglePassword;

  const _LoginFormFields({
    required this.primaryColor,
    required this.darkColor,
    required this.borderColor,
    required this.bodyColor,
    required this.isPasswordVisible,
    required this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _inputField(Icons.email, "Digite seu e-mail"),

        const SizedBox(height: 20),

        _inputField(
          Icons.lock,
          "Digite sua senha",
          isPassword: true,
          suffix: GestureDetector(
            onTap: onTogglePassword,
            child: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            ),
          ),
        ),
      ],
    );
  }

  Widget _inputField(
    IconData icon,
    String hint, {
    bool isPassword = false,
    Widget? suffix,
  }) {
    return TextField(
      obscureText: isPassword && !isPasswordVisible,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  final Color primaryColor;

  const _LoginButton({required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        "Entrar",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
