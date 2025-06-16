import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NutrimateOrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const NutrimateOrderDetailScreen({
    super.key,
    required this.order,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      case 'Out for Delivery':
        return Colors.blue;
      case 'Food Preparation':
        return Colors.orange;
      case 'Order Placed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Delivered':
        return Icons.check_circle;
      case 'Cancelled':
        return Icons.cancel;
      case 'Out for Delivery':
        return Icons.delivery_dining;
      case 'Food Preparation':
        return Icons.kitchen;
      case 'Order Placed':
        return Icons.shopping_bag;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime orderDate = DateFormat('yyyy-MM-dd').parse(order['date']);

    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${order['id']}'),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                        context, Icons.receipt, 'Order ID', order['id']),
                    _buildInfoRow(
                        context, Icons.calendar_today, 'Date', order['date']),
                    _buildInfoRow(context, Icons.restaurant_menu, 'Items',
                        order['items']),
                    _buildInfoRow(context, Icons.attach_money, 'Total',
                        '\$${order['total'].toStringAsFixed(2)}'),
                    _buildInfoRow(context, Icons.info_outline, 'Current Status',
                        order['status'].toUpperCase()),
                    if (order['deliveryPerson'] != null)
                      _buildInfoRow(context, Icons.person, 'Delivery Person',
                          order['deliveryPerson']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Order Tracking Timeline
            Text(
              'Order Tracking',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: order['timeline']
                      .map<Widget>(
                        (step) => _buildTimelineStep(context, step),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Need Help / Contact Support
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Contacting support for this order...')),
                  );
                  // TODO: Implement actual contact support functionality
                },
                icon: const Icon(Icons.help_outline),
                label: const Text('Need Help with this Order?'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(BuildContext context, Map<String, dynamic> step) {
    final isCurrent = step['status'] == order['status'];
    final stepTime = DateTime.parse(step['time']);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(
                _getStatusIcon(step['status']),
                color: isCurrent
                    ? _getStatusColor(step['status'])
                    : Colors.grey[400],
                size: 24,
              ),
              if (step['status'] != order['timeline'].last['status'])
                Container(
                  width: 2,
                  height: 40,
                  color: isCurrent
                      ? _getStatusColor(step['status'])
                      : Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step['status'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCurrent
                            ? _getStatusColor(step['status'])
                            : Colors.black87,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy - hh:mm a').format(stepTime),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
