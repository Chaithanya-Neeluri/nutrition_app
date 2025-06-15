import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I track my meals?',
      'answer':
          'You can track your meals by going to the "Track" tab and selecting "Add Meal". Choose the meal type, enter the food items, and save your entry.',
    },
    {
      'question': 'How do I update my profile information?',
      'answer':
          'Navigate to the "Profile" tab and tap the "Edit" button. You can update your personal information, health metrics, and preferences.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help & Support',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [
                    Theme.of(context).primaryColor.withOpacity(0.2),
                    Theme.of(context).scaffoldBackgroundColor,
                  ]
                : [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Colors.white,
                  ],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            _buildSearchBar(isDarkMode),
            SizedBox(height: 24),
            _buildSection(
              'Frequently Asked Questions',
              _buildFAQs(isDarkMode),
              isDarkMode,
            ),
            SizedBox(height: 24),
            _buildSection(
              'Contact Us',
              _buildContactOptions(context, isDarkMode),
              isDarkMode,
            ),
            SizedBox(height: 24),
            _buildSection(
              'Support Resources',
              _buildSupportResources(context, isDarkMode),
              isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for help...',
          prefixIcon: Icon(
            Icons.search,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  List<Widget> _buildFAQs(bool isDarkMode) {
    return _faqs.map((faq) {
      return ExpansionTile(
        title: Text(
          faq['question']!,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              faq['answer']!,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black54,
                height: 1.5,
              ),
            ),
          ),
        ],
      );
    }).toList();
  }

  List<Widget> _buildContactOptions(BuildContext context, bool isDarkMode) {
    return [
      ListTile(
        leading: Icon(
          Icons.email_outlined,
          color: isDarkMode ? Colors.white70 : Colors.black87,
        ),
        title: Text(
          'Email Support',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'support@nutrimate.com',
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
        ),
        onTap: () => _launchEmail('support@nutrimate.com'),
      ),
      ListTile(
        leading: Icon(
          Icons.phone_outlined,
          color: isDarkMode ? Colors.white70 : Colors.black87,
        ),
        title: Text(
          'Call Us',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '+1 (555) 123-4567',
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
        ),
        onTap: () => _launchPhone('+15551234567'),
      ),
      ListTile(
        leading: Icon(
          Icons.chat_outlined,
          color: isDarkMode ? Colors.white70 : Colors.black87,
        ),
        title: Text(
          'Live Chat',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'Available 24/7',
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
        ),
        onTap: () {
          // Implement live chat functionality
        },
      ),
    ];
  }

  List<Widget> _buildSupportResources(BuildContext context, bool isDarkMode) {
    return [
      ListTile(
        leading: Icon(
          Icons.book_outlined,
          color: isDarkMode ? Colors.white70 : Colors.black87,
        ),
        title: Text(
          'User Guide',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDarkMode ? Colors.white70 : Colors.black54,
        ),
        onTap: () {
          // Navigate to user guide
        },
      ),
      ListTile(
        leading: Icon(
          Icons.video_library_outlined,
          color: isDarkMode ? Colors.white70 : Colors.black87,
        ),
        title: Text(
          'Video Tutorials',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDarkMode ? Colors.white70 : Colors.black54,
        ),
        onTap: () {
          // Navigate to video tutorials
        },
      ),
      ListTile(
        leading: Icon(
          Icons.forum_outlined,
          color: isDarkMode ? Colors.white70 : Colors.black87,
        ),
        title: Text(
          'Community Forum',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDarkMode ? Colors.white70 : Colors.black54,
        ),
        onTap: () {
          // Navigate to community forum
        },
      ),
    ];
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneLaunchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunch(phoneLaunchUri.toString())) {
      await launch(phoneLaunchUri.toString());
    }
  }
}
