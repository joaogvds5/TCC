import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nearu/src/services/auth_service.dart';
import 'package:intl/intl.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
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

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  DateTime? _parseDate(String dateStr) {
    try {
      final formats = ['dd/MM/yyyy', 'dd/MM/yy'];
      for (final format in formats) {
        final date = DateFormat(format).tryParse(dateStr);
        if (date != null) return date;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _handleSignUp() async {
    if (nameController.text.trim().isEmpty) {
      _showError('Digite seu nome');
      return;
    }

    if (emailController.text.trim().isEmpty) {
      _showError('Digite seu e-mail');
      return;
    }

    if (!emailController.text.contains('@') ||
        !emailController.text.contains('.')) {
      _showError('Digite um e-mail válido');
      return;
    }

    if (passwordController.text.length < 6) {
      _showError('A senha deve ter pelo menos 6 caracteres');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showError('Senhas não conferem');
      return;
    }
    DateTime? birthDate;
    if (birthController.text.isNotEmpty) {
      birthDate = _parseDate(birthController.text);
      if (birthDate == null) {
        _showError('Data inválida. Use DD/MM/AAAA');
        return;
      }
    }
    setState(() => _isLoading = true);
    try {
      final authResponse = await AuthService.instance.signUpWithEmailPassword(
        emailController.text.trim(),
        passwordController.text,
      );

      if (authResponse.user == null) {
        if (!mounted) return;
        _showError('Erro ao criar conta. Tente novamente.');
        return;
      }
      final userId = authResponse.user!.id;

      final hasExtraData =
          nameController.text.trim().isNotEmpty ||
          phoneController.text.trim().isNotEmpty ||
          birthDate != null;

      if (hasExtraData) {
        final updateData = <String, dynamic>{
          'name': nameController.text.trim(),
        };

        if (phoneController.text.trim().isNotEmpty) {
          updateData['telephone'] = phoneController.text.trim();
        }

        if (birthDate != null) {
          updateData['birth_date'] = birthDate.toIso8601String();
        }

        await Supabase.instance.client
            .from('users')
            .update(updateData)
            .eq('user_id', userId);
      }
      if (!mounted) return;
      _showSuccess(
        'Conta criada com sucesso! Verifique seu e-mail para confirmar.',
      );
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) Navigator.pop(context);
      });
    } on AuthException catch (e) {
      if (!mounted) return;
      final isEmailInUse = _isEmailAlreadyRegistered(e);
      _showError(
        isEmailInUse
            ? 'Este e-mail já está cadastrado. Faça login ou recupere sua senha.'
            : 'Erro ao criar conta: ${e.message}',
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Erro inesperado: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isEmailAlreadyRegistered(AuthException e) {
    final msg = e.message.toLowerCase();
    return msg.contains('already registered') ||
        msg.contains('already exists') ||
        msg.contains('já está cadastrado') ||
        msg.contains('user already registered');
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Selecione a data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Selecionar',
    );

    if (date != null && mounted) {
      birthController.text = DateFormat('dd/MM/yyyy').format(date);
    }
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
                      "Criar conta",
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

                    // Campo de data com DatePicker
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: _inputField(
                          controller: birthController,
                          hint: "Data de nascimento (opcional)",
                          icon: Icons.cake,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    _inputField(
                      controller: phoneController,
                      hint: "Número de telefone (opcional)",
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 15),

                    _inputField(
                      controller: emailController,
                      hint: "E-mail",
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),

                    _inputField(
                      controller: passwordController,
                      hint: "Senha (mínimo 6 caracteres)",
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

  // componentes de ui
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
        color: primaryColor.withValues(alpha: 0.1),
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
    TextInputType keyboardType = TextInputType.text,
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
      keyboardType: keyboardType,
      textCapitalization: keyboardType == TextInputType.emailAddress
          ? TextCapitalization.none
          : TextCapitalization.words,
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _signupButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleSignUp,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: _isLoading
              ? primaryColor.withValues(alpha: 0.6)
              : primaryColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isLoading
              ? null
              : [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                "Cadastrar",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
      ),
    );
  }

  Widget _divider() {
    return const Row(
      children: [
        Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text("ou"),
        ),
        Expanded(child: Divider()),
      ],
    );
  }

  Widget _loginText() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Text.rich(
          TextSpan(
            text: "Já possui uma conta? ",
            style: TextStyle(color: Colors.grey.shade600),
            children: [
              TextSpan(
                text: "Entrar",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
