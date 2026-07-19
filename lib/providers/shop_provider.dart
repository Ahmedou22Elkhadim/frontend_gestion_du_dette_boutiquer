// providers/shop_provider.dart
import 'package:flutter/material.dart';
import 'auth_provider.dart';

class ShopProvider with ChangeNotifier {
  List<dynamic> _shops = [];
  List<dynamic> _clients = [];
  Map<String, dynamic>? _stats;
  bool _isLoading = false;

  List<dynamic> get shops => _shops;
  List<dynamic> get clients => _clients;
  Map<String, dynamic>? get stats => _stats;
  bool get isLoading => _isLoading;

  Future<void> fetchShops(AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) return;
    
    // 🔥 Éviter les appels pendant le build
    await Future.microtask(() {
      _isLoading = true;
      notifyListeners();
    });
    
    try {
      final boutiques = await authProvider.getClientBoutiques();
      
      // 🔥 Utiliser Future.microtask pour éviter l'erreur
      await Future.microtask(() {
        _shops = boutiques;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      await Future.microtask(() {
        _isLoading = false;
        notifyListeners();
      });
      print('Error fetching shops: $e');
    }
  }

  Future<void> fetchTotalDette(AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) return;
    
    try {
      final stats = await authProvider.getClientTotalDette();
      
      await Future.microtask(() {
        _stats = stats;
        notifyListeners();
      });
    } catch (e) {
      print('Error fetching total dette: $e');
    }
  }

  Future<void> fetchClients(AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) return;
    
    await Future.microtask(() {
      _isLoading = true;
      notifyListeners();
    });
    
    try {
      final clients = await authProvider.getClients();
      
      await Future.microtask(() {
        _clients = clients;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      await Future.microtask(() {
        _isLoading = false;
        notifyListeners();
      });
      print('Error fetching clients: $e');
    }
  }

  void clearData() {
    _shops = [];
    _clients = [];
    _stats = null;
    notifyListeners();
  }
}