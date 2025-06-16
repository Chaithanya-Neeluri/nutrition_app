import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  // Dummy data for FAQs
  final List<Map<String, dynamic>> _faqs = const [
    {
      'question': 'How do I update my delivery status?',
      'answer':
          'You can update your delivery status by tapping on the order card and using the "Update Order Status" button. Make sure to update the status accurately to maintain good service quality.',
    },
    {
      'question': 'What should I do if I can\'t find the delivery address?',
      'answer':
          'If you\'re having trouble finding the delivery address, you can use the in-app navigation feature. If the issue persists, contact the customer through the app or reach out to our support team.',
    },
    {
      'question': 'How are my earnings calculated?',
      'answer':
          'Your earnings are calculated based on the number of deliveries, distance traveled, and any additional bonuses or tips. You can view your detailed earnings breakdown in the profile section.',
    },
    {
      'question': 'What should I do in case of an emergency?',
      'answer':
          'In case of an emergency, immediately contact our 24/7 support team through the emergency button in the app. Your safety is our top priority.',
    },
  ];

  // Dummy data for support contacts
  final List<Map<String, dynamic>> _supportContacts = const [
    {
      'title': 'Emergency Support',
      'number': '1800-123-4567',
      'icon': Icons.emergency,
      'color': Colors.red,
    },
    {
      'title': 'Customer Service',
      'number': '1800-765-4321',
      'icon': Icons.support_agent,
      'color': Colors.blue,
    },
    {
      'title': 'Technical Support',
      'number': '1800-987-6543',
      'icon': Icons.phone_android,
      'color': Colors.green,
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
                        Icons.help_outline,
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Help & Support',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
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
                    'Support Contacts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._supportContacts
                      .map((contact) => _buildContactCard(contact)),
                  const SizedBox(height: 24),
                  const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._faqs.map((faq) => _buildFaqCard(faq)),
                  const SizedBox(height: 24),
                  _buildEmergencyButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(Map<String, dynamic> contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: contact['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            contact['icon'],
            color: contact['color'],
            size: 24,
          ),
        ),
        title: Text(
          contact['title'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          contact['number'],
          style: TextStyle(
            color: contact['color'],
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.phone),
          color: contact['color'],
          onPressed: () {
            // TODO: Implement phone call functionality
          },
        ),
      ),
    );
  }

  Widget _buildFaqCard(Map<String, dynamic> faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          faq['question'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              faq['answer'],
              style: const TextStyle(
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.emergency,
            color: Colors.red,
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            'Emergency Support',
            style: TextStyle(
              color: Colors.red,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Available 24/7 for urgent assistance',
            style: TextStyle(
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement emergency call functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.phone),
            label: const Text('Call Emergency Support'),
          ),
        ],
      ),
    );
  }
}
