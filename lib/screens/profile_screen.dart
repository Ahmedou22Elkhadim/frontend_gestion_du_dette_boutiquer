// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isRtl = language.locale.languageCode == 'ar';
    final user = authProvider.userProfile;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(language.getText('my_profile')),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  user?['role'] == 'boutiquier' ? Icons.store : Icons.person,
                  size: 50,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              
              // Nom
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Nom d\'utilisateur'),
                  subtitle: Text(user?['username'] ?? 'Non défini'),
                ),
              ),
              
              // Téléphone
              Card(
                child: ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Téléphone'),
                  subtitle: Text(user?['phone_number'] ?? 'Non défini'),
                ),
              ),
              
              // Email
              Card(
                child: ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text(user?['email'] ?? 'Non défini'),
                ),
              ),
              
              // Rôle
              Card(
                child: ListTile(
                  leading: const Icon(Icons.badge),
                  title: const Text('Rôle'),
                  subtitle: Text(user?['role'] ?? 'Non défini'),
                  trailing: Chip(
                    label: Text(
                      user?['role'] == 'boutiquier' ? 'Boutiquier' : 'Client',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: user?['role'] == 'boutiquier' 
                        ? Colors.orange 
                        : Colors.green,
                  ),
                ),
              ),
              
              // Statut validation
              Card(
                child: ListTile(
                  leading: const Icon(Icons.verified),
                  title: const Text('Statut'),
                  subtitle: Text(user?['is_validated'] == true ? 'Validé' : 'Non validé'),
                  trailing: Icon(
                    user?['is_validated'] == true 
                        ? Icons.check_circle 
                        : Icons.pending,
                    color: user?['is_validated'] == true 
                        ? Colors.green 
                        : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}