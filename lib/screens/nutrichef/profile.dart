import 'package:flutter/material.dart';
class RestaurantProfileScreen extends StatelessWidget {
  const RestaurantProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text("Restaurant Information", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(decoration: InputDecoration(labelText: 'Restaurant Name')),
          TextField(decoration: InputDecoration(labelText: 'Owner Name')),
          TextField(decoration: InputDecoration(labelText: 'Location')),
          TextField(decoration: InputDecoration(labelText: 'Contact Number')),
          ElevatedButton(
            onPressed: () {
              // Save to Firebase
            },
            child: const Text("Save Info"),
          ),
        ],
      ),
    );
  }
}
