import 'package:flutter/material.dart';
import 'mock_data.dart';

class ProfilePage extends StatelessWidget {
  final User currentUser;

  const ProfilePage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Profile Picture Placeholder
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF58CC02),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(
            currentUser.username.toUpperCase(),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 30),
          // Simple Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn("Coins", "💰 ${currentUser.coins}"),
              _buildStatColumn("Words", "📖 ${currentUser.wordsFound}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}