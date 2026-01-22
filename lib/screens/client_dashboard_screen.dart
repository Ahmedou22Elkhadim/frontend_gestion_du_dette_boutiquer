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
                  color: Color(0xFF4CAF50), // Green Theme
                ),
                accountName: const Text(
                  "Ahmedou",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: const Text(
                  "22487323",
                  style: TextStyle(color: Colors.white70),
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Color(0xFF4CAF50)),
                ),
              ),

              // Menu Items
              ListTile(
                leading: const Icon(Icons.person, color: Colors.black87),
                title: Text(language.getText('my_profile')),
                onTap: () {
                  // Navigate to profile
                  Navigator.pop(context); // Close drawer
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.black87),
                title: Text(language.getText('help_support')),
                onTap: () {
                  // Navigate to support
                  Navigator.pop(context); // Close drawer
                },
              ),

              const Spacer(), // Pushes logout to the bottom

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
            // User Card - Improved Design
            Container(
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
                      Icons.qr_code,
                      color: Color(0xFF4CAF50),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Ahmedou',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '22487323',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
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
            ),

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
                  // border: Border.all(color: Colors.black87), // Removed border for cleaner look
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 10),
                    const Icon(Icons.filter_list, color: Colors.grey),
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
                        padding: const EdgeInsets.all(12), // Compact padding
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(20),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFE8F5E9,
                                ), // Light Green bg for icon
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  shop.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4CAF50),
                                    fontSize: 18,
                                  ),
                                ),
                              ),
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
                                  const SizedBox(height: 4),
                                  Text(
                                    shop.phone,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "5000 UM", // Placeholder amount
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.redAccent,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  shop.date,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
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
              selectedItemColor: const Color(0xFF4CAF50), // Green Theme
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
                // const BottomNavigationBarItem(
                //   icon: SizedBox.shrink(), // Placeholder for center button
                //   label: '',
                // ),
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
            ),
            // Positioned(
            //   bottom: 25,
            //   child: Container(
            //     width: 60,
            //     height: 60,
            //     decoration: BoxDecoration(
            //       color: const Color(0xFF4CAF50),
            //       shape: BoxShape.circle,
            //       boxShadow: [
            //         BoxShadow(
            //           color: const Color(0xFF4CAF50).withAlpha(60),
            //           blurRadius: 10,
            //           spreadRadius: 2,
            //           offset: const Offset(0, 5),
            //         ),
            //       ],
            //     ),
            //     child: const Icon(
            //       Icons.qr_code_scanner,
            //       size: 30,
            //       color: Colors.white,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
