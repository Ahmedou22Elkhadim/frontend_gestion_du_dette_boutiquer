// providers/language_provider.dart
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

  void setLanguage(String languageCode) {
    _locale = Locale(languageCode);
    notifyListeners();
  }

  // Simple dictionary for translations
  final Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      // Général
      'app_title': 'Karnet Deyn',
      'welcome': 'Bienvenue',
      'search': 'Rechercher',
      'search_hint': 'Rechercher...',
      'home': 'Accueil',
      'stats': 'Statistiques',
      'history': 'Historique',
      'settings': 'Paramètres',
      'accueil': 'Accueil',
      'reports': 'Rapports',
      'scan': 'Scanner',
      
      // Authentification
      'login': 'Connexion',
      'signup': 'Inscription',
      'logout': 'Déconnexion',
      'phone_hint': 'Numéro de téléphone',
      'password_hint': 'Mot de passe',
      'forgot_password': 'Mot de passe oublié',
      'new_user': 'Nouvel utilisateur ?',
      'register_now': 'S\'inscrire maintenant',
      'login_success': 'Connexion réussie!',
      'enter_phone': 'Veuillez entrer votre numéro',
      'enter_password': 'Veuillez entrer votre mot de passe',
      'signup_title': 'Inscription',
      'full_name': 'Nom complet',
      'confirm_password': 'Confirmer mot de passe',
      'i_am_a': 'Je suis un :',
      'register_button': 'S\'INSCRIRE',
      'password_mismatch': 'Les mots de passe ne correspondent pas',
      'registration_success': 'Inscription réussie!',
      'required_field': 'Ce champ est requis',
      'email': 'Email',
      
      // Rôles
      'client': 'Client',
      'boutiquier': 'Boutiquier',
      'admin': 'Administrateur',
      
      // Dashboard Boutiquier
      'shop_dashboard': 'Tableau de bord Boutique',
      'manage_clients': 'Gérer mes clients',
      'my_shop': 'Ma Boutique',
      'clients': 'Clients',
      'total_debt': 'Total Dettes',
      'client_list': 'Liste des Clients',
      'add_client': 'Ajouter un client',
      'send_request': 'Envoyer la demande',
      'client_phone': 'Numéro du client',
      'address': 'Adresse',
      'message': 'Message',
      'client_debt': 'Dette client',
      'impayees': 'Impayées',
      'shop_list': 'Liste des boutiques',
      'my_clients': 'Mes clients',
      
      // Dashboard Client
      'my_profile': 'Mon Profil',
      'help_support': 'Aide & Support',
      'shop_list_client': 'Mes boutiques',
      'total_due': 'Total dû',
      'paid': 'Payées',
      'unpaid': 'Impayées',
      'my_demands': 'Mes demandes',
      'shop_details': 'Détails de la boutique',
      'debt_list': 'Liste des dettes',
      'no_shops': 'Aucune boutique pour le moment',
      'no_debts': 'Aucune dette pour cette boutique',
      'accept': 'Accepter',
      'refuse': 'Refuser',
      'pending': 'En attente',
      'accepted': 'Acceptée',
      'refused': 'Refusée',
      'add_debt': 'Ajouter une dette',
      'edit_debt': 'Modifier la dette',
      'delete_debt': 'Supprimer la dette',
      'mark_as_paid': 'Marquer comme payée',
      'product': 'Produit',
      'quantity': 'Quantité',
      'amount': 'Montant',
      'due_date': 'Date d\'échéance',
      'description': 'Description',
      'total': 'Total',
      'number_of_debts': 'Nombre de dettes',
      
      // Notifications
      'notifications': 'Notifications',
      'no_notifications': 'Aucune notification',
      'demand_sent': 'Demande envoyée',
      'demand_accepted': 'Demande acceptée',
      'demand_refused': 'Demande refusée',
      
      // Erreurs
      'error_occurred': 'Une erreur est survenue',
      'connection_error': 'Erreur de connexion',
      'session_expired': 'Session expirée',
      'access_denied': 'Accès refusé',
      
      // OTP
      'otp_verification': 'Vérification OTP',
      'otp_sent': 'Un code a été envoyé au',
      'verify': 'Vérifier',
      'resend_code': 'Renvoyer le code',
      'resend_in': 'Renvoyer dans',
      'seconds': 'secondes',
      'resend_code_prompt': 'Vous n\'avez pas reçu le code ? ',
      'resend': 'Renvoyer',
      
      // Autres
      'my_shop': 'Ma Boutique',
      'shop_list': 'Liste des boutiques',
      'total_dettes': 'Total Dettes',
      'client_management': 'Gestion des clients',
      'profile': 'Profil',
      'statistics': 'Statistiques',
      'reports_title': 'Rapports',
      'qr_scan': 'Scanner QR',
    },
    'ar': {
      // Général
      'app_title': 'كارني دين',
      'welcome': 'مرحباً',
      'search': 'بحث',
      'search_hint': 'بحث...',
      'home': 'الرئيسية',
      'stats': 'الإحصائيات',
      'history': 'السجل',
      'settings': 'الإعدادات',
      'accueil': 'الرئيسية',
      'reports': 'التقارير',
      'scan': 'مسح QR',
      
      // Authentification
      'login': 'تسجيل الدخول',
      'signup': 'تسجيل جديد',
      'logout': 'تسجيل الخروج',
      'phone_hint': 'رقم الهاتف',
      'password_hint': 'كلمة المرور',
      'forgot_password': 'نسيت كلمة المرور',
      'new_user': 'مستخدم جديد ؟',
      'register_now': 'سجل الآن',
      'login_success': 'تم تسجيل الدخول بنجاح!',
      'enter_phone': 'الرجاء إدخال رقم الهاتف',
      'enter_password': 'الرجاء إدخال كلمة المرور',
      'signup_title': 'تسجيل',
      'full_name': 'الاسم الكامل',
      'confirm_password': 'تأكيد كلمة المرور',
      'i_am_a': 'أنا :',
      'register_button': 'تسجيل',
      'password_mismatch': 'كلمات المرور غير متطابقة',
      'registration_success': 'تم التسجيل بنجاح!',
      'required_field': 'هذا الحقل مطلوب',
      'email': 'البريد الإلكتروني',
      'Bonjour': 'مرحباً',
      
      // Rôles
      'client': 'عميل',
      'boutiquier': 'تاجر',
      'admin': 'مدير',
      
      // Dashboard Boutiquier
      'shop_dashboard': 'لوحة تحكم المتجر',
      'manage_clients': 'إدارة العملاء',
      'my_shop': 'متجري',
      'clients': 'العملاء',
      'total_debt': 'إجمالي الديون',
      'client_list': 'قائمة العملاء',
      'add_client': 'إضافة عميل',
      'send_request': 'إرسال الطلب',
      'client_phone': 'رقم العميل',
      'address': 'العنوان',
      'message': 'رسالة',
      'client_debt': 'دين العميل',
      'impayees': 'غير مدفوعة',
      'shop_list': 'قائمة المتاجر',
      'my_clients': 'عملائي',
      
      // Dashboard Client
      'my_profile': 'ملفي الشخصي',
      'help_support': 'المساعدة والدعم',
      'shop_list_client': 'متاجري',
      'total_due': 'إجمالي المستحق',
      'paid': 'مدفوعة',
      'unpaid': 'غير مدفوعة',
      'my_demands': 'طلباتي',
      'shop_details': 'تفاصيل المتجر',
      'debt_list': 'قائمة الديون',
      'no_shops': 'لا توجد متاجر حاليا',
      'no_debts': 'لا توجد ديون لهذا المتجر',
      'accept': 'قبول',
      'refuse': 'رفض',
      'pending': 'قيد الانتظار',
      'accepted': 'مقبولة',
      'refused': 'مرفوضة',
      'add_debt': 'إضافة دين',
      'edit_debt': 'تعديل الدين',
      'delete_debt': 'حذف الدين',
      'mark_as_paid': 'تحديد كمدفوع',
      'product': 'المنتج',
      'quantity': 'الكمية',
      'amount': 'المبلغ',
      'due_date': 'تاريخ الاستحقاق',
      'description': 'الوصف',
      'total': 'الإجمالي',
      'number_of_debts': 'عدد الديون',
      
      // Notifications
      'notifications': 'الإشعارات',
      'no_notifications': 'لا توجد إشعارات',
      'demand_sent': 'تم إرسال الطلب',
      'demand_accepted': 'تم قبول الطلب',
      'demand_refused': 'تم رفض الطلب',
      
      // Erreurs
      'error_occurred': 'حدث خطأ',
      'connection_error': 'خطأ في الاتصال',
      'session_expired': 'انتهت الجلسة',
      'access_denied': 'تم رفض الوصول',
      
      // OTP
      'otp_verification': 'التحقق من الرمز',
      'otp_sent': 'تم إرسال رمز إلى',
      'verify': 'تحقق',
      'resend_code': 'إعادة إرسال الرمز',
      'resend_in': 'إعادة الإرسال بعد',
      'seconds': 'ثانية',
      'resend_code_prompt': 'لم تستلم الرمز؟ ',
      'resend': 'إعادة إرسال',
      
      // Autres
      'total_dettes': 'إجمالي الديون',
      'client_management': 'إدارة العملاء',
      'profile': 'الملف الشخصي',
      'statistics': 'الإحصائيات',
      'reports_title': 'التقارير',
      'qr_scan': 'مسح QR',
      // Dans la section 'fr'
// 'accept': 'Accepter',
// 'refuse': 'Refuser',
// 'pending': 'En attente',
// 'accepted': 'Acceptée',
// 'refused': 'Refusée',
// 'debt': 'Dette',
// 'paid': 'Payée',
// 'unpaid': 'Impayée',
'dark_mode': 'Mode sombre',
'change_password': 'Changer le mot de passe',
'preferences': 'Préférences',
'disable_notifications': 'Désactiver les notifications',
'notifications_enabled': 'Notifications activées',
'notifications_disabled': 'Notifications désactivées',

// Dans la section 'ar'
// 'accept': 'قبول',
// 'refuse': 'رفض',
// 'pending': 'قيد الانتظار',
// 'accepted': 'مقبولة',
// 'refused': 'مرفوضة',
// 'debt': 'دين',
// 'paid': 'مدفوعة',
// 'unpaid': 'غير مدفوعة',
// 'dark_mode': 'الوضع الداكن',
// 'change_password': 'تغيير كلمة المرور',
// 'preferences': 'التفضيلات',
// 'disable_notifications': 'تعطيل الإشعارات',
// 'notifications_enabled': 'الإشعارات مفعلة',
// 'notifications_disabled': 'الإشعارات معطلة',
    },
  };

  String getText(String key) {
    return _localizedValues[_locale.languageCode]?[key] ?? key;
  }
}