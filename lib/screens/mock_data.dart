/*
 * File: mock_data.dart
 * Description: Data model and simulated database for user management.
 */

import 'package:shared_preferences/shared_preferences.dart';

class User {
  final String username;
  final String password;
  int coins;
  int wordsFound;
  List<String> foundWordsList;
  String currentThemeId;
  List<String> ownedThemeIds;

  int gamesPlayed;
  int gamesWon;
  int currentStreak;
  int maxStreak;
  List<int> guessDistribution;
  bool isSoundEnabled;
  String avatarEmoji;
  List<String> ownedAvatars; // 🆕 tracks purchased avatars across restarts

  User({
    required this.username,
    required this.password,
    this.coins = 0,
    this.wordsFound = 0,
    List<String>? foundWordsList,
    this.currentThemeId = 'classic',
    List<String>? ownedThemeIds,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    List<int>? guessDistribution,
    this.isSoundEnabled = true,
    this.avatarEmoji = '🧑',
    List<String>? ownedAvatars,
  })  : foundWordsList = foundWordsList ?? [],
        ownedThemeIds = ownedThemeIds ?? ['classic'],
        guessDistribution = guessDistribution ?? [0, 0, 0, 0, 0, 0],
  // Free avatars (🧑 👧) are always owned by default
        ownedAvatars = ownedAvatars != null ? List<String>.from(ownedAvatars) : ['🧑', '👧'];

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${username}_password', password);
    await prefs.setInt('${username}_coins', coins);
    await prefs.setInt('${username}_words_count', wordsFound);
    await prefs.setStringList('${username}_found_list', foundWordsList);
    await prefs.setString('${username}_theme', currentThemeId);
    await prefs.setStringList('${username}_owned_themes', ownedThemeIds);

    await prefs.setInt('${username}_gamesPlayed', gamesPlayed);
    await prefs.setInt('${username}_gamesWon', gamesWon);
    await prefs.setInt('${username}_currentStreak', currentStreak);
    await prefs.setInt('${username}_maxStreak', maxStreak);
    await prefs.setString('${username}_guessDist', guessDistribution.join(','));
    await prefs.setBool('${username}_isSound', isSoundEnabled);
    await prefs.setString('${username}_avatar', avatarEmoji);
    await prefs.setStringList('${username}_owned_avatars', ownedAvatars); // 🆕

    print("""
✨ Saved data for $username:
💰 Coins: $coins
🏆 Words Found: $wordsFound
🎨 Current Theme: $currentThemeId
🛍️ Owned Themes: $ownedThemeIds
🖼️ Avatar: $avatarEmoji | Owned Avatars: $ownedAvatars
📝 Word List: $foundWordsList
📊 Played: $gamesPlayed | Won: $gamesWon | Streak: $currentStreak
    """);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    coins = prefs.getInt('${username}_coins') ?? coins;
    wordsFound = prefs.getInt('${username}_words_count') ?? wordsFound;
    foundWordsList = prefs.getStringList('${username}_found_list') ?? foundWordsList;
    currentThemeId = prefs.getString('${username}_theme') ?? currentThemeId;
    ownedThemeIds = prefs.getStringList('${username}_owned_themes') ?? ownedThemeIds;

    gamesPlayed = prefs.getInt('${username}_gamesPlayed') ?? gamesPlayed;
    gamesWon = prefs.getInt('${username}_gamesWon') ?? gamesWon;
    currentStreak = prefs.getInt('${username}_currentStreak') ?? currentStreak;
    maxStreak = prefs.getInt('${username}_maxStreak') ?? maxStreak;

    String? distStr = prefs.getString('${username}_guessDist');
    if (distStr != null && distStr.isNotEmpty) {
      guessDistribution = distStr.split(',').map((e) => int.parse(e)).toList();
    }

    isSoundEnabled = prefs.getBool('${username}_isSound') ?? isSoundEnabled;
    avatarEmoji = prefs.getString('${username}_avatar') ?? avatarEmoji;

    // 🆕 Load owned avatars; always ensure free avatars are included
    final savedAvatars = prefs.getStringList('${username}_owned_avatars');
    if (savedAvatars != null) {
      ownedAvatars = List<String>.from(savedAvatars);
      // Safety: make sure free avatars are never lost
      if (!ownedAvatars.contains('🧑')) ownedAvatars.add('🧑');
      if (!ownedAvatars.contains('👧')) ownedAvatars.add('👧');
    }

    print("""
✨ LOADED result for $username:
💰 Coins: $coins
🏆 Words Found: $wordsFound
🎨 Current Theme: $currentThemeId
🛍️ Owned Themes: $ownedThemeIds
🖼️ Avatar: $avatarEmoji | Owned Avatars: $ownedAvatars
📝 Word List: $foundWordsList
📊 Played: $gamesPlayed | Won: $gamesWon | Streak: $currentStreak
    """);
  }
}

class MockDatabase {
  static List<User> users = [
    // 1. ยูสเซอร์ a: เล่นมาสักพักแล้ว (ยศ Bookworm)
    User(
      username: 'a',
      password: 'a',
      coins: 350,
      wordsFound: 18,
      foundWordsList: ['HELLO', 'WORLD', 'APPLE', 'MANGO', 'TIGER', 'SMART', 'GHOST', 'PLANT', 'WATER', 'CHAIR', 'TABLE', 'BREAD', 'GRAPE', 'LEMON', 'MONEY', 'SUGAR', 'SMILE', 'SLEEP'],
      currentThemeId: 'pastel',
      ownedThemeIds: ['classic', 'pastel'],
      gamesPlayed: 20,
      gamesWon: 18,
      currentStreak: 5,
      maxStreak: 12,
      guessDistribution: [0, 2, 5, 6, 3, 2],
      avatarEmoji: '🐱',
      ownedAvatars: ['🧑', '👧', '🐱'], // 🆕 already bought 🐱
    ),

    // 2. ยูสเซอร์ b: เพิ่งเริ่มเล่น
    User(
      username: 'b',
      password: 'b',
      coins: 50,
      wordsFound: 5,
      foundWordsList: ['BLACK', 'WHITE', 'GREEN', 'BLUES', 'BROWN'],
      gamesPlayed: 10,
      gamesWon: 5,
      currentStreak: 1,
      maxStreak: 3,
      guessDistribution: [0, 0, 1, 2, 1, 1],
    ),

    // 3. ยูสเซอร์ c: มือใหม่แกะกล่อง
    User(username: 'c', password: 'c', coins: 0, wordsFound: 0),

    // 4. ยูสเซอร์ d: เซียนเกม Wordle (ยศ Word Master)
    User(
      username: 'd',
      password: 'd',
      coins: 1500,
      wordsFound: 75,
      gamesPlayed: 80,
      gamesWon: 75,
      currentStreak: 20,
      maxStreak: 35,
      guessDistribution: [5, 10, 30, 20, 5, 5],
      currentThemeId: 'dark',
      ownedThemeIds: ['classic', 'dark', 'neon'],
      avatarEmoji: '👑',
      ownedAvatars: ['🧑', '👧', '🐱', '🐶', '🤖', '👽', '👑'], // 🆕 bought everything
    ),
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