
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Big, Bold Mascot/Logo
              Image.asset('assets/logo.png', height: 180),
              const SizedBox(height: 24),
              // Big Bold Typography
              const Text(
                'Quackle',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF58CC02), // Duolingo Green
                  letterSpacing: -1.5,
                ),
              ),
              const Text(
                'The fun way to learn!',
                style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              // GET STARTED BUTTON
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4, // Gives it that "thick" button look
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text('GET STARTED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
              const SizedBox(height: 12),
              // ALREADY HAVE ACCOUNT
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('I ALREADY HAVE AN ACCOUNT', style: TextStyle(color: Color(0xFF1CB0F6), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
