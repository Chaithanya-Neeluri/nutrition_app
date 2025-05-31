import 'package:flutter/material.dart';
import  'package:nutrition_app/screens/nutricarrier/profile.dart';
import 'package:nutrition_app/screens/nutricarrier/orders.dart';
import 'package:nutrition_app/screens/nutricarrier/rewards.dart';
import 'package:nutrition_app/screens/nutricarrier/help.dart';

class NutriCarrierDashboard extends StatefulWidget {
  const NutriCarrierDashboard({super.key});

  @override
  State<NutriCarrierDashboard> createState() => _NutriCarrierDashboardState();
}

class _NutriCarrierDashboardState extends State<NutriCarrierDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AssignedOrdersScreen(),
    RewardsScreen(),
    HelpScreen(),
    NutriCarrierProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Rewards'),
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: 'Help'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
