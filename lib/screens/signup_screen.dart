import 'package:flutter/material.dart';
import 'package:karnet_deyn/screens/login_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';


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
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Les mots de passe ne correspondent pas'),
          ),
        );
        return;
      }

      final success = await Provider.of<AuthProvider>(context, listen: false)
          .register(
            _nameController.text,
            _phoneController.text,
            _passwordController.text,
            _selectedRole,
            _emailController.text,
          );

      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Inscription réussie!')));

        if (_selectedRole == 'client' || _selectedRole == 'boutiquer') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        } else {
          Navigator.pop(
            context,
          ); // Go back to login for boutiquier or handle differently
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

  Widget _buildInput(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType type = TextInputType.text,
  }) {
    return FormField<String>(
      validator: (value) {
        if (controller.text.isEmpty) {
          return 'Ce champ est requis';
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
    return Scaffold(
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
                  const Text(
                    "Inscription",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Name Input
                  _buildInput(
                    _nameController,
                    "Nom complet",
                    Icons.person_outline,
                  ),
                  const SizedBox(height: 15),

                  // Phone Input
                  _buildInput(
                    _phoneController,
                    "Téléphone",
                    Icons.payment,
                    type: TextInputType.phone,
                  ), // User used 'credit card' icon in mockup for second field, likely for ID or Phone. Keeping phone logic but matching icon loosely or sticking to logic? Let's use logic: payment icon looks like the card in mockup.
                  const SizedBox(height: 15),

                   _buildInput(
                    _emailController,
                    "Email",
                    Icons.email,
                    type: TextInputType.phone,
                  ), // User used 'credit card' icon in mockup for second field, likely for ID or Phone. Keeping phone logic but matching icon loosely or sticking to logic? Let's use logic: payment icon looks like the card in mockup.
                  const SizedBox(height: 15),

                  // Password Input
                  _buildInput(
                    _passwordController,
                    "Mot de passe",
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
                    "Confirmer mot de passe",
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

                  // Role Selection (En bas, as requested)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Je suis un :",
                      style: TextStyle(
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
                          onTap: () => setState(() => _selectedRole = 'client'),
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
                                "Client",
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
                                "Boutiquier",
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
                                  backgroundColor: const Color(
                                    0xFF66BB6A,
                                  ), // Lighter green as per mockup
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      10,
                                    ), // Less rounded than login based on mockup
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  "S'INSCRIRE",
                                  style: TextStyle(
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
    );
  }
}
