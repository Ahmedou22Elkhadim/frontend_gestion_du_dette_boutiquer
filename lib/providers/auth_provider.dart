// providers/auth_provider.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _accessToken;
  String? _refreshToken;
  Map<String, dynamic>? _userProfile;
  String? _pendingPhoneNumber;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _accessToken != null;
  Map<String, dynamic>? get userProfile => _userProfile;
  String? get pendingPhoneNumber => _pendingPhoneNumber;

  String? get userRole {
    if (_userProfile != null && _userProfile!.containsKey('role')) {
      return _userProfile!['role'];
    }
    return null;
  }

    // 🔥 AJOUTEZ CE GETTER
  Map<String, String> get _authHeaders {
    return {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
    };
  }

  /// Exécute une requête HTTP authentifiée et rafraîchit automatiquement le
  /// token d'accès (une seule fois) si le serveur répond 401, avant de
  /// réessayer la même requête. Centralise ce qui était géré au cas par cas
  /// (ou pas du tout) dans chaque méthode d'appel API.
  Future<http.Response> _authorizedRequest(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool isRetry = false,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = _authHeaders;
    final encodedBody = body != null ? json.encode(body) : null;

    http.Response response;
    switch (method) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(uri, headers: headers, body: encodedBody);
        break;
      case 'PATCH':
        response = await http.patch(uri, headers: headers, body: encodedBody);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        throw ArgumentError('Méthode HTTP non supportée: $method');
    }

    if (response.statusCode == 401 && !isRetry && _refreshToken != null) {
      final refreshed = await refreshToken();
      if (refreshed) {
        return _authorizedRequest(method, path, body: body, isRetry: true);
      }
      logout();
    }

    return response;
  }

  // 🔥 URL du backend Django, adaptée automatiquement à la plateforme.
  // - Android emulator ne peut pas joindre localhost de la machine hôte
  //   directement : il faut passer par l'alias spécial 10.0.2.2.
  // - iOS simulator, desktop et web utilisent le vrai localhost.
  // À terme (déploiement réel), remplacer par l'URL du serveur de production.
  static String get _baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://127.0.0.1:8000';
  }

  // ==================== AUTHENTIFICATION ====================
  
  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/token/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': phone, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access'];
        _refreshToken = data['refresh'];
        await _saveTokens();
        await getProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = _parseError(response);
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur de connexion: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

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
          'password2': password, // ✅ AJOUTER
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
        _errorMessage = errorData['error'] ?? errorData.toString();
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'envoi OTP : $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOTP(String phoneNumber, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/verify-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone_number': phoneNumber, 'otp': otp}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        _accessToken = data['access'];
        _refreshToken = data['refresh'];
        _pendingPhoneNumber = null;
        await _saveTokens();
        await getProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['error'] ?? 'OTP invalide ou expiré';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la vérification OTP : $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendOTP(String phoneNumber) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/resend-otp/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phone_number': phoneNumber}),
      );

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['error'] ?? 'Erreur lors du renvoi du code';
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erreur lors du renvoi du code : $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String phone, String password, String role, String email) async {
    String username = phone;
    return await sendOTP(phone, username, email, password, role);
  }

  Future<void> getProfile() async {
    if (_accessToken == null) return;

    try {
      final response = await _authorizedRequest('GET', '/api/profile/');

      if (response.statusCode == 200) {
        _userProfile = json.decode(response.body);
        notifyListeners();
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
        await _saveTokens();
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }
    return false;
  }

  void logout() async {
    _accessToken = null;
    _refreshToken = null;
    _userProfile = null;
    _pendingPhoneNumber = null;
    await _clearTokens();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ==================== CLIENTS (Boutiquier) ====================
  
  Future<List<dynamic>> getClients() async {
    if (_accessToken == null) return [];

    try {
      final response = await _authorizedRequest('GET', '/api/clients/list/');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('Error getting clients: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getClientDetail(int clientId) async {
    if (_accessToken == null) return null;

    try {
      final response = await _authorizedRequest('GET', '/api/clients/$clientId/retrieve/');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting client detail: $e');
      return null;
    }
  }

  // ==================== DETTES (Boutiquier) ====================
  
  Future<List<dynamic>> getDettes({int? clientId}) async {
    if (_accessToken == null) return [];

    try {
      String path = '/api/dettes/';
      if (clientId != null) {
        path += '?client_id=$clientId';
      }

      final response = await _authorizedRequest('GET', path);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('Error getting dettes: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> createDette({
    required int clientId,
    required String description,
    required double montant,
    String produit = '',
    int quantite = 1,
    String? dateEcheance,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authorizedRequest(
        'POST',
        '/api/dettes/create/',
        body: {
          'client': clientId,
          'description': description,
          'montant': montant,
          'produit': produit,
          'quantite': quantite,
          'date_echeance': dateEcheance,
        },
      );

      _isLoading = false;
      notifyListeners();

      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error creating dette: $e');
      return null;
    }
  }

  Future<bool> updateDette(int detteId, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authorizedRequest(
        'PATCH',
        '/api/dettes/$detteId/update/',
        body: data,
      );

      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error updating dette: $e');
      return false;
    }
  }

  Future<bool> deleteDette(int detteId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authorizedRequest('DELETE', '/api/dettes/$detteId/delete/');

      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error deleting dette: $e');
      return false;
    }
  }

  Future<bool> marquerDettePayee(int detteId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authorizedRequest('POST', '/api/dettes/$detteId/marquer-payee/');

      _isLoading = false;
      notifyListeners();
      return response.statusCode == 200;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error marking dette as paid: $e');
      return false;
    }
  }

  // ==================== VUES CLIENT ====================
  
  Future<Map<String, dynamic>?> getClientTotalDette() async {
    if (_accessToken == null) return null;

    try {
      final response = await _authorizedRequest('GET', '/api/client/total-dette/');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting total dette: $e');
      return null;
    }
  }

  Future<List<dynamic>> getClientBoutiques() async {
    if (_accessToken == null) return [];

    try {
      final response = await _authorizedRequest('GET', '/api/client/boutiques/');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['boutiques'] ?? [];
      }
      return [];
    } catch (e) {
      print('Error getting boutiques: $e');
      return [];
    }
  }

  // ==================== DEMANDES ====================
  
  // providers/auth_provider.dart - Améliorez la méthode envoyerDemandeAjout
// providers/auth_provider.dart
// providers/auth_provider.dart - Version finale corrigée
Future<bool> envoyerDemandeAjout(String clientPhone, {String adresse = '', String message = ''}) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    print('=== ENVOI DEMANDE AJOUT ===');
    print('URL: $_baseUrl/api/demandes/ajout/');
    print('Client Phone: $clientPhone');

    final response = await _authorizedRequest(
      'POST',
      '/api/demandes/ajout/',
      body: {
        'telephone': clientPhone,
        'adresse': adresse,
        'message': message,
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    _isLoading = false;
    notifyListeners();

    // 🔥 Accepter tous les codes 2xx comme succès
    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('✅ Demande envoyée avec succès');
      
      // Vérifier si la réponse contient une erreur cachée
      try {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('success') && data['success'] == false) {
          // La réponse dit qu'il y a une erreur
          _errorMessage = data['message'] ?? data['error'] ?? 'Erreur inconnue';
          print('❌ Erreur cachée: $_errorMessage');
          return false;
        }
        if (data is Map && data.containsKey('error')) {
          _errorMessage = data['error'];
          print('❌ Erreur: $_errorMessage');
          return false;
        }
      } catch (e) {
        // Si le parsing échoue, on considère que c'est un succès
        print('⚠️ Parsing ignoré: $e');
      }
      
      _errorMessage = null;
      return true;
    } else {
      // Gérer les erreurs HTTP
      String errorMessage = _parseErrorResponse(response.body);
      _errorMessage = errorMessage;
      print('❌ Erreur HTTP ${response.statusCode}: $_errorMessage');
      return false;
    }
  } catch (e) {
    print('❌ Exception: $e');
    _isLoading = false;
    notifyListeners();
    _errorMessage = 'Erreur de connexion: $e';
    return false;
  }
}

