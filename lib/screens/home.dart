/*
 * File: home.dart
 * Description: The main dashboard screen displayed after successful login.
 *
 * Responsibilities:
 * - Displays current user information (Name, Coins, wordsFound)
 * - Provides navigation to the Game Screen
 * - Handles user logout functionality (clearing session and navigation)
 * - Refreshes user data when returning from gameplay
 *
 *
 * Author: Detnarin Karinchai
 * Course: Mobile Application Development Framework
 */
 
import 'package:flutter/material.dart';
import 'mock_data.dart'; 
import 'game_screen.dart';

class HomePage extends StatefulWidget {
  final User currentUser; // รับข้อมูล User

  const HomePage({super.key, required this.currentUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _handleLogout() {
    Navigator.pushReplacementNamed(context, '/login');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Welcome, ${widget.currentUser.username.toUpperCase()}"), // แสดงชื่อ
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          //  แสดงเหรียญ
          Center(
            child: Text(
              "💰 ${widget.currentUser.coins}",
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          
          //  ปุ่ม Log out
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Log Out',
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.grid_on_rounded, size: 80, color: Color(0xFF6AAA64)),
            const SizedBox(height: 20),
            const Text(
              "WORDLE",
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 4),
            ),
            const SizedBox(height: 10),
            Text(
              "Words Found: ${widget.currentUser.wordsFound}", // แสดงสถิติ
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () async {
                  // ส่ง User ไปเล่นเกม และรอผลลัพธ์กลับมาเพื่ออัปเดตหน้าจอ
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WordleScreen(currentUser: widget.currentUser),
                    ),
                  );
                  // เมื่อกลับมาจากเกม ให้รีเฟรชหน้าจอ (เพื่อให้เหรียญเพิ่ม)
                  setState(() {});
                },
                child: const Text("PLAY", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}