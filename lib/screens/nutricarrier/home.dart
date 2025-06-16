import 'package:flutter/material.dart';
import 'package:nutrition_app/screens/nutricarrier/orders.dart';
import 'package:nutrition_app/screens/nutricarrier/rewards.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Dummy data for home screen
  final String _deliveryPersonName = 'John Doe';
  final double _todayEarnings = 125.50;
  final int _activeOrders = 3;
  final int _completedDeliveriesToday = 8;
  final double _averageRating = 4.8;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Text(
              'Welcome, $_deliveryPersonName!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
            ),
            const SizedBox(height: 24),

            // Availability Toggle
            _buildAvailabilityToggle(context),
            const SizedBox(height: 24),

            // Today's Summary
            Text(
              'Today' 's Summary',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5, // Adjust as needed
              children: [
                _buildSummaryCard(
                  context,
                  'Earnings',
                  '\$$_todayEarnings',
                  Icons.attach_money,
                  Colors.green,
                ),
                _buildSummaryCard(
                  context,
                  'Active Orders',
                  _activeOrders.toString(),
                  Icons.delivery_dining,
                  Colors.orange,
                ),
                _buildSummaryCard(
                  context,
                  'Deliveries',
                  _completedDeliveriesToday.toString(),
                  Icons.check_circle_outline,
                  Colors.blue,
                ),
                _buildSummaryCard(
                  context,
                  'Rating',
                  _averageRating.toString(),
                  Icons.star,
                  Colors.amber,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickActionCard(
                  context,
                  'View All Orders',
                  Icons.list_alt,
                  () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AssignedOrdersScreen()));
                  },
                ),
                _buildQuickActionCard(
                  context,
                  'View Rewards',
                  Icons.emoji_events,
                  () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RewardsScreen()));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityToggle(BuildContext context) {
    // This would ideally be a stateful widget or use a state management solution
    // For dummy purposes, we'll just show a static card
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are currently',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  'Online',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            Switch(
              value: true, // Dummy value: true for online
              onChanged: (bool newValue) {
                // TODO: Implement actual online/offline toggle logic
              },
              activeColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 40, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
