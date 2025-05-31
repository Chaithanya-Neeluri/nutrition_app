import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutrition_app/screens/nutricarrier/order_details.dart';

class AssignedOrdersScreen extends StatelessWidget {
  const AssignedOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions:[
          IconButton(
            onPressed: (){
              FirebaseAuth.instance.signOut();
            },
            icon:Icon(Icons.exit_to_app),
          ),
        ],
        title: const Text("Assigned Deliveries")),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.all(12),
          child: ListTile(
            title: const Text("Order #12345"),
            subtitle: const Text("Restaurant: Green Spice\nDestination: John's House"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderDetailScreen()));
            },
          ),
        ),
      ),
    );
  }
}
