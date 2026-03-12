import 'package:shared_preferences/shared_preferences.dart';

class User {
  String username;
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
  bool isVibrationEnabled;
  String avatarEmoji; // ตัวแปรชื่อเดิม แต่เราจะเก็บ path รูปแทน
  List<String> ownedAvatars;
  int hintCount;
  int cleanerCount;
  int extraRowCount;
  String selectedRankTitle;
  List<String> unlockedRanks;

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
    this.hintCount = 0,
    this.cleanerCount = 0,
    this.extraRowCount = 0,
    List<int>? guessDistribution,
    this.isSoundEnabled = true,
    this.isVibrationEnabled = true,
    this.avatarEmoji = 'assets/emoji/duck.png', // 🆕 เปลี่ยนค่าเริ่มต้น
    List<String>? ownedAvatars,
    this.selectedRankTitle = "🌱 Novice",
    List<String>? unlockedRanks,
  })  : foundWordsList = foundWordsList ?? [],
        ownedThemeIds = ownedThemeIds ?? ['classic'],
        guessDistribution = guessDistribution ?? [0, 0, 0, 0, 0, 0],
        // 🆕 ให้ทุกคนมีเป็ดกับไก่เป็นของฟรีแต่แรก
        ownedAvatars = ownedAvatars ?? ['assets/emoji/duck.png', 'assets/emoji/chicken.png'],
        unlockedRanks = unlockedRanks ?? ["🌱 Novice"];

  Future<void> saveData() async {
    print('💾 [QUACKLE LOG] เริ่มบันทึกข้อมูลของ User: $username ...');
    final prefs = await SharedPreferences.getInstance();

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
    await prefs.setStringList('${username}_owned_avatars', ownedAvatars);
    await prefs.setString('${username}_selectedRank', selectedRankTitle);
    await prefs.setStringList('${username}_unlockedRanks', unlockedRanks);

    print('✅ [QUACKLE LOG] บันทึกข้อมูลของ $username สำเร็จ! (Coins: $coins, Words: $wordsFound)');
  }

  Future<void> loadData() async {
    print('📂 [QUACKLE LOG] กำลังโหลดข้อมูลของ User: $username ...');
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
    selectedRankTitle = prefs.getString('${username}_selectedRank') ?? selectedRankTitle;

    final savedAvatars = prefs.getStringList('${username}_owned_avatars') ?? [];
    for (final a in savedAvatars) {
      if (!ownedAvatars.contains(a)) ownedAvatars.add(a);
    }

    final savedRanks = prefs.getStringList('${username}_unlockedRanks') ?? [];
    for (final r in savedRanks) {
      if (!unlockedRanks.contains(r)) unlockedRanks.add(r);
    }

    print('✅ [QUACKLE LOG] โหลดข้อมูล $username สำเร็จ! (Avatar: $avatarEmoji, Theme: $currentThemeId)');
  }
}

