import 'package:flutter/material.dart';
import 'dart:math';

import 'package:google_fonts/google_fonts.dart';

class ModernLoadingScreen extends StatefulWidget {
  const ModernLoadingScreen({
    super.key,
    this.message = "Finding the healthiest bite just for you...",
  });

  final String message;

  @override
  State<ModernLoadingScreen> createState() => _ModernLoadingScreenState();
}

class _ModernLoadingScreenState extends State<ModernLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
  }

  Widget _buildOrbitingImage(String path, double angle, double radius) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final rotationAngle = _controller.value * 2 * pi + angle;
        final dx = radius * cos(rotationAngle);
        final dy = radius * sin(rotationAngle);
        return Transform.translate(
          offset: Offset(dx, dy),
          child: Image.asset(path, height: 40),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double radius = 80;

    return Scaffold(
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // 6 evenly spaced food images (every 60°)
                _buildOrbitingImage('assets/foods/orange.png', 0 * pi / 3, radius),
                _buildOrbitingImage('assets/foods/cabbage.png', 1 * pi / 3, radius),
                _buildOrbitingImage('assets/foods/bananas.png', 2 * pi / 3, radius),
                _buildOrbitingImage('assets/foods/strawberry.png', 3 * pi / 3, radius),
                _buildOrbitingImage('assets/foods/carrot.png', 4 * pi / 3, radius),
                _buildOrbitingImage('assets/foods/apple.png', 5 * pi / 3, radius),
              ],
            ),
            const SizedBox(height: 120),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.brown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
