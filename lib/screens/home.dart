import 'package:flutter/material.dart';
import 'game_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using correctColor from game_screen.dart
            const Icon(Icons.grid_on_rounded, size: 80, color: correctColor),
            const SizedBox(height: 20),
            const Text(
              "WORDLE",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Get 6 chances to guess a 5-letter word.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 50),

            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // Navigate to the actual Game Grid
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WordleScreen()),
                  );
                },
                child: const Text(
                  "PLAY",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}