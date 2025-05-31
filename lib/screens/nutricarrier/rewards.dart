import 'package:flutter/material.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Rewards")),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: const [
          RewardBadge(title: "5 Deliveries", icon: Icons.emoji_events, earned: true),
          RewardBadge(title: "Fast Mover", icon: Icons.flash_on, earned: false),
          RewardBadge(title: "Weekly Streak", icon: Icons.local_fire_department, earned: true),
        ],
      ),
    );
  }
}

class RewardBadge extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool earned;

  const RewardBadge({
    super.key,
    required this.title,
    required this.icon,
    required this.earned,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: earned ? Colors.teal : Colors.grey.shade300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
