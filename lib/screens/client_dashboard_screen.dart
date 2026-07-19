// screens/client_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/shop_provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../providers/client_demandes_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'boutiquer_detail_screen.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _demandesEnAttente = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _loadDemandesCount();
    });
  }

  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    
    await shopProvider.fetchShops(authProvider);
    await shopProvider.fetchTotalDette(authProvider);
  }

  Future<void> _loadDemandesCount() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final demandes = await authProvider.getClientDemandes();
    setState(() {
      _demandesEnAttente = demandes.where((d) => d['statut'] == 'en_attente').length;
    });
  }

  Future<void> _refreshData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    
    await shopProvider.fetchShops(authProvider);
    await shopProvider.fetchTotalDette(authProvider);
    await _loadDemandesCount();
  }

  Future<int> _getDemandesEnAttenteCount() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final demandes = await authProvider.getClientDemandes();
    return demandes.where((d) => d['statut'] == 'en_attente').length;
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final shopProvider = Provider.of<ShopProvider>(context);
    final isRtl = language.locale.languageCode == 'ar';
    final user = authProvider.userProfile;
    
    // Récupérer les données
    final boutiques = shopProvider.shops;
    final totalDette = shopProvider.stats;
    final isLoading = shopProvider.isLoading;
    
    double totalGeneral = 0;
    if (totalDette != null) {
      totalGeneral = (totalDette['total_general_restant'] as num?)?.toDouble() ?? 0;
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
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          actions: [
            // 🔥 Bouton des demandes avec indicateur
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.black),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClientDemandesScreen(),
                      ),
                    );
                    await _loadDemandesCount();
                    await _refreshData();
                  },
                ),
                // Indicateur de notifications
                if (_demandesEnAttente > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_demandesEnAttente',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
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
          onRefresh: _refreshData,
          color: Colors.green,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // User Card
                      _buildUserCard(user, totalGeneral),
                      
                      // List Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              language.getText('shop_list'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${boutiques.length} boutique(s)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 10),
                              const Icon(Icons.search, color: Colors.grey),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: language.getText('search'),
                                    border: InputBorder.none,
                                    hintStyle: const TextStyle(color: Colors.grey),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Shop List (Boutiques acceptées)
                      _buildShopList(boutiques, language),
                    ],
                  ),
                ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(language),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic>? user, double totalGeneral) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withAlpha(80),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.person,
              color: Color(0xFF4CAF50),
              size: 30,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?['username'] ?? 'Client',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 14, color: Colors.white70),
                    const SizedBox(width: 5),
                    Text(
                      'Total dû: ${totalGeneral.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white70,
            size: 16,
          ),
        ],
      ),
    );
  }

  // Dans client_dashboard_screen.dart, ajoutez l'import

// Modifiez la méthode _buildShopList pour ajouter le onTap
Widget _buildShopList(List<dynamic> boutiques, LanguageProvider language) {
  if (boutiques.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.store_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(language.getText( 'Aucune boutique pour le moment',),
           
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Les boutiquiers que vous acceptez apparaîtront ici',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    itemCount: boutiques.length,
    itemBuilder: (context, index) {
      final boutique = boutiques[index];
      return GestureDetector(
        onTap: () {
          // 🔥 Navigation vers les détails de la boutique
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShopDetailScreen(
                boutiqueId: boutique['id'],
                boutiqueNom: boutique['nom'] ?? 'Boutique',
                boutiquePhone: boutique['telephone'] ?? '',
                boutiqueAdresse: boutique['adresse'],
              ),
            ),
          );
        },
        child: Card(
          margin: const EdgeInsets.only(bottom: 15),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        (boutique['nom'] as String).substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4CAF50),
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    boutique['nom'] ?? 'Boutique',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 12, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            boutique['telephone'] ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (boutique['adresse'] != null && boutique['adresse'].isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              boutique['adresse'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, size: 14, color: Colors.green[700]),
                                const SizedBox(width: 4),
                                Text(
                                  'Acceptée',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.receipt, size: 14, color: Colors.orange[700]),
                                const SizedBox(width: 4),
                                Text(
                                  '${boutique['nombre_dettes'] ?? 0} dette(s)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(boutique['total_restant'] as num?)?.toDouble() ?? 0} FCFA',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
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
              user?['username'] ?? 'Client',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              user?['phone_number'] ?? '---',
              style: const TextStyle(color: Colors.white70),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Color(0xFF4CAF50)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.black87),
            title: Text(language.getText('my_profile')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          // 🔥 AJOUTER ICI - Menu Mes demandes
          ListTile(
            leading: Icon(Icons.notifications_active, color: Colors.orange[700]),
            title: const Text('Mes demandes'),
            trailing: _demandesEnAttente > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_demandesEnAttente',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                : null,
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ClientDemandesScreen(),
                ),
              );
              await _loadDemandesCount();
              await _refreshData();
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.black87),
            title: Text(language.getText('help_support')),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.black87),
            title: Text(language.getText('settings')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              language.getText('logout'),
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              Navigator.pop(context);
              authProvider.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
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
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF4CAF50),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 10,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: language.getText('home'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.bar_chart),
          label: language.getText('stats'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.history),
          label: language.getText('history'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          activeIcon: const Icon(Icons.settings),
          label: language.getText('settings'),
        ),
      ],
    );
  }
}