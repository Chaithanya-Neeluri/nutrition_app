import 'package:flutter/material.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  // Dummy data for rewards
  final List<Map<String, dynamic>> _rewards = const [
    {
      'title': 'Early Bird Bonus',
      'description': 'Complete 5 deliveries before 9 AM',
      'points': 500,
      'progress': 0.6,
      'icon': Icons.wb_sunny,
    },
    {
      'title': 'Speed Master',
      'description': 'Maintain 4.5+ rating for 20 deliveries',
      'points': 1000,
      'progress': 0.8,
      'icon': Icons.speed,
    },
    {
      'title': 'Night Owl',
      'description': 'Complete 10 deliveries after 8 PM',
      'points': 750,
      'progress': 0.3,
      'icon': Icons.nightlight_round,
    },
  ];

  // Dummy data for achievements
  final List<Map<String, dynamic>> _achievements = const [
    {
      'title': 'First Delivery',
      'description': 'Completed your first delivery',
      'icon': Icons.emoji_events,
      'completed': true,
    },
    {
      'title': 'Perfect Week',
      'description': 'No late deliveries for 7 days',
      'icon': Icons.star,
      'completed': true,
    },
    {
      'title': 'Customer Favorite',
      'description': 'Received 10 5-star ratings',
      'icon': Icons.favorite,
      'completed': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue,
                      Colors.blue.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Your Rewards',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '2,250 Points',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Challenges',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._rewards.map((reward) => _buildRewardCard(reward)),
                  const SizedBox(height: 24),
                  const Text(
                    'Achievements',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._achievements
                      .map((achievement) => _buildAchievementCard(achievement)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(Map<String, dynamic> reward) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(reward['icon'], color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        reward['description'],
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${reward['points']} pts',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: reward['progress'],
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: achievement['completed']
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                achievement['icon'],
                color: achievement['completed'] ? Colors.blue : Colors.grey,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement['title'],
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: achievement['completed']
                          ? Colors.black
                          : Colors.grey[600],
                    ),
                  ),
                  Text(
                    achievement['description'],
                    style: TextStyle(
                      color: achievement['completed']
                          ? Colors.grey[600]
                          : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              achievement['completed']
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: achievement['completed'] ? Colors.blue : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
