import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutrition_app/screens/nutrichef/widgets/dashboard_card.dart';
class NutriChefHome extends StatelessWidget {
  const NutriChefHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriChef Dashboard'),
        actions:[
          IconButton(onPressed:(){
            FirebaseAuth.instance.signOut();
          }, icon: Icon(Icons.exit_to_app))
        ]
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          children: const [
            DashboardCard(icon: Icons.receipt_long, title: "Orders Today", value: "25"),
            DashboardCard(icon: Icons.star, title: "Avg. Rating", value: "4.6"),
            DashboardCard(icon: Icons.people, title: "Customers", value: "340"),
            DashboardCard(icon: Icons.trending_up, title: "Revenue", value: "₹12,400"),
          ],
        ),
      ),
    );
  }
}
