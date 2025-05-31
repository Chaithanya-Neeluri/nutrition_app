import 'package:flutter/material.dart';

class NutriCarrierProfile extends StatelessWidget {
  const NutriCarrierProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, backgroundImage: AssetImage('assets/images/avatar.png')),
            const SizedBox(height: 16),
            TextFormField(decoration: const InputDecoration(labelText: 'Full Name')),
            TextFormField(decoration: const InputDecoration(labelText: 'Phone Number')),
            TextFormField(decoration: const InputDecoration(labelText: 'Vehicle Type')),
            TextFormField(decoration: const InputDecoration(labelText: 'Location/Zone')),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () {}, child: const Text("Update Profile")),
          ],
        ),
      ),
    );
  }
}
