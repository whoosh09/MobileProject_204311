import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../models/mock_data.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
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
      duration: const Duration(milliseconds: 1200), // ความเร็วแอนิเมชันเด้งดึ๋ง
    );

    // 2. Define the Elastic/Bouncy curve
    _bounceAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    // 3. Start the animation immediately
    _controller.forward();

    // 4. เช็คประวัติการล็อกอิน (ระบบจำรหัสผ่านที่ทำไว้ล่าสุด)
    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('loggedInUser');

    User? loggedInUser;
    if (savedUsername != null) {
      try {
        loggedInUser = MockDatabase.users.firstWhere((u) => u.username == savedUsername);
        await loggedInUser.loadData();
      } catch (e) {
        loggedInUser = null;
      }
    }
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (loggedInUser != null) {
      // มีบัญชีค้างไว้ -> ไปหน้า Home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage(currentUser: loggedInUser!)),
      );
    } else {
      // ไม่มีบัญชี -> ไปหน้า Welcome
      Navigator.of(context).pushReplacementNamed('/welcome');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