// 🔥 Méthode helper pour parser les erreurs
String _parseErrorResponse(String responseBody) {
  try {
    final decoded = json.decode(responseBody);
    
    if (decoded is Map) {
      // Vérifier les champs d'erreur possibles
      if (decoded.containsKey('error')) {
        final error = decoded['error'];
        if (error is List) return error.isNotEmpty ? error[0].toString() : 'Erreur';
        return error.toString();
      }
      if (decoded.containsKey('detail')) {
        return decoded['detail'].toString();
      }
      if (decoded.containsKey('message')) {
        return decoded['message'].toString();
      }
      if (decoded.containsKey('errors')) {
        final errors = decoded['errors'];
        if (errors is Map) {
          for (var key in errors.keys) {
            final value = errors[key];
            if (value is List && value.isNotEmpty) {
              return value[0].toString();
            }
          }
        }
      }
      if (decoded.containsKey('telephone')) {
        final err = decoded['telephone'];
        if (err is List) return err.isNotEmpty ? err[0].toString() : err.toString();
        return err.toString();
      }
      return decoded.toString();
    }
    
    if (decoded is List && decoded.isNotEmpty) {
      return decoded[0].toString();
    }
    
    return responseBody;
  } catch (e) {
    return responseBody;
  }
}
// ==================== DEMANDES ====================
// Ajoutez cette méthode après envoyerDemandeAjout

