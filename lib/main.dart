// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import 'providers/shop_provider.dart';
import 'screens/login_screen.dart';
import 'screens/boutiquer_dashboard_screen.dart';
import 'screens/client_dashboard_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final authProvider = AuthProvider();
  await authProvider.loadSavedTokens();
  
  runApp(MyApp(authProvider: authProvider));
}

class MyApp extends StatelessWidget {
  final AuthProvider authProvider;
  
  const MyApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Karnet Deyn',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: authProvider.isAuthenticated 
                ? (authProvider.userRole == 'boutiquier' 
                    ? const BoutiquerDashboardScreen()
                    : const ClientDashboardScreen())
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}