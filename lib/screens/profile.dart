import 'package:flutter/material.dart';
import 'mock_data.dart';
import 'theme_data.dart';

class ProfilePage extends StatelessWidget {
  final User currentUser;

  const ProfilePage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeDatabase.getTheme(currentUser.currentThemeId);
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Profile Picture Placeholder
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.correct, // สีพื้นหลังรูปตามธีม (เขียว/ส้ม/นีออน)
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 25),
          Text(
            currentUser.username.toUpperCase(),
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textColor // สีชื่อ User ตามธีม
            ),
          ),
          const SizedBox(height: 25),
          // Stats Row
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn("Coins", "💰 ${currentUser.coins}", theme),
                Container(width: 1, height: 40, color: theme.textColor.withOpacity(0.2)), // เส้นคั่น
                _buildStatColumn("Words", "📖 ${currentUser.wordsFound}", theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, GameTheme theme) {
    return Column(
      children: [
        Text(
            value,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textColor // สีตัวเลข
            )
        ),
        const SizedBox(height: 5),
        Text(
            label,
            style: TextStyle(
                color: theme.textColor.withOpacity(0.6), // สีคำบรรยาย (จางๆ)
                fontWeight: FontWeight.w500
            )
        ),
      ],
    );
  }
}