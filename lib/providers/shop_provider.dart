import 'package:flutter/material.dart';

class Shop {
  final String id;
  final String name;
  final String phone;
  final String date;
  final Color color; // For the avatar background

  Shop({
    required this.id,
    required this.name,
    required this.phone,
    required this.date,
    this.color = const Color(0xFFC5A39F), // Default dusty pink from UI
  });
}

class ShopProvider with ChangeNotifier {
  final List<Shop> _shops = [
    Shop(id: '1', name: 'Sidi Abdi', phone: '22010203', date: '12-11-25'),
    Shop(id: '2', name: 'Sidi Abdi', phone: '22010203', date: '12-11-25'),
    Shop(
      id: '3',
      name: 'Ahmedou Shop',
      phone: '33445566',
      date: '13-11-25',
      color: Colors.blueGrey,
    ),
  ];

  List<Shop> get shops => _shops;

  // Simulate fetching shops
  Future<void> fetchShops() async {
    // API call would go here
    await Future.delayed(const Duration(seconds: 1));
    notifyListeners();
  }
}
