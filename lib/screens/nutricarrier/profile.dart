import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NutriCarrierProfile extends StatelessWidget {
  const NutriCarrierProfile({super.key});

  // Dummy data for profile
  final Map<String, dynamic> _profileData = const {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'phone': '+1 234 567 8900',
    'rating': 4.8,
    'totalDeliveries': 156,
    'earnings': 2345.67,
    'joinedDate': 'January 2024',
    'vehicleType': 'Motorcycle',
    'vehicleNumber': 'MH 01 AB 1234',
  };

  // Dummy data for statistics
  final List<Map<String, dynamic>> _statistics = const [
    {
      'title': 'Today\'s Deliveries',
      'value': '8',
      'icon': Icons.delivery_dining,
      'color': Colors.blue,
    },
    {
      'title': 'Weekly Earnings',
      'value': '\$345.50',
      'icon': Icons.attach_money,
      'color': Colors.green,
    },
    {
      'title': 'Rating',
      'value': '4.8',
      'icon': Icons.star,
      'color': Colors.amber,
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
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _profileData['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _profileData['rating'].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
                  _buildStatisticsGrid(),
                  const SizedBox(height: 24),
                  const Text(
                    'Profile Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProfileCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Vehicle Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildVehicleCard(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _statistics.length,
      itemBuilder: (context, index) {
        final stat = _statistics[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  stat['icon'],
                  color: stat['color'],
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  stat['value'],
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: stat['color'],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['title'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.email,
              title: 'Email',
              value: _profileData['email'],
            ),
            const Divider(),
            _buildInfoRow(
              icon: Icons.phone,
              title: 'Phone',
              value: _profileData['phone'],
            ),
            const Divider(),
            _buildInfoRow(
              icon: Icons.calendar_today,
              title: 'Joined',
              value: _profileData['joinedDate'],
            ),
            const Divider(),
            _buildInfoRow(
              icon: Icons.delivery_dining,
              title: 'Total Deliveries',
              value: _profileData['totalDeliveries'].toString(),
            ),
            const Divider(),
            _buildInfoRow(
              icon: Icons.attach_money,
              title: 'Total Earnings',
              value: '\$${_profileData['earnings']}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              icon: Icons.directions_bike,
              title: 'Vehicle Type',
              value: _profileData['vehicleType'],
            ),
            const Divider(),
            _buildInfoRow(
              icon: Icons.confirmation_number,
              title: 'Vehicle Number',
              value: _profileData['vehicleNumber'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
