// providers/auth_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _accessToken;
  String? _refreshToken;
  Map<String, dynamic>? _userProfile;
  String? _pendingPhoneNumber; // Stocker le numéro en attente de vérification OTP

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _accessToken != null;
  Map<String, dynamic>? get userProfile => _userProfile;
  String? get pendingPhoneNumber => _pendingPhoneNumber;

  String? get userRole {
    if (_userProfile != null && _userProfile!.containsKey('role')) {
      return _userProfile!['role'];
    }
    if (_userProfile != null &&
        _userProfile!['profile'] != null &&
        _userProfile!['profile'] is Map) {
      return _userProfile!['profile']['role'];
    }
    return null;
  }

  // static const String _baseUrl = 'http://10.0.2.2:8000'; // Pour Android emulator
  static const String _baseUrl = 'http://127.0.0.1:8000'; // Pour iOS ou test

  // Nouvelle méthode : Envoyer OTP pour inscription
  Future<bool> sendOTP(String phoneNumber, String username, String email, 
      String password, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone_number': phoneNumber,
          'username': username,
          'email': email,
          'password': password,
          'password2': password,
          'role': role,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _pendingPhoneNumber = data['phone_number'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        if (errorData.containsKey('error')) {
          _errorMessage = errorData['error'];
        } else {
          _errorMessage = errorData.toString();
        }
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'envoi OTP : $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Nouvelle méthode : Vérifier OTP et compléter l'inscription
  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/verify-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone_number': phoneNumber,
          'otp': otp,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _accessToken = data['access'];
        _refreshToken = data['refresh'];
        _pendingPhoneNumber = null;
        
        // Récupérer le profil utilisateur
        await getProfile();
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['error'] ?? 'OTP invalide ou expiré';
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la vérification OTP : $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Login existant (légèrement modifié)
  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/token/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access'];
        _refreshToken = data['refresh'];
        await getProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['detail'] ?? 
                       errorData['non_field_errors']?[0] ?? 
                       'Échec de la connexion.';
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion : $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Register method mis à jour pour utiliser OTP
  Future<bool> register(
    String name,
    String phone,
    String password,
    String role,
    String email,
  ) async {
    // Générer un username unique (peut être le phone ou name+phone)
    String username = phone; // ou name.replaceAll(' ', '_').toLowerCase();
    
    // Envoyer OTP d'abord
    return await sendOTP(phone, username, email, password, role);
  }

  // Le reste des méthodes reste identique...
  Future<void> getProfile() async {
    if (_accessToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/profile/'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _userProfile = json.decode(response.body);
        notifyListeners();
      } else if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (refreshed) {
          await getProfile();
        } else {
          logout();
        }
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  Future<bool> refreshToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access'];
        if (data.containsKey('refresh')) {
          _refreshToken = data['refresh'];
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }
    return false;
  }

  void logout() {
    _accessToken = null;
    _refreshToken = null;
    _userProfile = null;
    _pendingPhoneNumber = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}