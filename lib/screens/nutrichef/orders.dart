import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Incoming Orders")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('orders').where('status', isEqualTo: 'pending').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data();
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text("Order for ${order['customerName']}"),
                  subtitle: Text("Items: ${order['items'].length}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.check), onPressed: () {
                        FirebaseFirestore.instance.collection('orders').doc(orders[index].id).update({'status': 'accepted'});
                      }),
                      IconButton(icon: const Icon(Icons.close), onPressed: () {
                        FirebaseFirestore.instance.collection('orders').doc(orders[index].id).update({'status': 'rejected'});
                      }),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
