import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutrition_app/screens/login_signup.dart';

class RoleBasedLandingScreen extends StatelessWidget {
  const RoleBasedLandingScreen({super.key});

  Widget _buildRoleButton(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 5,
          shadowColor: color.withOpacity(0.4),
        ),
        onPressed: onPressed,
      ),
    );
  }

  Widget _blurredCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFFFF8E1),
      body: Stack(
        children: [
          // Background decorative circles
          Positioned(
            top: -100,
            left: -80,
            child: _blurredCircle(200, Colors.orange.withOpacity(0.3)),
          ),
          Positioned(
            bottom: -120,
            right: -100,
            child: _blurredCircle(250, Colors.greenAccent.withOpacity(0.25)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    "Welcome to NutriNudge 🍽️",
                    textAlign: TextAlign.center,
                    style:Theme.of(context).textTheme.displayMedium,
                    // style: GoogleFonts.poppins(
                    //   fontSize: 28,
                    //   fontWeight: FontWeight.bold,
                    //   color: Colors.brown.shade700,
                    // ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Your personalized path to nutrition & wellness",
                    textAlign: TextAlign.center,
                     style:Theme.of(context).textTheme.headlineSmall,
                    // style: GoogleFonts.poppins(
                    //   fontSize: 16,
                    //   color: Colors.brown.shade500,
                    // ),
                  ),
                  const Spacer(),
                  _buildRoleButton(
                    context,
                    icon: Icons.person_outline,
                    label: "Login as NutriMate",
                    color: Colors.green.shade400,
                    onPressed: () {
                        Navigator.push(
                         context,
                         MaterialPageRoute(
                         builder: (context) => const LoginSignup(role: 'NutriMate'),
                        ),
                      );
                    
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildRoleButton(
                    context,
                    icon: Icons.restaurant_menu,
                    label: "Login as NutriChef",
                    color: Colors.orange.shade400,
                    onPressed: () {
                     Navigator.push(
                         context,
                         MaterialPageRoute(
                         builder: (context) => const LoginSignup(role: 'NutriChef'),
                        ),
                      );
                       
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildRoleButton(
                    context,
                    icon: Icons.delivery_dining,
                    label: "Login as 	NutriCarrier",
                    color: Colors.blue.shade400,
                    onPressed: () {
                         Navigator.push(
                         context,
                         MaterialPageRoute(
                         builder: (context) => const LoginSignup(role: 'NutriCarrier'),
                        ),
                      );
                      
                    },
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
