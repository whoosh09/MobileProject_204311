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
import 'mock_data.dart'; //
import 'game_screen.dart'; //
import 'store.dart';
import 'dictionary.dart';
import 'profile.dart';

// HomePage (The Container): This is the "Main Frame.
class HomePage extends StatefulWidget {
  final User currentUser; // Required to track coins and stats

  const HomePage({super.key, required this.currentUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  void _refreshState() {
    setState(() {});
  }
  void _handleLogout() {
    Navigator.pushReplacementNamed(context, '/login'); //
  }

  // We use a getter to pass the currentUser down to the WordleMainBody
  List<Widget> get _pages => [
    WordleMainBody(currentUser: widget.currentUser, onRefresh: _refreshState),
    StorePage(currentUser: widget.currentUser),
    DictionaryPage(currentUser: widget.currentUser),
    ProfilePage(currentUser: widget.currentUser),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text("WELCOME, ${widget.currentUser.username.toUpperCase()}"),
        actions: [
          // Coins Display
          Center(
              child: Text(
                "💰 ${widget.currentUser.coins}", //
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  ),
              ),
          ),
          const SizedBox(width: 10),

          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container( // Bottom Navigation Bar Container
        decoration: BoxDecoration( //grey border at navbar
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 2),
          ),
        ),
        child: BottomNavigationBar( // Bottom Navigation Bar
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color(0xFF58CC02), // Duolingo Green
          unselectedItemColor: Colors.grey.shade400,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded, size: 32), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_rounded, size: 32), label: 'Store'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded, size: 32), label: 'Dictionary'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded, size: 32), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

//WordleMainBody (The Content)
class WordleMainBody extends StatelessWidget {
  final User currentUser; // Added to handle statistics
  final VoidCallback onRefresh;

  const WordleMainBody({super.key, required this.currentUser,required this.onRefresh,});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.grid_on_rounded, size: 80, color: Color(0xFF58CC02)),
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
          Text(
            "Words Found: ${currentUser.wordsFound}", // Statistics
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 50),

          // The Play Button with Duolingo-style rounded corners
          SizedBox(
            width: 250,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF58CC02),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                // Navigate and wait for refresh
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WordleScreen(currentUser: currentUser),
                  ),
                );
                // Trigger refresh if needed (Parent should handle state)
                onRefresh();
              },
              child: const Text(
                "PLAY",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
