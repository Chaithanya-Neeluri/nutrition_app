import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutrition_app/screens/nutrichef/chef_order_detail.dart';

class NutriChefDashboard extends StatefulWidget {
  const NutriChefDashboard({super.key});

  @override
  State<NutriChefDashboard> createState() => _NutriChefDashboardState();
}

class _NutriChefDashboardState extends State<NutriChefDashboard> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? _restaurantData;

  // Dummy data for chef dashboard
  final Map<String, dynamic> _chefData = const {
    'name': 'Chef Anna',
    'restaurantName': 'Anna' 's Kitchen',
    'totalOrdersToday': 25,
    'revenueToday': 850.75,
    'avgOrderValue': 34.03,
    'pendingOrders': [
      {'id': '#1001', 'time': '10:30 AM', 'items': '2x Pasta, 1x Salad'},
      {'id': '#1002', 'time': '10:45 AM', 'items': '1x Pizza, 1x Drink'},
      {'id': '#1003', 'time': '11:00 AM', 'items': '3x Burgers'},
    ],
    'readyOrders': [
      {'id': '#0998', 'time': '10:15 AM', 'customer': 'John Doe'},
      {'id': '#0999', 'time': '10:20 AM', 'customer': 'Jane Smith'},
    ],
    'topSellingItems': [
      {'name': 'Chicken Biryani', 'sales': 120},
      {'name': 'Paneer Tikka', 'sales': 95},
      {'name': 'Veg Thali', 'sales': 80},
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadRestaurantData();
  }

  Future<void> _loadRestaurantData() async {
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _restaurantData = doc.data();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'NutriChef Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_outlined, color: Colors.white),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Text(
              'Welcome, ${_chefData['name']}!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
            ),
            Text(
              '${_chefData['restaurantName']}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            SizedBox(height: 24),

            // Today's Performance Metrics
            Text(
              'Today' 's Performance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.8, // Adjust for better spacing
              children: [
                _buildMetricCard(
                  context,
                  'Orders',
                  _chefData['totalOrdersToday'].toString(),
                  Icons.receipt_long,
                  Colors.blue,
                ),
                _buildMetricCard(
                  context,
                  'Revenue',
                  '\$${_chefData['revenueToday'].toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.green,
                ),
                _buildMetricCard(
                  context,
                  'Avg. Order',
                  '\$${_chefData['avgOrderValue'].toStringAsFixed(2)}',
                  Icons.shopping_cart,
                  Colors.purple,
                ),
              ],
            ),
            SizedBox(height: 24),

            // Orders to Prepare
            Text(
              'Orders to Prepare',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 16),
            _chefData['pendingOrders'].isEmpty
                ? Text('No pending orders.',
                    style: TextStyle(color: Colors.grey))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _chefData['pendingOrders'].length,
                    itemBuilder: (context, index) {
                      final order = _chefData['pendingOrders'][index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChefOrderDetailScreen(
                                  order: order,
                                  orderType: 'pending',
                                ),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: Icon(Icons.timer, color: Colors.orange),
                            title:
                                Text('Order ${order['id']} - ${order['time']}'),
                            subtitle: Text(order['items']),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      );
                    },
                  ),
            SizedBox(height: 24),

            // Ready for Pickup
            Text(
              'Ready for Pickup',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 16),
            _chefData['readyOrders'].isEmpty
                ? Text('No orders ready for pickup.',
                    style: TextStyle(color: Colors.grey))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _chefData['readyOrders'].length,
                    itemBuilder: (context, index) {
                      final order = _chefData['readyOrders'][index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChefOrderDetailScreen(
                                  order: order,
                                  orderType: 'ready',
                                ),
                              ),
                            );
                          },
                          child: ListTile(
                            leading:
                                Icon(Icons.check_circle, color: Colors.green),
                            title:
                                Text('Order ${order['id']} - ${order['time']}'),
                            subtitle: Text('Customer: ${order['customer']}'),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      );
                    },
                  ),
            SizedBox(height: 24),

            // Top Selling Items
            Text(
              'Top Selling Items',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _chefData['topSellingItems'].length,
              itemBuilder: (context, index) {
                final item = _chefData['topSellingItems'][index];
                return Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.star, color: Colors.amber),
                    title: Text(item['name']),
                    trailing: Text('${item['sales']} sales',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
            SizedBox(height: 24),

            // Quick Actions (Existing, but potentially updated styling)
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildActionCard(
                  'Menu Management',
                  Icons.restaurant_menu,
                  Colors.blue,
                  () {
                    // TODO: Navigate to menu management
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Navigating to Menu Management')),
                    );
                  },
                ),
                _buildActionCard(
                  'Orders',
                  Icons.shopping_cart,
                  Colors.green,
                  () {
                    // TODO: Navigate to orders
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Navigating to Orders')),
                    );
                  },
                ),
                _buildActionCard(
                  'Analytics',
                  Icons.analytics,
                  Colors.purple,
                  () {
                    // TODO: Navigate to analytics
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Navigating to Analytics')),
                    );
                  },
                ),
                _buildActionCard(
                  'Settings',
                  Icons.settings,
                  Colors.orange,
                  () {
                    // TODO: Navigate to settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Navigating to Settings')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement new order or menu item
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Adding New Item')),
          );
        },
        icon: Icon(Icons.add),
        label: Text('Add New Item'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.7),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
