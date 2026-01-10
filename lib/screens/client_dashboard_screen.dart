import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/shop_provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Fetch shops when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShopProvider>(context, listen: false).fetchShops();
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = Provider.of<LanguageProvider>(context);
    final isRtl = language.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        drawer: Drawer(
          child: Column(
            children: [
              // Drawer Header
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFFE0CFA9), // Matching the User Card color
                ),
                accountName: const Text(
                  "Ahmedou",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: const Text(
                  "22487323",
                  style: TextStyle(color: Colors.black87),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Color(0xFFE0CFA9)),
                ),
              ),

              // Menu Items
              ListTile(
                leading: const Icon(Icons.person, color: Colors.black87),
                title: const Text('Mon Profil'),
                onTap: () {
                  // Navigate to profile
                  Navigator.pop(context); // Close drawer
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.black87),
                title: const Text('Aide & Support'),
                onTap: () {
                  // Navigate to support
                  Navigator.pop(context); // Close drawer
                },
              ),

              const Spacer(), // Pushes logout to the bottom

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
                  // Close drawer
                  Navigator.pop(context);

                  // Logout logic
                  Provider.of<AuthProvider>(context, listen: false).logout();

                  // Navigate to Login
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
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
            IconButton(
              icon: const Icon(Icons.language, color: Colors.black),
              onPressed: () {
                language.toggleLanguage();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // User Card
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE0CFA9), // Gold/Beige color
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    color: const Color(0xFFFFF0EB), // Light pinkish for logo bg
                    child: const Text(
                      'Logo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Ahmedou',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '22487323',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // List des boutiques Label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                language.getText('shop_list'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black87),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    const Icon(Icons.filter_list),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: language.getText('search'),
                          border: InputBorder.none,
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Shop List
            Expanded(
              child: Consumer<ShopProvider>(
                builder: (context, shopProvider, child) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: shopProvider.shops.length,
                    itemBuilder: (context, index) {
                      final shop = shopProvider.shops[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2EBE9), // Pinkish beige
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: shop.color,
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shop.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    shop.phone,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Text(
                                shop.date,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.black54,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  label: language.getText('home'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.bar_chart),
                  label: language.getText('stats'),
                ),
                const BottomNavigationBarItem(
                  icon: SizedBox.shrink(), // Placeholder for center button
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.history),
                  label: language.getText('history'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings_outlined),
                  label: language.getText('settings'),
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFC5E1A5), // Light Green
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 30,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
