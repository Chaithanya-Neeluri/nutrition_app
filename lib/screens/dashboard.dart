import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutrition_app/widgets/auth_checker.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: Colors.lightGreen.withAlpha(120),
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            onPressed: (){
              FirebaseAuth.instance.signOut();
                 Navigator.pushReplacement(
                context,
                 MaterialPageRoute(builder: (_) => AuthChecker()),
                 );
            },
             icon:Icon(Icons.exit_to_app)
             )
        ],
        ),
      body: const Center(
        child: Text(
          "Welcome to your personalized nutrition dashboard!",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
