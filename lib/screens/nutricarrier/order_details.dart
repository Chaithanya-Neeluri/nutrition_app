import 'package:flutter/material.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Delivery Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Order Timeline", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildTimelineStep("Picked Up", true),
            _buildTimelineStep("On the Way", false),
            _buildTimelineStep("Delivered", false),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Launch Google Maps route
              },
              icon: const Icon(Icons.navigation),
              label: const Text("Open Route in Maps"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(String title, bool isCompleted) {
    return Row(
      children: [
        Icon(isCompleted ? Icons.check_circle : Icons.radio_button_unchecked, color: isCompleted ? Colors.green : Colors.grey),
        const SizedBox(width: 8),
        Text(title),
      ],
    );
  }
}
