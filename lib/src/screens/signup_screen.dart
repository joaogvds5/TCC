import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController birthController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final Color primaryColor = const Color(0xFF0A0A23);
  final Color backgroundColor = const Color(0xFFEDEBFF);

  @override
  void dispose() {
    nameController.dispose();
    birthController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          _backgroundDecoration(),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    const Text(
                      "Criar conta ✨",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "Preencha os dados abaixo",
                      style: TextStyle(fontSize: 16),
                    ),

                    const SizedBox(height: 30),

                    _inputField(
                      controller: nameController,
                      hint: "Nome completo",
                      icon: Icons.person,
                    ),

                    const SizedBox(height: 15),

                    _inputField(
                      controller: birthController,
                      hint: "Data de nascimento (DD/MM/AAAA)",
                      icon: Icons.cake,
                    ),

                    const SizedBox(height: 15),

                    _inputField(
                      controller: phoneController,
                      hint: "Número de telefone",
                      icon: Icons.phone,
                    ),

                    const SizedBox(height: 15),

                    _inputField(
                      controller: emailController,
                      hint: "E-mail",
                      icon: Icons.email,
                    ),

                    const SizedBox(height: 15),

                    _inputField(
                      controller: passwordController,
                      hint: "Senha",
                      icon: Icons.lock,
                      isPassword: true,
                    ),

                    const SizedBox(height: 15),

                    _inputField(
                      controller: confirmPasswordController,
                      hint: "Confirmar senha",
                      icon: Icons.lock_outline,
                      isConfirmPassword: true,
                    ),

                    const SizedBox(height: 25),

                    _signupButton(),

                    const SizedBox(height: 25),

                    _divider(),

                    const SizedBox(height: 20),

                    _socialButtons(),

                    const SizedBox(height: 30),

                    _loginText(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _backgroundDecoration() {
    return Stack(
      children: [
        Positioned(top: -80, left: -60, child: _blob(250)),
        Positioned(bottom: -80, right: -60, child: _blob(200)),
      ],
    );
  }

  Widget _blob(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isConfirmPassword = false,
  }) {
    bool obscure = false;
    IconData? suffixIcon;
    VoidCallback? onTap;

    if (isPassword) {
      obscure = !_isPasswordVisible;
      suffixIcon = _isPasswordVisible ? Icons.visibility : Icons.visibility_off;
      onTap = () {
        setState(() {
          _isPasswordVisible = !_isPasswordVisible;
        });
      };
    }

    if (isConfirmPassword) {
      obscure = !_isConfirmPasswordVisible;
      suffixIcon = _isConfirmPasswordVisible
          ? Icons.visibility
          : Icons.visibility_off;
      onTap = () {
        setState(() {
          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
        });
      };
    }

    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon != null
            ? IconButton(icon: Icon(suffixIcon), onPressed: onTap)
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

  Widget _signupButton() {
    return GestureDetector(
      onTap: () {
        // lógica futura
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
          "Cadastrar",
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
          child: Text("ou"),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _socialButtons() {
    return Row(
      children: [
        _socialButton("Google", Icons.g_mobiledata),
        const SizedBox(width: 10),
        _socialButton("Facebook", Icons.facebook),
      ],
    );
  }

  Widget _socialButton(String text, IconData icon) {
    return Expanded(
      child: Container(
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

  Widget _loginText() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context); // volta pro login
        },
        child: const Text.rich(
          TextSpan(
            text: "Já possui uma conta? ",
            children: [
              TextSpan(
                text: "Entrar",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
