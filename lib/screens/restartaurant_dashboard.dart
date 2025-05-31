import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrition_app/widgets/auth_checker.dart';

class RestaurantDashboard extends StatelessWidget {
  const RestaurantDashboard({super.key});

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        tileColor: color,
        leading: Icon(icon, size: 32, color: Colors.black87),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Restaurant Owner Dashboard", style: GoogleFonts.poppins()),
        backgroundColor: Colors.orange.withAlpha(120),
        actions: [
          IconButton(onPressed:(){
            FirebaseAuth.instance.signOut();
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>AuthChecker()));
          }, icon: Icon(Icons.exit_to_app))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTile(
              icon: Icons.fastfood,
              title: 'Manage Menu',
              subtitle: 'Add, update, or remove items',
              color: Colors.orange.shade200,
              onTap: () {
                // TODO: Navigate to Menu Management Screen
              },
            ),
            const SizedBox(height: 16),
            _buildTile(
              icon: Icons.receipt_long,
              title: 'View Orders',
              subtitle: 'See customer orders',
              color: Colors.green.shade200,
              onTap: () {
                // TODO: Navigate to Orders Screen
              },
            ),
            const SizedBox(height: 16),
            _buildTile(
              icon: Icons.analytics,
              title: 'Sales Analytics',
              subtitle: 'View your performance',
              color: Colors.purple.shade200,
              onTap: () {
                // TODO: Navigate to Analytics Screen
              },
            ),
          ],
        ),
      ),
    );
  }
}
