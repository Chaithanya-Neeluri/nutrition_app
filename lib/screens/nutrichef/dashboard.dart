import 'package:flutter/material.dart';
import 'package:nutrition_app/screens/nutrichef/home.dart';
import 'package:nutrition_app/screens/nutrichef/orders.dart';
import 'package:nutrition_app/screens/nutrichef/assignorder.dart';
import 'package:nutrition_app/screens/nutrichef/profile.dart';
import 'package:nutrition_app/screens/nutrichef/settings.dart';

class NutriChefDashboardScreen extends StatefulWidget {
  const NutriChefDashboardScreen({super.key});

  @override
  State<NutriChefDashboardScreen> createState() => _NutriChefDashboardScreenState();
}

class _NutriChefDashboardScreenState extends State<NutriChefDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    NutriChefHome(),
    OrdersScreen(),
    AssignOrdersScreen(),
    RestaurantProfileScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_ind), label: 'Assign'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
