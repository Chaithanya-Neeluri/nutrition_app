import 'package:flutter/material.dart';
import 'package:nutrition_app/screens/nutricarrier/profile.dart';
import 'package:nutrition_app/screens/nutricarrier/orders.dart';
import 'package:nutrition_app/screens/nutricarrier/rewards.dart';
import 'package:nutrition_app/screens/nutricarrier/help.dart';
import 'package:nutrition_app/screens/nutricarrier/home.dart';

class NutriCarrierDashboard extends StatefulWidget {
  const NutriCarrierDashboard({super.key});

  @override
  State<NutriCarrierDashboard> createState() => _NutriCarrierDashboardState();
}

class _NutriCarrierDashboardState extends State<NutriCarrierDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AssignedOrdersScreen(),
    RewardsScreen(),
    HelpScreen(),
    NutriCarrierProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).cardColor,
        title: Row(
          children: [
            Image.asset(
              'assets/app_logo.png',
              height: 40,
            ),
            const SizedBox(width: 8),
            Text(
              'NutriCarrier',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined,
                color: Theme.of(context).colorScheme.primary),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            backgroundColor: Theme.of(context).cardColor,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.delivery_dining),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events),
                label: 'Rewards',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.help_outline),
                label: 'Help',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
