
import 'package:flutter/material.dart';
import '../components/custom_3d_buttton.dart';

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
              Image.asset('assets/images/fullbody_quackle.png', height:350),
              const SizedBox(height: 24),
              // Big Bold Typography

              const Text(
                'The fun way to learn!',
                style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              // GET STARTED BUTTON
              Custom3DButton(
                text: 'GET STARTED',
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                backgroundColor: const Color(0xFF58CC02),
                shadowColor: const Color(0xFF48A901), // A darker green
              ),
            ],
          ),
        ),
      ),
    );
  }
}

