// screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../providers/theme_provider.dart';
import '../providers/notification_provider.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final isRtl = language.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(language.getText('settings')),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: ListView(
          children: [
            // Section Préférences
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                language.getText('preferences'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            // Langue
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                leading: const Icon(Icons.language, color: Colors.green),
                title: Text(language.getText('language')),
                subtitle: Text(language.locale.languageCode == 'fr' ? 'Français' : 'العربية'),
                trailing: DropdownButton<String>(
                  value: language.locale.languageCode,
                  items: const [
                    DropdownMenuItem(value: 'fr', child: Text('Français')),
                    DropdownMenuItem(value: 'ar', child: Text('العربية')),
                  ],
                  onChanged: (value) {
                    if (value != null && value != language.locale.languageCode) {
                      language.toggleLanguage();
                    }
                  },
                ),
              ),
            ),
            
            // Section Apparence
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                language.getText('appearance'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            // Mode sombre - Fonctionnel
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                leading: const Icon(Icons.dark_mode, color: Colors.green),
                title: Text(language.getText('dark_mode')),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  activeColor: Colors.green,
                ),
              ),
            ),
            
            // Section Compte
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                language.getText('account'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            // Changer mot de passe - Navigation réelle
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                leading: const Icon(Icons.lock, color: Colors.green),
                title: Text(language.getText('change_password')),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),
            ),
            
            // Section Notifications
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                language.getText('notifications'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            // Désactiver notifications - Fonctionnel
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                leading: const Icon(Icons.notifications, color: Colors.green),
                title: Text(language.getText('disable_notifications')),
                subtitle: Text(
                  notificationProvider.notificationsEnabled 
                      ? language.getText('notifications_enabled')
                      : language.getText('notifications_disabled'),
                ),
                trailing: Switch(
                  value: notificationProvider.notificationsEnabled,
                  onChanged: (value) {
                    notificationProvider.toggleNotifications();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          notificationProvider.notificationsEnabled 
                              ? 'Notifications activées'
                              : 'Notifications désactivées',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  activeColor: Colors.green,
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Bouton Déconnexion
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(language.getText('logout')),
                      content: Text(language.getText('logout_confirm')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(language.getText('cancel')),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: Text(language.getText('logout')),
                        ),
                      ],
                    ),
                  );
                  
                  if (confirm == true && context.mounted) {
                    authProvider.logout();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.logout),
                label: Text(language.getText('logout')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Version
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}