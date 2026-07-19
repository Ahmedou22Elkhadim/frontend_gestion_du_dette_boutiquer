// screens/boutiquer_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/shop_provider.dart';
import 'login_screen.dart';
import 'add_client_screen.dart';
import 'demandes_boutiquier_screen.dart';
import 'client_dette_detail_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';
import 'clients_list_screen.dart';
import 'boutiquier_notifications_screen.dart';

class BoutiquerDashboardScreen extends StatefulWidget {
  const BoutiquerDashboardScreen({super.key});

  @override
  State<BoutiquerDashboardScreen> createState() =>
      _BoutiquerDashboardScreenState();
}

class _BoutiquerDashboardScreenState extends State<BoutiquerDashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final RefreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    
    await shopProvider.fetchClients(authProvider);
  }

  // 🔥 Méthode pour le rafraîchissement par glissement
  Future<void> _refreshData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    
    await shopProvider.fetchClients(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final shopProvider = Provider.of<ShopProvider>(context);
    final isRtl = language.locale.languageCode == 'ar';
    final user = authProvider.userProfile;
    
    // Calculer les statistiques
    int totalClients = shopProvider.clients.length;
    double totalDettes = 0;
    int totalDettesImpayees = 0;
    
    for (var client in shopProvider.clients) {
      totalDettes += (client['total_dettes'] as num?)?.toDouble() ?? 0;
      totalDettesImpayees += (client['dettes_impayees'] as int?) ?? 0;
    }

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: _buildDrawer(context, language, authProvider),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            language.getText('shop_dashboard'),
            style: const TextStyle(color: Colors.black, fontSize: 18),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          actions: [
            // 🔥 Le bouton de rafraîchissement est supprimé
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () => _navigateToNotifications(context),
            ),
            IconButton(
              icon: const Icon(Icons.language, color: Colors.black),
              onPressed: () {
                language.toggleLanguage();
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          key: RefreshIndicatorKey,
          onRefresh: _refreshData,  // 🔥 Rafraîchissement par glissement
          color: Colors.green,
          backgroundColor: Colors.white,
          child: shopProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),  // 🔥 Important pour le refresh
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message de bienvenue
                      Text(
                        '${language.getText('Bonjour')} ,${user?['username'] ?? 'Boutiquier'}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Gérez vos clients et leurs dettes',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Metrics Cards
                      _buildMetricsCards(language, totalClients, totalDettes, totalDettesImpayees),
                      const SizedBox(height: 30),

                      // Client List Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            language.getText('client_list'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _navigateToAddClient(context),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Ajouter'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Client List
                      _buildClientList(shopProvider.clients, language),
                    ],
                  ),
                ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(language),
      ),
    );
  }

  Widget _buildMetricsCards(LanguageProvider language, int totalClients, double totalDettes, int totalDettesImpayees) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(
                  language.getText('clients'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  totalClients.toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(
                  language.getText('total_debt'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${totalDettes.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(
                  'Impayées',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  totalDettesImpayees.toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClientList(List<dynamic> clients, LanguageProvider language) {
    if (clients.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(Icons.people_outline, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text(
              'Aucun client pour le moment',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 5),
            Text(
              'Tirez vers le bas pour rafraîchir',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddClient(context),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un client'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () => _navigateToDemandes(context),
              icon: const Icon(Icons.hourglass_empty),
              label: const Text('Voir mes demandes en attente'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: clients.length,
      itemBuilder: (context, index) {
        final client = clients[index];
        return _buildClientCard(client);
      },
    );
  }

  Widget _buildClientCard(dynamic client) {
    return GestureDetector(
      onTap: () => _navigateToClientDetails(context, client),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.withAlpha(50),
              child: Text(
                (client['user_nom'] as String).substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.green),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client['user_nom'] ?? 'Client',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    client['user_phone'] ?? '---',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(client['total_dettes'] as num?)?.toDouble() ?? 0} FCFA',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: (client['dettes_impayees'] as int? ?? 0) > 0
                        ? Colors.orange.withAlpha(20)
                        : Colors.green.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${client['dettes_impayees'] ?? 0} impayée(s)',
                    style: TextStyle(
                      fontSize: 10,
                      color: (client['dettes_impayees'] as int? ?? 0) > 0
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, LanguageProvider language, AuthProvider authProvider) {
    final user = authProvider.userProfile;
    
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF4CAF50)),
            accountName: Text(
              user?['username'] ?? 'Boutiquier',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              user?['phone_number'] ?? '---',
              style: const TextStyle(color: Colors.white70),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.store, size: 40, color: Color(0xFF4CAF50)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.black87),
            title: Text(language.getText('my_profile')),
            onTap: () {
              Navigator.pop(context);
              _navigateToProfile(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.black87),
            title: Text('Mes clients'),
            onTap: () {
              Navigator.pop(context);
              _navigateToClients(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.hourglass_empty, color: Colors.orange),
            title: const Text('Demandes en attente'),
            onTap: () {
              Navigator.pop(context);
              _navigateToDemandes(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.black87),
            title: Text(language.getText('settings')),
            onTap: () {
              Navigator.pop(context);
              _navigateToSettings(context);
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              language.getText('logout'),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              authProvider.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(LanguageProvider language) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        if (index == 1) {
          _navigateToClients(context);
        } else if (index == 2) {
          _navigateToScan(context);
        } else if (index == 3) {
          _navigateToReports(context);
        }
      },
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 10,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: language.getText('accueil'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.people_outline),
          activeIcon: const Icon(Icons.people),
          label: language.getText('clients'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.qr_code_scanner),
          label: language.getText('scan'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.pie_chart_outline),
          activeIcon: const Icon(Icons.pie_chart),
          label: language.getText('reports'),
        ),
      ],
    );
  }

  void _navigateToClientDetails(BuildContext context, dynamic client) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ClientDetteDetailScreen(
        clientId: client['user'],
        clientName: client['user_nom'] ?? 'Client',
        clientPhone: client['user_phone'] ?? '',
      ),
    ),
  );
}

  void _navigateToAddClient(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddClientScreen(),
      ),
    );
  }

  void _navigateToDemandes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DemandesBoutiquierScreen(),
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(context,
    MaterialPageRoute(builder: (context) => const ProfileScreen() )
    );
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  void _navigateToClients(BuildContext context) {
    Navigator.push(context, 
    MaterialPageRoute(builder: (context) => const ClientsListScreen())
    );
  }

  void _navigateToScan(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scan QR code à venir')),
    );
  }

  void _navigateToReports(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rapports à venir')),
    );
  }

  void _navigateToNotifications(BuildContext context) {
   Navigator.push(context, 
    MaterialPageRoute(builder: (context) => const BoutiquierNotificationsScreen())
    );
  }
}