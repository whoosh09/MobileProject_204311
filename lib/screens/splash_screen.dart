import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Initialize the Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // Total duration for the pop and bounce
    );

    // 2. Define the Elastic/Bouncy curve
    _bounceAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut, // This provides the "springy" effect
    );

    // 3. Start the animation immediately
    _controller.forward();

    // 4. Handle Navigation
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/welcome');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Important: cleanup the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF58CC02),
      body: Center(
        child: ScaleTransition(
          scale: _bounceAnimation,
          child: const Text(
            "Quackle",
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -2.0,
            ),
          ),
        ),
      ),
    );
  }
}