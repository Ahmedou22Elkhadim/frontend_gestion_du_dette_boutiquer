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
      'my_profile': 'Mon Profil',
      'help_support': 'Aide & Support',
      'logout': 'Déconnexion',
      'shop_dashboard': 'Tableau de bord Boutique',
      'manage_clients': 'Gérer mes clients',
      'my_shop': 'Ma Boutique',
      'clients': 'Clients',
      'total_debt': 'Total Dettes',
      'client_list': 'Liste des Clients',
      'phone_hint': 'Numéro de téléphone',
      'password_hint': 'Mot de passe',
      'forgot_password': 'Mot de passe oublié',
      'new_user': 'Nouvel utilisateur ?',
      'register_now': "S'inscrire maintenant",
      'login_success': 'Connexion réussie!',
      'enter_phone': 'Veuillez entrer votre numéro',
      'enter_password': 'Veuillez entrer votre mot de passe',
      'scan': 'Scan',
      'reports': 'Rapports',
      'accueil': 'Accueil',
      'signup_title': 'Inscription',
      'full_name': 'Nom complet',
      'confirm_password': 'Confirmer mot de passe',
      'i_am_a': 'Je suis un :',
      'register_button': "S'INSCRIRE",
      'password_mismatch': 'Les mots de passe ne correspondent pas',
      'registration_success': 'Inscription réussie!',
      'required_field': 'Ce champ est requis',
      'email': 'Email',
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
      'my_profile': 'ملفي الشخصي',
      'help_support': 'المساعدة والدعم',
      'logout': 'تسجيل الخروج',
      'shop_dashboard': 'لوحة تحكم المتجر',
      'manage_clients': 'إدارة العملاء',
      'my_shop': 'متجري',
      'clients': 'العملاء',
      'total_debt': 'إجمالي الديون',
      'client_list': 'قائمة العملاء',
      'phone_hint': 'رقم الهاتف',
      'password_hint': 'كلمة المرور',
      'forgot_password': 'نسيت كلمة المرور',
      'new_user': 'مستخدم جديد ؟',
      'register_now': 'سجل الآن',
      'login_success': 'تم تسجيل الدخول بنجاح!',
      'enter_phone': 'الرجاء إدخال رقم الهاتف',
      'enter_password': 'الرجاء إدخال كلمة المرور',
      'scan': 'مسح QR',
      'reports': 'التقارير',
      'accueil': 'الرئيسية',
      'signup_title': 'تسجيل',
      'full_name': 'الاسم الكامل',
      'confirm_password': 'تأكيد كلمة المرور',
      'i_am_a': 'أنا :',
      'register_button': 'تسجيل',
      'password_mismatch': 'كلمات المرور غير متطابقة',
      'registration_success': 'تم التسجيل بنجاح!',
      'required_field': 'هذا الحقل مطلوب',
      'email': 'البريد الإلكتروني',
      'Nom complet': 'الاسم الكامل',
    },
  };

  String getText(String key) {
    return _localizedValues[_locale.languageCode]![key] ?? key;
  }
}
