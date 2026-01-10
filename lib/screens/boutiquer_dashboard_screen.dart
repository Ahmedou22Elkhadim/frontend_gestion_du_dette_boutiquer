import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class BoutiquerDashboardScreen extends StatefulWidget {
  const BoutiquerDashboardScreen({super.key});

  @override
  State<BoutiquerDashboardScreen> createState() =>
      _BoutiquerDashboardScreenState();
}

class _BoutiquerDashboardScreenState extends State<BoutiquerDashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // Basic Layout for Shopkeeper
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF50), // Green for shopkeeper
              ),
              accountName: const Text(
                "Ma Boutique",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: const Text(
                "Gérer mes clients",
                style: TextStyle(color: Colors.white70),
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.store, size: 40, color: Color(0xFF4CAF50)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.black87),
              title: const Text('Mon Profil'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.black87),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Déconnexion',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Tableau de bord Boutique",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Metrics Cards
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9), // Light Green
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          "Clients",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "24",
                          style: TextStyle(
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
                      color: const Color(0xFFFFF3E0), // Light Orange
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          "Total Dettes",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "150k",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Client List Header
            const Text(
              "Liste des Clients",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // Placeholder List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
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
                        backgroundColor: Colors.blueAccent.withAlpha(50),
                        child: Text(
                          "C${index + 1}",
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Client ${index + 1}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "Tel: 22487323",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${(index + 1) * 5000} UM",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.green,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Clients"),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: "Scan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: "Rapports",
          ),
        ],
      ),
    );
  }
}
