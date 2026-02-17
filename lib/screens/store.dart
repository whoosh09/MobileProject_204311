import 'package:flutter/material.dart';
import 'mock_data.dart'; // Ensure the path is correct to your User model

class StorePage extends StatelessWidget {
  final User currentUser;

  const StorePage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Item Shop", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        // Example Item
        ListTile(
          leading: const Icon(Icons.bolt, color: Colors.amber),
          title: const Text("Extra Hint"),
          subtitle: const Text("Cost: 50 coins"),
          trailing: ElevatedButton(
            onPressed: () { /* Logic for buying */ },
            child: const Text("BUY"),
          ),
        ),
      ],
    );
  }
}