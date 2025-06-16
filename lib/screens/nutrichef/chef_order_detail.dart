import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChefOrderDetailScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  final String orderType;

  const ChefOrderDetailScreen({
    super.key,
    required this.order,
    required this.orderType,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'ready':
        return Colors.green;
      case 'accepted':
        return Colors.blue;
      case 'assigned':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'ready':
        return Icons.kitchen;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'assigned':
        return Icons.delivery_dining;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${order['id']}'),
        backgroundColor: Colors.orange,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      'Order Details',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                        context, Icons.receipt, 'Order ID', order['id']),
                    _buildInfoRow(
                        context, Icons.access_time, 'Time', order['time']),
                    if (orderType == 'pending')
                      _buildInfoRow(
                          context, Icons.list_alt, 'Items', order['items']),
                    if (orderType == 'ready')
                      _buildInfoRow(
                          context, Icons.person, 'Customer', order['customer']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons based on order type
            if (orderType == 'pending')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement accept order functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Order ${order['id']} Accepted!')),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Accept Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (orderType == 'pending')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement mark as ready functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Order ${order['id']} Marked as Ready!')),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.kitchen),
                  label: const Text('Mark as Ready'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (orderType == 'ready')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement assign to delivery functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Assigning Order ${order['id']} to Delivery...')),
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.delivery_dining),
                  label: const Text('Assign to Delivery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
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
                this._getStatusIcon(step['status']),
                color: isCurrent
                    ? this._getStatusColor(step['status'])
                    : Colors.grey[400],
                size: 24,
              ),
              if (step['status'] != order['timeline'].last['status'])
                Container(
                  width: 2,
                  height: 40,
                  color: isCurrent
                      ? this._getStatusColor(step['status'])
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
