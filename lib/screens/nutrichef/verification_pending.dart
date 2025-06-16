import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/auth_checker.dart';

class VerificationPending extends StatefulWidget {
  const VerificationPending({super.key});

  @override
  State<VerificationPending> createState() => _VerificationPendingState();
}

class _VerificationPendingState extends State<VerificationPending> {
  bool _isRefreshing = false;

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => AuthChecker()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshStatus() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      // Get latest user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        if (data['isVerified'] == true) {
          // If verified, navigate to dashboard
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => AuthChecker()),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final backgroundColor =
        isDarkMode ? Colors.grey[900] : Colors.orange.shade50;
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    // Define status colors
    final statusColors = {
      'submitted': Color(0xFF4CAF50), // Green
      'review': Color(0xFF2196F3), // Blue
      'notification': Color(0xFF9C27B0), // Purple
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Verification Status'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [Colors.grey[900]!, Colors.grey[800]!]
                : [Colors.orange.shade100, Colors.orange.shade300],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Chef Image
                  Hero(
                    tag: 'chef_verification',
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: statusColors['submitted']!.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/foods/chef.png',
                        height: 200,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        statusColors['submitted']!,
                        statusColors['review']!,
                      ],
                    ).createShader(bounds),
                    child: Text(
                      'Verification in Progress',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your restaurant documents are being reviewed by our administrators.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: textColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This process typically takes 24-48 hours.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: textColor.withOpacity(0.7),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Status Cards
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildStatusItem(
                          context,
                          Icons.upload_file,
                          'Documents Submitted',
                          'Your documents have been successfully uploaded',
                          statusColors['submitted']!,
                          isDarkMode,
                        ),
                        const Divider(height: 32),
                        _buildStatusItem(
                          context,
                          Icons.admin_panel_settings,
                          'Under Review',
                          'Our team is reviewing your documents',
                          statusColors['review']!,
                          isDarkMode,
                        ),
                        const Divider(height: 32),
                        _buildStatusItem(
                          context,
                          Icons.notifications_active,
                          'Notification',
                          'You will be notified once verified',
                          statusColors['notification']!,
                          isDarkMode,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Refresh Button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: ElevatedButton.icon(
                      onPressed: _isRefreshing ? null : _refreshStatus,
                      icon: _isRefreshing
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDarkMode
                                      ? Colors.white
                                      : statusColors['review']!,
                                ),
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label:
                          Text(_isRefreshing ? 'Checking...' : 'Check Status'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    bool isDarkMode,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
