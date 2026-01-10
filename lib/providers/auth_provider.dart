import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _accessToken;
  String? _refreshToken;
  Map<String, dynamic>? _userProfile;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _accessToken != null;
  Map<String, dynamic>? get userProfile => _userProfile;

  String? get userRole {
    if (_userProfile != null && _userProfile!.containsKey('role')) {
      return _userProfile!['role'];
    }
    // Handle nested profile if applicable
    if (_userProfile != null &&
        _userProfile!['profile'] != null &&
        _userProfile!['profile'] is Map) {
      return _userProfile!['profile']['role'];
    }
    return null;
  }

  // Replace with your actual API endpoint (10.0.2.2 for Android emulator -> localhost)
  static const String _baseUrl = 'http://127.0.0.1:8000';

  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/token/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username':
              phone, // SimpleJWT usually expects 'username' key even for custom user models
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access'];
        _refreshToken = data['refresh'];

        await getProfile(); // Fetch profile after login

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['detail'] ?? 'Échec de la connexion.';
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion : $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(
    String name,
    String phone,
    String password,
    String role,
    String email,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/register/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username':
              phone, // Use phone as username to ensure no spaces and uniqueness
          'phone_number': phone,
          'password': password,
          'password2': password, // Often required by registration serializers
          'email': email,
          'first_name': name,
          'role': role,
          // Adapt fields according to your Django User/Profile model
        }),
      );

      if (response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        // Handle common Django error formats (list of errors per field)
        _errorMessage = errorData.toString();
        if (errorData is Map) {
          if (errorData.containsKey('phone_number')) {
            _errorMessage = 'Ce numéro est déjà utilisé.';
          } else if (errorData.containsKey('password')) {
            _errorMessage = 'Mot de passe invalide.';
          }
        }
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'inscription : $e';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

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
        // Token might be expired, try refresh
        final refreshed = await refreshToken();
        if (refreshed) {
          await getProfile(); // Retry
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
        // Refresh token might be rotated or same, update if present
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
    notifyListeners();
  }
}
