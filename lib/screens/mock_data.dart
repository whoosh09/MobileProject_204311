/*
 * File: mock_data.dart
 * Description: Data model and simulated database for user management.
 *
 * Responsibilities:
 * - Defines the User data model (username, password, coins, wordsFound, foundWordsList)
 * - Manages local data persistence using 'shared_preferences'
 * - Simulates a database for user authentication (Login)
 * - Handles saving and loading of user progress (coins and found words)
 *
 *
 * Author: Detnarin Karinchai
 * Course: Mobile Application Development Framework
 */
 
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String username;
  final String password;
  int coins;
  int wordsFound;
  List<String> foundWordsList;

  User({
    required this.username,
    required this.password,
    this.coins = 0,
    this.wordsFound = 0,
    List<String>? foundWordsList,
  }) : foundWordsList = foundWordsList ?? [];

  // --- (Save) ---
  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${username}_coins', coins);
    await prefs.setInt('${username}_words_count', wordsFound);
    await prefs.setStringList('${username}_found_list', foundWordsList);
    print("Saved data for $username: Coins=$coins, Words=$foundWordsList");
  }

  // --- (Load) ---
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    print("🔄 LOADING data for $username...");
    
    // ดึงค่าจากเครื่อง ถ้าไม่มีก็ใช้ค่าเดิม
    coins = prefs.getInt('${username}_coins') ?? coins;
    wordsFound = prefs.getInt('${username}_words_count') ?? wordsFound;
    foundWordsList = prefs.getStringList('${username}_found_list') ?? foundWordsList;
    
    print("✨ LOADED result: Coins=$coins, Words=$foundWordsList");
  }
}

class MockDatabase {
  static List<User> users = [
    User(username: 'a', password: 'a', coins: 10, wordsFound: 1, foundWordsList: ['HELLO']),
    User(username: 'b', password: 'b', coins: 0, wordsFound: 2),
    User(username: 'c', password: 'c', coins: 0, wordsFound: 0),
    User(username: 'd', password: 'd', coins: 0, wordsFound: 0),
  ];

  static Future<User?> login(String username, String password) async {
    try {
      User user = users.firstWhere(
        (u) => u.username == username && u.password == password,
      );
      await user.loadData(); 
      return user;
    } catch (e) {
      return null;
    }
  }
}