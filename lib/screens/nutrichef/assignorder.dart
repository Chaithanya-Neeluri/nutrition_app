import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class AssignOrdersScreen extends StatelessWidget {
  const AssignOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assign Delivery")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('orders').where('status', isEqualTo: 'accepted').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data();
              return ListTile(
                title: Text("Order for ${order['customerName']}"),
                subtitle: Text("Select delivery person"),
                trailing: DropdownButton<String>(
                  items: ['Delivery1', 'Delivery2'].map((id) {
                    return DropdownMenuItem(value: id, child: Text(id));
                  }).toList(),
                  onChanged: (value) {
                    FirebaseFirestore.instance.collection('orders').doc(orders[index].id).update({
                      'deliveryPerson': value,
                      'status': 'assigned',
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