Future<bool> envoyerDemandeSuppression(int clientId) async {
  _isLoading = true;
  notifyListeners();

  try {
    print('=== ENVOI DEMANDE SUPPRESSION ===');
    print('URL: $_baseUrl/api/demandes/suppression/');
    print('Client ID: $clientId');

    final response = await _authorizedRequest(
      'POST',
      '/api/demandes/suppression/',
      body: {'client_id': clientId},
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    _isLoading = false;
    notifyListeners();

    if (response.statusCode == 201) {
      print('✅ Demande de suppression envoyée avec succès');
      return true;
    } else {
      String errorMessage = '';
      
      try {
        final responseData = json.decode(response.body);
        
        if (responseData is List) {
          errorMessage = responseData.isNotEmpty ? responseData[0] : 'Erreur inconnue';
        } else if (responseData is Map) {
          if (responseData.containsKey('error')) {
            errorMessage = responseData['error'];
          } else if (responseData.containsKey('detail')) {
            errorMessage = responseData['detail'];
          } else {
            errorMessage = responseData.toString();
          }
        } else {
          errorMessage = response.body;
        }
      } catch (e) {
        errorMessage = response.body;
      }
      
      _errorMessage = errorMessage;
      print('❌ Erreur: $_errorMessage');
      return false;
    }
  } catch (e) {
    print('❌ Exception: $e');
    _isLoading = false;
    notifyListeners();
    _errorMessage = 'Erreur de connexion: $e';
    return false;
  }
}

// Ajoutez aussi cette méthode pour que le client puisse voir ses demandes
Future<List<dynamic>> getClientDemandes() async {
  if (_accessToken == null) return [];

  try {
    final response = await _authorizedRequest('GET', '/api/demandes/client/');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  } catch (e) {
    print('Error getting client demandes: $e');
    return [];
  }
}

// 🔥 NOUVEAU : Récupérer l'historique complet des demandes (acceptées, refusées, en attente)
Future<List<dynamic>> getClientDemandesHistorique() async {
  if (_accessToken == null) return [];

  try {
    final response = await _authorizedRequest('GET', '/api/demandes/client/historique/');

    print('📋 getClientDemandesHistorique - Status: ${response.statusCode}');
    print('📋 getClientDemandesHistorique - Body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  } catch (e) {
    print('Error getting client demandes historique: $e');
    return [];
  }
}
// Ajoutez cette méthode pour répondre aux demandes (accepter/refuser)
Future<bool> repondreDemande(int demandeId, bool accepter) async {
  _isLoading = true;
  notifyListeners();

  try {
    final String path = accepter
        ? '/api/demandes/$demandeId/accepter/'
        : '/api/demandes/$demandeId/refuser/';

    print('=== RÉPONSE DEMANDE ===');
    print('URL: $_baseUrl$path');
    print('Demande ID: $demandeId');
    print('Accepter: $accepter');

    final response = await _authorizedRequest('POST', path);

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    _isLoading = false;
    notifyListeners();
    
    if (response.statusCode == 200) {
      print('✅ Demande ${accepter ? 'acceptée' : 'refusée'} avec succès');
      return true;
    } else {
      String errorMessage = '';
      try {
        final errorData = json.decode(response.body);
        errorMessage = errorData['error'] ?? errorData['detail'] ?? 'Erreur lors du traitement';
      } catch (e) {
        errorMessage = response.body;
      }
      _errorMessage = errorMessage;
      return false;
    }
  } catch (e) {
    print('❌ Exception: $e');
    _isLoading = false;
    notifyListeners();
    _errorMessage = 'Erreur de connexion: $e';
    return false;
  }
}

// providers/auth_provider.dart
// providers/auth_provider.dart - Méthode getDemandesBoutiquier améliorée
Future<List<dynamic>> getDemandesBoutiquier() async {
  if (_accessToken == null) return [];

  try {
    final response = await _authorizedRequest('GET', '/api/demandes/boutiquier/');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      // Le rafraîchissement automatique (voir _authorizedRequest) a aussi échoué.
      throw Exception('Session expirée. Veuillez vous reconnecter.');
    } else {
      // Erreur serveur
      try {
        final errorData = json.decode(response.body);
        if (errorData is Map && errorData.containsKey('detail')) {
          throw Exception(errorData['detail']);
        } else if (errorData is List && errorData.isNotEmpty) {
          throw Exception(errorData[0]);
        } else {
          throw Exception('Erreur ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Erreur de communication avec le serveur');
      }
    }
  } catch (e) {
    print('Error getting demandes boutiquier: $e');
    rethrow;
  }
}
  // ==================== NOTIFICATIONS ====================
  
// providers/auth_provider.dart - Ajoutez ces méthodes

// Récupérer toutes les notifications du boutiquier
Future<List<dynamic>> getNotifications() async {
  if (_accessToken == null) return [];

  try {
    final response = await _authorizedRequest('GET', '/api/notifications/');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return [];
  } catch (e) {
    print('Error getting notifications: $e');
    return [];
  }
}

// Compter les notifications non lues
Future<int> getNotificationsNonLues() async {
  if (_accessToken == null) return 0;

  try {
    final response = await _authorizedRequest('GET', '/api/notifications/non-lues/');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['non_lues'] ?? 0;
    }
    return 0;
  } catch (e) {
    print('Error getting unread count: $e');
    return 0;
  }
}

// Marquer une notification comme lue
Future<bool> marquerNotificationLue(int notificationId) async {
  try {
    final response = await _authorizedRequest('POST', '/api/notifications/$notificationId/lire/');
    return response.statusCode == 200;
  } catch (e) {
    print('Error marking notification as read: $e');
    return false;
  }
}

// Marquer toutes les notifications comme lues
Future<bool> marquerToutesNotificationsLues() async {
  try {
    final response = await _authorizedRequest('POST', '/api/notifications/lire-toutes/');
    return response.statusCode == 200;
  } catch (e) {
    print('Error marking all as read: $e');
    return false;
  }
}

  // ==================== PRIVÉS ====================
  
  String _parseError(http.Response response) {
    try {
      final error = json.decode(response.body);
      if (error is Map) {
        if (error.containsKey('error')) return error['error'];
        if (error.containsKey('detail')) return error['detail'];
        if (error.containsKey('message')) return error['message'];
        return error.toString();
      }
      return 'Erreur ${response.statusCode}';
    } catch (e) {
      return 'Erreur de communication';
    }
  }

  Future<void> _saveTokens() async {
    final prefs = await SharedPreferences.getInstance();
    if (_accessToken != null) {
      await prefs.setString('access_token', _accessToken!);
    }
    if (_refreshToken != null) {
      await prefs.setString('refresh_token', _refreshToken!);
    }
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  Future<void> loadSavedTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
    if (_accessToken != null) {
      await getProfile();
    }
    notifyListeners();
  }

  // providers/auth_provider.dart
Future<Map<String, dynamic>?> getClientDettes() async {
  if (_accessToken == null) return null;

  try {
    final response = await _authorizedRequest('GET', '/api/client/dettes/');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  } catch (e) {
    print('Error getting client dettes: $e');
    return null;
  }
}

// providers/auth_provider.dart - Ajoutez cette méthode
Future<bool> changePassword(String currentPassword, String newPassword) async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final response = await _authorizedRequest(
      'POST',
      '/api/change-password/',
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );

    _isLoading = false;
    notifyListeners();

    if (response.statusCode == 200) {
      return true;
    } else {
      final errorData = json.decode(response.body);
      _errorMessage = errorData['error'] ?? errorData['detail'] ?? 'Erreur lors du changement';
      return false;
    }
  } catch (e) {
    _isLoading = false;
    notifyListeners();
    _errorMessage = 'Erreur: $e';
    return false;
  }
}
}