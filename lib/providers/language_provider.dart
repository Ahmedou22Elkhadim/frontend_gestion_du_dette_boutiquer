import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('fr');

  Locale get locale => _locale;

  void toggleLanguage() {
    if (_locale.languageCode == 'fr') {
      _locale = const Locale('ar');
    } else {
      _locale = const Locale('fr');
    }
    notifyListeners();
  }

  // Simple dictionary for translations
  final Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      'app_title': 'Karnet Deyn',
      'login': 'Connexion',
      'signup': "S'inscrire",
      'shop_list': 'List des boutiques',
      'search': 'rechercher',
      'client': 'Client',
      'boutiquier': 'Boutiquier',
      'search_hint': 'rechercher...',
      'home': 'Acceuil',
      'stats': 'Statistique',
      'history': 'Historique',
      'settings': 'Parametre',
      'welcome': 'Bienvenue',
      // Add more as needed
    },
    'ar': {
      'app_title': 'كارني دين',
      'login': 'تسجيل الدخول',
      'signup': 'تسجيل جديد',
      'shop_list': 'قائمة المتاجر',
      'search': 'بحث',
      'client': 'عميل',
      'boutiquier': 'تاجر',
      'search_hint': 'بحث...',
      'home': 'الرئيسية',
      'stats': 'الإحصائيات',
      'history': 'السجل',
      'settings': 'الإعدادات',
      'welcome': 'مرحباً',
    },
  };

  String getText(String key) {
    return _localizedValues[_locale.languageCode]![key] ?? key;
  }
}
