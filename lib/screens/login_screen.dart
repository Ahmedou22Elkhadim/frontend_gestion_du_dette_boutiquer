import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import 'signup_screen.dart';
import 'client_dashboard_screen.dart';
import 'boutiquer_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).login(_phoneController.text, _passwordController.text);

      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Connexion réussie!')));

        // Navigate to dashboard based on role? For now assume client as requested
        final role = Provider.of<AuthProvider>(context, listen: false).userRole;

        if (role == 'boutiquier' || role == 'boutiquer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const BoutiquerDashboardScreen(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ClientDashboardScreen(),
            ),
          );
        }
      } else if (mounted) {
        final error = Provider.of<AuthProvider>(
          context,
          listen: false,
        ).errorMessage;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error ?? 'Erreur inconnue')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context);
    final isRtl = language.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Placeholder for a logo or image if needed
                    // const SizedBox(height: 50),

                    // Phone Input
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
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: language.getText(
                            'phone_hint',
                          ), // Localized hint
                          prefixIcon: const Icon(
                            Icons.phone_outlined,
                            color: Colors.black54,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return language.getText('enter_phone');
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password Input
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
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          hintText: language.getText(
                            'password_hint',
                          ), // Localized
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.black54,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return language.getText('enter_password');
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Login Button
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
                                    backgroundColor: const Color(
                                      0xFF4CAF50,
                                    ), // Green color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Text(
                                    language.getText('login'),
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

                    // Forgot Password
                    TextButton(
                      onPressed: () {
                        // Handle forgot password
                      },
                      child: Text(
                        language.getText('forgot_password'),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    // Sign Up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${language.getText('new_user')} ',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
                          },
                          child: Text(
                            language.getText('register_now'),
                            style: const TextStyle(
                              color: Color(
                                0xFF8D6E63,
                              ), // Brownish color from image
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Language Toggle
                    IconButton(
                      icon: const Icon(Icons.language, color: Colors.black54),
                      onPressed: () {
                        language.toggleLanguage();
                      },
                    ),
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