class MockDatabase {
  static List<User> users = [

    // ═══════════════════════════════════════════════════════
    // 💎  user: god / pass: god  —  "FULL DEMO USER"
    // ═══════════════════════════════════════════════════════
    User(
      username: 'god',
      password: 'god',
      coins: 1000000,
      wordsFound: 200,
      foundWordsList: [
        'ABATE','ABYSS','ADORN','AFIRE','ALERT','ANGER','ANNOY','ARENA','ARRAY','AUDIT',
        'AVOID','AWAKE','AWARD','BELCH','BETEL','BIDDY','BLITZ','BLUER','BOBBY','BOOBY',
        'BORNE','BRAKE','BRASH','BRIAR','BRINE','BROKE','BROOD','BRUSH','BUDDY','CAGEY',
        'CANAL','CHAIN','CHARD','CHILI','CHOKE','CHUCK','CHURN','CLAMP','CLANG','CLEAR',
        'CLOCK','CLOUT','CLOVE','CONCH','COVER','CRAMP','CRANK','CREED','CRUMP','DADDY',
        'DALLY','DEBUT','DEPOT','DODGY','DONUT','DRAPE','EASEL','EJECT','ELUDE','ENACT',
        'ENEMA','ENTRY','EQUIP','ERODE','ETHOS','FANCY','FIGHT','FLUTE','FOLLY','FROST',
        'FUNKY','GLADE','GLEAN','GLOAT','GLORY','GOING','GONER','GRANT','GRASP','GRASS',
        'GRAVY','GROAN','GROUT','GUILE','GULLY','GUMBO','GUSTY','HARRY','HARSH','HENCE',
        'HITCH','HONEY','HOVEL','HUMUS','HUNCH','HYENA','IDEAL','INDEX','KNAVE','KNEED',
        'KNOLL','KNOWN','KOALA','LANCE','LANKY','LARGE','LEACH','LIBEL','LIVER','LIVID',
        'LLAMA','MAMBO','MASON','MATCH','METER','MOULT','MUSHY','NAVEL','NERVE','OFFER',
        'OFTEN','OVINE','PATIO','PEACE','PERCH','PIGGY','POSER','POUND','PRISM','PROXY',
        'PRUDE','PUDGY','PURER','QUILL','RAINY','RAJAH','REARM','REBUT','RECUR','REIGN',
        'RETCH','RUDER','SALSA','SALTY','SATYR','SAVOY','SCOPE','SEIZE','SHELF','SHOCK',
        'SHONE','SHOOT','SHORN','SHORT','SINGE','SKULK','SLIDE','SLYLY','SOUND','SPEAK',
        'SPERM','SPICE','SPORT','SPRAY','STAID','STEAM','STEIN','STORE','STORK','STRUT',
        'SWORE','SWUNG','TAKER','TEMPO','THONG','THROW','TODDY','TORUS','TOXIN','TRICK',
        'TRUNK','UNTIL','URINE','USURP','VAPID','VENUE','VILLA','VIPER','VIXEN','VOCAL',
        'VODKA','WEAVE','WEDGE','WHIRL','WIELD','WINCH','WISER','WORRY','WRUNG','WRYLY',
      ],
      currentThemeId: 'legendary',
      ownedThemeIds: [
        'classic','pastel','dark','neon','midnight','sunset',
        'sakura','ice','ocean','candy','matrix','galaxy','lava','legendary',
      ],
      gamesPlayed: 250,
      gamesWon: 200,
      currentStreak: 99,
      maxStreak: 99,
      guessDistribution: [10, 30, 80, 50, 20, 10],
      avatarEmoji: 'assets/emoji/phoenix.png', // 🆕
      ownedAvatars: [
        'assets/emoji/duck.png', 'assets/emoji/chicken.png', 'assets/emoji/frog.png',
        'assets/emoji/pig_face.png', 'assets/emoji/maple_leaf.png', 'assets/emoji/bubbles.png',
        'assets/emoji/penguin.png', 'assets/emoji/panda.png', 'assets/emoji/teddy_bear.png',
        'assets/emoji/butterfly.png', 'assets/emoji/jellyfish.png', 'assets/emoji/peacock.png',
        'assets/emoji/whale.png', 'assets/emoji/sauropod.png', 'assets/emoji/alien.png',
        'assets/emoji/t-rex.png', 'assets/emoji/fire.png', 'assets/emoji/video_game.png',
        'assets/emoji/rainbow.png', 'assets/emoji/glowing_star.png', 'assets/emoji/unicorn.png',
        'assets/emoji/phoenix.png', 'assets/emoji/trident_emblem.png', 'assets/emoji/crown.png',
      ], // 🆕 มีครบทุกตัว
      hintCount: 99,
      cleanerCount: 99,
      extraRowCount: 99,
      isSoundEnabled: true,
      isVibrationEnabled: true,
      selectedRankTitle: "👑 Legend",
      unlockedRanks: [
        "🌱 Novice","📖 Bookworm","🎓 Scholar","🧙‍♂️ Word Master","👑 Legend",
      ],
    ),
    // ═══════════════════════════════════════════════════════
    // 1️⃣  user: 1 / pass: 1  —  "BRAND NEW PLAYER" (ผู้เล่นเริ่มต้น)
    // โชว์: หน้าตาแอปตอนเพิ่งโหลดเสร็จ สถิติเป็น 0 หมด กระเป๋าว่างเปล่า
    // ═══════════════════════════════════════════════════════
    User(
      username: 'newbie',
      password: '1',
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
      avatarEmoji: 'assets/emoji/chicken.png',
      ownedAvatars: ['assets/emoji/duck.png', 'assets/emoji/chicken.png'],
      hintCount: 0,
      cleanerCount: 0,
      extraRowCount: 0,
      selectedRankTitle: "🌱 Novice",
      unlockedRanks: ["🌱 Novice"],
    ),

    // ═══════════════════════════════════════════════════════
    // 2️⃣  user: 2 / pass: 2  —  "FLASHCARD TRIGGER" (อีก 1 คำเปิดโหมด)
    // โชว์: เล่นชนะตาเดียวปุ๊บ จะมีเด้งแจ้งเตือนปลดล็อกหน้า Flashcard ทันที
    // ═══════════════════════════════════════════════════════
    User(
      username: 'flash',
      password: '2',
      coins: 150,
      wordsFound: 14, // ขาดอีก 1 คำจะครบ 15
      foundWordsList: [
        'ABODE','BONGO','EGRET','FLUNK','GRAFT',
        'KRILL','LURCH','MELEE','REBEL','ROACH',
        'SHORE','SPIKY','TABBY','WOOER',
      ],
      currentThemeId: 'pastel',
      ownedThemeIds: ['classic','pastel'],
      gamesPlayed: 17,
      gamesWon: 14,
      currentStreak: 4,
      maxStreak: 7,
      guessDistribution: [0, 1, 4, 5, 3, 1],
      avatarEmoji: 'assets/emoji/duck.png',
      ownedAvatars: ['assets/emoji/duck.png', 'assets/emoji/chicken.png', 'assets/emoji/frog.png'],
      hintCount: 1,
      cleanerCount: 0,
      extraRowCount: 0,
      selectedRankTitle: "📖 Bookworm",
      unlockedRanks: ["🌱 Novice","📖 Bookworm"],
    ),

    // ═══════════════════════════════════════════════════════
    // 3️⃣  user: 3 / pass: 3  —  "ALMOST SCHOLAR" (อีก 1 คำเลื่อนยศ)
    // โชว์: เล่นชนะแล้วป้ายฉายาใหม่สีส้ม "🎓 Scholar" เด้งขึ้นมา
    // ═══════════════════════════════════════════════════════
    User(
      username: 'ranker',
      password: '3',
      coins: 500,
      wordsFound: 29, // ขาดอีก 1 คำจะครบ 30 เพื่อขึ้น Scholar
      foundWordsList: [
        'ALONE','BLANK','BONUS','BUTCH','CHOSE','CLASS','COURT','DOUGH','ETHER','EVICT',
        'FLANK','FLUTE','FOGGY','GNOME','HEAVY','IDLER','IMBUE','LLAMA','PENAL','SATIN',
        'SCOLD','SHOCK','SNARL','SOOTY','STAIN','SWASH','SWORN','VILLA','VOTER'
      ],
      currentThemeId: 'dark',
      ownedThemeIds: ['classic','dark'],
      gamesPlayed: 35,
      gamesWon: 29,
      currentStreak: 8,
      maxStreak: 12,
      guessDistribution: [1, 5, 10, 8, 3, 2],
      avatarEmoji: 'assets/emoji/penguin.png',
      ownedAvatars: ['assets/emoji/duck.png', 'assets/emoji/chicken.png', 'assets/emoji/penguin.png'],
      hintCount: 0,
      cleanerCount: 0,
      extraRowCount: 0,
      selectedRankTitle: "📖 Bookworm",
      unlockedRanks: ["🌱 Novice","📖 Bookworm"],
    ),

    // ═══════════════════════════════════════════════════════
    // 4️⃣  user: 4 / pass: 4  —  "RICH SHOPPER" (เงิน 1 ล้าน ยังไม่ซื้ออะไร)
    // โชว์: ระบบร้านค้า กดซื้อ Theme แพงๆ และ Avatar ได้รัวๆ ให้ดูระบบตัดเงิน
    // ═══════════════════════════════════════════════════════
    User(
      username: 'richboy',
      password: '4',
      coins: 1000000, // รวยมาก
      wordsFound: 20,
      foundWordsList: [
        'AGING','BAWDY','BLAME','BLURB','BLUSH','BOSOM','BRINK','BRISK','BUILT','CANNY',
        'CAROL','CROWN','DELVE','ELIDE','FLINT','GAUGE','HEADY','HINGE','HUTCH','KARMA'
      ],
      currentThemeId: 'classic',
      ownedThemeIds: ['classic'], // ยังไม่มีธีมอื่นเลย
      gamesPlayed: 25,
      gamesWon: 20,
      currentStreak: 5,
      maxStreak: 10,
      guessDistribution: [0, 2, 5, 8, 3, 2],
      avatarEmoji: 'assets/emoji/duck.png',
      ownedAvatars: ['assets/emoji/duck.png', 'assets/emoji/chicken.png'], // มีแค่ของแจกฟรี
      hintCount: 0,
      cleanerCount: 0,
      extraRowCount: 0,
      selectedRankTitle: "📖 Bookworm",
      unlockedRanks: ["🌱 Novice","📖 Bookworm"],
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
