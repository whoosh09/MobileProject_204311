import 'package:flutter/material.dart';
import 'mock_data.dart';

class DictionaryPage extends StatelessWidget {
  final User currentUser;

  const DictionaryPage({super.key, required this.currentUser});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "DICTIONARY",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Displaying progress based on user data
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.book, color: Colors.blue),
                  const SizedBox(width: 10),
                  Text(
                    "You have unlocked ${currentUser.wordsFound} words!",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  "List of words will appear here as you find them.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}