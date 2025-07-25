import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nutrition_app/screens/delivery_person_dashboard.dart';
import 'package:nutrition_app/screens/nutricarrier/dashboard.dart';
import 'package:nutrition_app/screens/nutrichef/dashboard.dart';

import 'package:nutrition_app/screens/role_based_landing.dart';
import 'package:nutrition_app/screens/user_details.dart';
import 'package:nutrition_app/screens/dashboard.dart';

import 'package:nutrition_app/screens/loading.dart';

class AuthChecker extends StatelessWidget {
  AuthChecker({super.key});

  Future<Widget> _handleUserRouting(User user) async {

  
  try {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = docSnapshot.data();

    if (data == null) {
      return const RoleBasedLandingScreen(); // Fallback
    }

    final role = data['role'];
    final isSubmitted = data['isSubmitted'] ?? false;

    
    switch (role) {
      case 'NutriMate':
         
     if (!isSubmitted) {

           return UserDetailsScreen();
      }
        return const DashboardScreen();
      case 'NutriChef':
        return const  NutriChefDashboardScreen(); 
      case 'NutriCarrier':
        return const NutriCarrierDashboard(); 
      default:
        return const RoleBasedLandingScreen();
    }
  } catch (e) {
    return Scaffold(
      body: Center(child: Text('Error fetching user data: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Auth state loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ModernLoadingScreen(message: 'Fueling your journey to better health... one byte at a time');
        }

        

        // No user logged in
        if (!snapshot.hasData || snapshot.data == null) {
          return const RoleBasedLandingScreen(); 
        }
        
        // User logged in
        return FutureBuilder<Widget>(
          future: _handleUserRouting(snapshot.data!),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const ModernLoadingScreen();
            } else if (futureSnapshot.hasError) {
              return Scaffold(
                body: Center(child: Text('Error: ${futureSnapshot.error}')),
              );  
            } else {
              return futureSnapshot.data!;
            }
          },
        );
      },
    );
  }
}
