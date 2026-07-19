// screens/otp_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import 'login_screen.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  
  const OTPVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isVerifying = false;
  int _resendCooldown = 60;
  bool _canResend = false;
  
  // 🔥 Ajouter une référence au timer pour pouvoir l'annuler
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendCooldown = 60;
    _canResend = false;
    _updateTimer(); // Démarrer le timer
  }

  void _updateTimer() {
    // 🔥 Vérifier si le widget est toujours monté avant de continuer
    if (!mounted || _isDisposed) return;
    
    if (_resendCooldown > 0) {
      setState(() {
        _resendCooldown--;
      });
      // Utiliser Timer au lieu de Future.delayed pour pouvoir l'annuler
      Future.delayed(const Duration(seconds: 1), _updateTimer);
    } else {
      if (mounted && !_isDisposed) {
        setState(() {
          _canResend = true;
        });
      }
    }
  }

  String get _otpCode {
    return _otpControllers.map((c) => c.text).join();
  }

  Future<void> _verifyOTP() async {
    if (_otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer le code à 6 chiffres')),
      );
      return;
    }

    // 🔥 Vérifier si le widget est toujours monté
    if (!mounted || _isDisposed) return;

    setState(() {
      _isVerifying = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyOTP(widget.phoneNumber, _otpCode);

    // 🔥 Vérifier à nouveau après l'async
    if (!mounted || _isDisposed) return;

    if (success) {
      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inscription réussie! Veuillez vous connecter.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // 🔥 Marquer comme disposé avant la navigation
      _isDisposed = true;
      
      // Rediriger vers la page de login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
      
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Code invalide'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      
      // Réinitialiser les champs OTP en cas d'erreur
      for (var controller in _otpControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
      
      setState(() {
        _isVerifying = false;
      });
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend || _isDisposed) return;

    setState(() {
      _isVerifying = true;
    });

    // Réinitialiser les champs OTP
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.resendOTP(widget.phoneNumber);

    if (!mounted || _isDisposed) return;

    if (success) {
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nouveau code envoyé!'),
          backgroundColor: Colors.blue,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Échec du renvoi du code'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted && !_isDisposed) {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  @override
  void dispose() {
    // 🔥 Marquer comme disposé et annuler tout
    _isDisposed = true;
    
    // Libérer les ressources
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
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
            onPressed: () {
              _showExitConfirmationDialog();
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Icon(
                    Icons.sms_failed_outlined,
                    size: 80,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Vérification OTP',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Un code a été envoyé au ${widget.phoneNumber}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Champs OTP
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                  children: List.generate(6, (index) {
                    final reversedIndex = isRtl ? 5 - index : index;
                    return _buildOTPTextField(reversedIndex);
                  }),
                ),
                
                const SizedBox(height: 40),
                
                // Bouton de vérification
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_isVerifying || _isDisposed) ? null : _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                      disabledBackgroundColor: Colors.grey.shade400,
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Vérifier',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Renvoyer le code
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _canResend 
                        ? (language.getText('resend_code_prompt') ?? 'Vous n\'avez pas reçu le code ? ')
                        : 'Renvoyer dans $_resendCooldown s',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    if (_canResend && !_isDisposed)
                      TextButton(
                        onPressed: _resendOTP,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF4CAF50),
                        ),
                        child: Text(
                          language.getText('resend') ?? 'Renvoyer',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                if (_isVerifying)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'Vérification en cours...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOTPTextField(int index) {
    return SizedBox(
      width: 50,
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        obscureText: false,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.green.shade700, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
        ),
        onChanged: (value) {
          if (_isDisposed) return;
          
          final language = Provider.of<LanguageProvider>(context, listen: false);
          final isRtl = language.locale.languageCode == 'ar';
          
          if (value.isNotEmpty) {
            if (isRtl) {
              if (index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
            } else {
              if (index < 5) {
                _focusNodes[index + 1].requestFocus();
              }
            }
          } else if (value.isEmpty) {
            if (isRtl) {
              if (index < 5) {
                _focusNodes[index + 1].requestFocus();
              }
            } else {
              if (index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
            }
          }
          
          if (_otpCode.length == 6 && !_isVerifying && !_isDisposed) {
            _verifyOTP();
          }
        },
      ),
    );
  }

  void _showExitConfirmationDialog() {
    if (_isDisposed) return;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Annuler l\'inscription'),
          content: const Text('Voulez-vous vraiment annuler et revenir à la page de connexion ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _isDisposed = true;
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Oui'),
            ),
          ],
        );
      },
    );
  }
}