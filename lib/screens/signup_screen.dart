import 'package:flutter/material.dart';
import 'package:karnet_deyn/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import 'otp_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  bool _isConfirmObscure = true;

  // Default role
  String _selectedRole = 'client'; // Values: 'client', 'boutiquier'

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() async {
    final language = Provider.of<LanguageProvider>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(language.getText('password_mismatch'))),
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        _nameController.text,
        _phoneController.text,
        _passwordController.text,
        _selectedRole,
        _emailController.text,
      );

      if (success && mounted) {
        // Rediriger vers l'écran de vérification OTP
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              phoneNumber: _phoneController.text,
            ),
          ),
        );
      } else if (mounted) {
        final error = authProvider.errorMessage;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error ?? 'Erreur inconnue')));
      }
    }
  }

  Widget _buildInput(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType type = TextInputType.text,
  }) {
    final language = Provider.of<LanguageProvider>(context);

    return FormField<String>(
      validator: (value) {
        if (controller.text.isEmpty) {
          return language.getText('required_field');
        }
        return null;
      },
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(50),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: state.hasError
                      ? Colors.red.shade300
                      : Colors.grey.shade300,
                  width: state.hasError ? 1.5 : 1.0,
                ),
              ),
              child: TextField(
                controller: controller,
                obscureText: isPassword ? obscureText : false,
                keyboardType: type,
                onChanged: (val) {
                  state.didChange(val);
                },
                decoration: InputDecoration(
                  hintText: hint,
                  prefixIcon: Icon(icon, color: Colors.black54),
                  suffixIcon: isPassword
                      ? IconButton(
                          icon: Icon(
                            obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.black54,
                          ),
                          onPressed: onToggleVisibility,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(left: 20.0, top: 5.0),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context);
    final isRtl = language.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      language.getText('signup_title'),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Name Input
                    _buildInput(
                      _nameController,
                      language.getText('full_name'),
                      Icons.person_outline,
                    ),
                    const SizedBox(height: 15),

                    // Phone Input
                    _buildInput(
                      _phoneController,
                      language.getText('phone_hint'),
                      Icons.payment,
                      type: TextInputType.phone,
                    ),
                    const SizedBox(height: 15),

                    _buildInput(
                      _emailController,
                      language.getText('email'),
                      Icons.email,
                      type: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),

                    // Password Input
                    _buildInput(
                      _passwordController,
                      language.getText('password_hint'),
                      Icons.lock_outline,
                      isPassword: true,
                      obscureText: _isObscure,
                      onToggleVisibility: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                    const SizedBox(height: 15),

                    // Confirm Password
                    _buildInput(
                      _confirmPasswordController,
                      language.getText('confirm_password'),
                      Icons.lock_outline,
                      isPassword: true,
                      obscureText: _isConfirmObscure,
                      onToggleVisibility: () {
                        setState(() {
                          _isConfirmObscure = !_isConfirmObscure;
                        });
                      },
                    ),
                    const SizedBox(height: 25),

                    // Role Selection
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        language.getText('i_am_a'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedRole = 'client'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'client'
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _selectedRole == 'client'
                                      ? const Color(0xFF4CAF50)
                                      : Colors.transparent,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  language.getText('client'),
                                  style: TextStyle(
                                    color: _selectedRole == 'client'
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedRole = 'boutiquier'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'boutiquier'
                                    ? const Color(0xFF4CAF50)
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _selectedRole == 'boutiquier'
                                      ? const Color(0xFF4CAF50)
                                      : Colors.transparent,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  language.getText('boutiquier'),
                                  style: TextStyle(
                                    color: _selectedRole == 'boutiquier'
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Sign Up Button
                    Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        return auth.isLoading
                            ? const CircularProgressIndicator()
                            : SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF66BB6A),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    language.getText('register_button'),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
