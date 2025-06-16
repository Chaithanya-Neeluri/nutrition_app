import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutrition_app/screens/nutrimate/nutrimate_order_detail.dart';
import 'package:nutrition_app/screens/nutrimate/exercise_detail_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dummy data for past orders
  final List<Map<String, dynamic>> _pastOrders = const [
    {
      'id': 'NMT001',
      'date': '2024-03-10',
      'items': 'Chicken Salad, Quinoa Bowl',
      'total': 35.50,
      'status': 'Delivered',
      'deliveryPerson': 'John D.',
      'trackingId': 'TRK12345',
      'timeline': [
        {'status': 'Order Placed', 'time': '2024-03-10 10:00'},
        {'status': 'Food Preparation', 'time': '2024-03-10 10:15'},
        {'status': 'Out for Delivery', 'time': '2024-03-10 10:45'},
        {'status': 'Delivered', 'time': '2024-03-10 11:00'},
      ],
    },
    {
      'id': 'NMT002',
      'date': '2024-03-08',
      'items': 'Veggie Wrap, Fresh Juice',
      'total': 22.00,
      'status': 'Cancelled',
      'trackingId': 'TRK67890',
      'timeline': [
        {'status': 'Order Placed', 'time': '2024-03-08 14:00'},
        {'status': 'Order Cancelled by User', 'time': '2024-03-08 14:10'},
      ],
    },
    {
      'id': 'NMT003',
      'date': '2024-03-05',
      'items': 'Protein Smoothie, Energy Bar',
      'total': 15.75,
      'status': 'Delivered',
      'deliveryPerson': 'Jane S.',
      'trackingId': 'TRK11223',
      'timeline': [
        {'status': 'Order Placed', 'time': '2024-03-05 09:30'},
        {'status': 'Food Preparation', 'time': '2024-03-05 09:45'},
        {'status': 'Out for Delivery', 'time': '2024-03-05 10:15'},
        {'status': 'Delivered', 'time': '2024-03-05 10:30'},
      ],
    },
  ];

  // Dummy data for Yoga & Asanas
  final List<Map<String, dynamic>> _yogaAsanas = const [
    {
      'name': 'Downward-Facing Dog',
      'description': 'A foundational pose that lengthens the entire body.',
      'howToPerform':
          'Start on all fours, lift hips up and back, forming an inverted V-shape. Press hands and feet into the mat, keeping spine straight.',
      'benefits': [
        'Strengthens arms and legs',
        'Stretches shoulders, hamstrings, and calves',
        'Calms the brain and helps relieve stress',
      ],
    },
    {
      'name': 'Warrior II',
      'description': 'A standing pose that builds strength and stamina.',
      'howToPerform':
          'Step one foot back, pivot foot 90 degrees. Bend front knee, extend arms parallel to the floor, gaze over front hand.',
      'benefits': [
        'Strengthens legs and ankles',
        'Stretches groins, chest, and lungs',
        'Increases stamina',
      ],
    },
    {
      'name': 'Tree Pose',
      'description': 'A balancing pose that improves focus and stability.',
      'howToPerform':
          'Stand on one leg, place sole of other foot on inner thigh, calf, or ankle. Bring hands to prayer position at chest or overhead.',
      'benefits': [
        'Strengthens thighs, calves, ankles, and spine',
        'Stretches the groins and inner thighs',
        'Improves sense of balance',
      ],
    },
  ];

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
      default:
        return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Activity',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightGreen.withAlpha(120),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'My Orders'),
            Tab(text: 'Yoga & Asanas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My Orders Tab Content
          _buildMyOrdersTab(),
          // Yoga & Asanas Tab Content
          _buildYogaAsanasTab(),
        ],
      ),
    );
  }

  Widget _buildMyOrdersTab() {
    return _pastOrders.isEmpty
        ? const Center(
            child: Text('No past orders found.',
                style: TextStyle(color: Colors.grey)))
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _pastOrders.length,
            itemBuilder: (context, index) {
              final order = _pastOrders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NutrimateOrderDetailScreen(
                          order: order,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order ${order['id']}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order['status'])
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                order['status'].toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(order['status']),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Date: ${order['date']}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Items: ${order['items']}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Total: \$${order['total'].toStringAsFixed(2)}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  Widget _buildYogaAsanasTab() {
    return _yogaAsanas.isEmpty
        ? const Center(
            child: Text('No yoga or asanas found.',
                style: TextStyle(color: Colors.grey)))
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _yogaAsanas.length,
            itemBuilder: (context, index) {
              final exercise = _yogaAsanas[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ExerciseDetailScreen(
                          exercise: exercise,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise['name'],
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepOrangeAccent,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          exercise['description'],
                          style: TextStyle(color: Colors.grey[700]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            'Tap to learn more',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }
}
