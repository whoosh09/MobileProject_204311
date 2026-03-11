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
  bool isVibrationEnabled; // สั่น
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
    this.isVibrationEnabled = true,
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
    await prefs.setBool('${username}_isVibrate', isVibrationEnabled);
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

    isSoundEnabled = prefs.getBool('${username}_isSound') ?? true;
    isVibrationEnabled = prefs.getBool('${username}_isVibrate') ?? true;
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
    // 👑 1. User: master (สายโชว์ของ - ปลดล็อคครบทุกอย่าง ยศ Legend)
    // เอาไว้โชว์: กราฟสถิติสวยๆ, ของที่ซื้อครบแล้ว, ยศสูงสุด
    User(
      username: 'a',
      password: 'a',
      coins: 9999,
      wordsFound: 125, // ยศ 👑 Legend (100+)
      foundWordsList: [
        'APPLE', 'MANGO', 'TIGER', 'SMART', 'GHOST', 'PLANT', 'WATER', 'CHAIR',
        'TABLE', 'BREAD', 'GRAPE', 'LEMON', 'MONEY', 'SUGAR', 'SMILE', 'SLEEP',
        'BRAIN', 'HEART', 'HOUSE', 'TRAIN', 'LIGHT', 'NIGHT', 'DREAM', 'MAGIC'
      ],
      currentThemeId: 'neon',
      ownedThemeIds: ['classic', 'pastel', 'dark', 'neon'], // มีทุกธีม
      gamesPlayed: 150,
      gamesWon: 125,
      currentStreak: 42,
      maxStreak: 55,
      guessDistribution: [5, 15, 45, 30, 20, 10], // กราฟแบบโค้งระฆังคว่ำสวยๆ
      avatarEmoji: '🦄',
      ownedAvatars: ['🧑', '👧', '🐱', '🐶', '🤖', '👽', '👑', '🦄'], // มีทุกอวาตาร์
      isSoundEnabled: true,
      isVibrationEnabled: true,
    ),

    // 🎯 2. User: demo (สายจัดฉาก - รอโชว์ฟีเจอร์ Flashcard ให้อาจารย์ดู)
    // เอาไว้โชว์: เล่นชนะ 1 ตา แล้วมันจะครบ 15 คำพอดี เพื่อโชว์ Popup Unlocked Flashcard!
    User(
      username: 'b',
      password: 'b',
      coins: 140,
      wordsFound: 14, // ขาดอีกแค่ 1 คำจะครบ 15 (เพื่อปลดล็อค Flashcard)
      foundWordsList: [
        'BLACK', 'WHITE', 'GREEN', 'BLUES', 'BROWN', 'CLEAN', 'DIRTY',
        'HAPPY', 'SADLY', 'QUICK', 'SLOWS', 'BRAVE', 'COWARD', 'PROUD'
      ],
      currentThemeId: 'pastel',
      ownedThemeIds: ['classic', 'pastel'],
      gamesPlayed: 18,
      gamesWon: 14,
      currentStreak: 3,
      maxStreak: 8,
      guessDistribution: [0, 1, 4, 5, 3, 1],
      avatarEmoji: '🐱',
      ownedAvatars: ['🧑', '👧', '🐱'],
    ),

    // 🛍️ 3. User: shop (สายเปย์ - เอาไว้โชว์ระบบร้านค้า)
    // เอาไว้โชว์: กดเข้า Avatar Shop แล้วกดซื้อของให้ดูว่าเงินลด และเปลี่ยนรูปได้
    User(
      username: 'c',
      password: 'c',
      coins: 1000, // เงินเยอะแต่ยังไม่ค่อยได้ซื้อ
      wordsFound: 35, // ยศ 🎓 Scholar
      foundWordsList: List.generate(35, (index) => 'WORD$index'), // mock คำศัพท์ง่ายๆ
      currentThemeId: 'classic',
      ownedThemeIds: ['classic'],
      gamesPlayed: 40,
      gamesWon: 35,
      currentStreak: 12,
      maxStreak: 15,
      guessDistribution: [1, 4, 10, 12, 5, 3],
      avatarEmoji: '🧑',
      ownedAvatars: ['🧑', '👧'], // มีแค่ของฟรีรอซื้อเพิ่ม
    ),

    // 🌱 4. User: new (สายเริ่มต้น - ผู้เล่นใหม่แกะกล่อง)
    // เอาไว้โชว์: หน้าตาแอปตอนเริ่มต้นเล่นครั้งแรก สถิติเป็น 0 หมด
    User(
      username: 'd',
      password: 'd',
      coins: 0,
      wordsFound: 0,
      foundWordsList: [],
      currentThemeId: 'classic',
      ownedThemeIds: ['classic'],
      gamesPlayed: 0,
      gamesWon: 0,
      currentStreak: 0,
      maxStreak: 0,
      guessDistribution: [0, 0, 0, 0, 0, 0],
      avatarEmoji: '🧑',
      ownedAvatars: ['🧑', '👧'],
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
