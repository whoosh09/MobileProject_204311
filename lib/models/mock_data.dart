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
  String avatarEmoji;
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
    this.avatarEmoji = '🧑',
    List<String>? ownedAvatars,
    this.selectedRankTitle = "🌱 Novice",
    List<String>? unlockedRanks,
  })  : foundWordsList = foundWordsList ?? [],
        ownedThemeIds = ownedThemeIds ?? ['classic'],
        guessDistribution = guessDistribution ?? [0, 0, 0, 0, 0, 0],
        ownedAvatars = ownedAvatars ?? ['🧑', '👧'],
        unlockedRanks = unlockedRanks ?? ["🌱 Novice"];

  Future<void> saveData() async {
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
    selectedRankTitle = prefs.getString('${username}_selectedRank') ?? selectedRankTitle;
    final savedAvatars = prefs.getStringList('${username}_owned_avatars') ?? [];
    for (final a in savedAvatars) {
      if (!ownedAvatars.contains(a)) ownedAvatars.add(a);
    }

    final savedRanks = prefs.getStringList('${username}_unlockedRanks') ?? [];
    for (final r in savedRanks) {
      if (!unlockedRanks.contains(r)) unlockedRanks.add(r);
    }
  }
}

class MockDatabase {
  static List<User> users = [

    // ═══════════════════════════════════════════════════════
    // 💎  user: god / pass: god  —  "FULL DEMO USER"
    // ครบทุกอย่าง: เงิน 1 ล้าน, ยศ Legend, ธีมครบ 14, avatar ครบ,
    // ฉายาครบ 5 ระดับ, power-up เยอะ, กราฟสวย, win rate สูง
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
      avatarEmoji: '🐦‍🔥',
      ownedAvatars: [
        '🧑','👧','🦆','🐔','🥷🏿','🐧','🍁','🦋','🐼',
        '🦖','👽','🪼','🦚','👑','🌈','🔱','🐦‍🔥','🦄','🌟','🫧','🎮',
      ],
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
    // 👑  user: a / pass: a  —  "THE LEGEND"
    // โชว์: ยศสูงสุด, กราฟสวย, ธีม Cyber Neon, avatar หายาก,
    //       ฉายาครบทุกระดับ, power-up ในกระเป๋าเยอะ
    // ═══════════════════════════════════════════════════════
    User(
      username: 'a',
      password: 'a',
      coins: 8888,
      wordsFound: 120,           // ยศ 👑 Legend (≥100)
      foundWordsList: [
        'ALONE','BLANK','BONUS','BUTCH','CHOSE','CLASS','COURT','DOUGH','ETHER','EVICT',
        'FLANK','FLUTE','FOGGY','GNOME','HEAVY','IDLER','IMBUE','LLAMA','PENAL','SATIN',
        'SCOLD','SHOCK','SNARL','SOOTY','STAIN','SWASH','SWORN','VILLA','VOTER','WHOLE',
      ],
      currentThemeId: 'neon',
      ownedThemeIds: [
        'classic','pastel','dark','neon','midnight','sunset',
        'sakura','ice','ocean','candy','matrix','galaxy','lava','legendary',
      ], // ครบทุกธีม → โชว์ว่า store ซื้อได้จริง
      gamesPlayed: 145,
      gamesWon: 120,
      currentStreak: 30,
      maxStreak: 52,
      guessDistribution: [8, 20, 48, 28, 16, 5], // โค้งระฆังคว่ำสวยๆ
      avatarEmoji: '👑',
      ownedAvatars: [
        '🧑','👧','🥷🏿','🐧','🦋','🐼','🦖','👽','🪼',
        '🦚','👑','🌈','🔱','🐦‍🔥','🦄','🌟','🫧','🎮',
      ], // ครบเกือบทุก avatar
      hintCount: 5,
      cleanerCount: 3,
      extraRowCount: 2,
      isSoundEnabled: true,
      isVibrationEnabled: true,
      selectedRankTitle: "👑 Legend",
      unlockedRanks: [
        "🌱 Novice","📖 Bookworm","🎓 Scholar","🧙‍♂️ Word Master","👑 Legend",
      ], // ปลดล็อกครบทุกฉายา → โชว์ rank picker ได้ครบ
    ),

    // ═══════════════════════════════════════════════════════
    // 🎯  user: b / pass: b  —  "FLASHCARD TRIGGER"
    // โชว์: เล่นชนะ 1 ตา → wordsFound ครบ 15 → popup ปลดล็อก Flashcard
    // ═══════════════════════════════════════════════════════
    User(
      username: 'b',
      password: 'b',
      coins: 150,
      wordsFound: 14,            // ขาดอีก 1 คำ → เล่นชนะ 1 ตา แล้ว popup จะขึ้น
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
      avatarEmoji: '🦆',
      ownedAvatars: ['🦆','🐔','🥷🏿'],
      hintCount: 1,
      cleanerCount: 0,
      extraRowCount: 0,
      selectedRankTitle: "📖 Bookworm",
      unlockedRanks: ["🌱 Novice","📖 Bookworm"],
    ),

    // ═══════════════════════════════════════════════════════
    // 🛍️  user: c / pass: c  —  "RICH SHOPPER"
    // โชว์: ระบบ Store — ซื้อ Theme / Avatar / Power-up ให้อาจารย์ดู
    //       เงินเยอะ แต่ยังไม่ได้ซื้ออะไร → เห็นปุ่ม "💰 Buy" ครบทุกไอเทม
    // ═══════════════════════════════════════════════════════
    User(
      username: 'c',
      password: 'c',
      coins: 9999,               // เงินเยอะพอซื้อได้ทุกอย่าง
      wordsFound: 35,            // ยศ 🎓 Scholar
      foundWordsList: [
        'AGING','BAWDY','BLAME','BLURB','BLUSH','BOSOM','BRINK','BRISK','BUILT','CANNY',
        'CAROL','CROWN','DELVE','ELIDE','FLINT','GAUGE','HEADY','HINGE','HUTCH','KARMA',
        'LABEL','MILKY','NASAL','NATAL','NEWLY','RUGBY','SCALP','SHEIK','SPOIL','STUNK',
        'TIGHT','TOTAL','TYING','VAGUE','WAGER',
      ],
      currentThemeId: 'classic',
      ownedThemeIds: ['classic'], // ยังไม่มีธีมอื่นเลย → เห็นราคาครบ
      gamesPlayed: 42,
      gamesWon: 35,
      currentStreak: 10,
      maxStreak: 14,
      guessDistribution: [1, 4, 10, 12, 5, 3],
      avatarEmoji: '🦆',
      ownedAvatars: ['🦆','🐔'], // มีแค่ของฟรี → เห็นราคา avatar ครบ
      hintCount: 0,
      cleanerCount: 0,
      extraRowCount: 0,
      selectedRankTitle: "🎓 Scholar",
      unlockedRanks: ["🌱 Novice","📖 Bookworm","🎓 Scholar"],
    ),

    // ═══════════════════════════════════════════════════════
    // 🌱  user: d / pass: d  —  "BRAND NEW PLAYER"
    // โชว์: หน้าตาแอปตอนเริ่มต้น สถิติเป็น 0 ทั้งหมด
    // ═══════════════════════════════════════════════════════
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
      avatarEmoji: '🥷🏿',
      ownedAvatars: ['🦆','🐔','🥷🏿'],
      hintCount: 0,
      cleanerCount: 0,
      extraRowCount: 0,
      selectedRankTitle: "🌱 Novice",
      unlockedRanks: ["🌱 Novice"],
    ),

    // ═══════════════════════════════════════════════════════
    // ⚡  user: e / pass: e  —  "POWER-UP DEMO"
    // โชว์: ระบบ Power-up ระหว่างเล่น — มี hint / cleaner / extra row ในกระเป๋าเยอะ
    //       เข้าเกมแล้วกดใช้ power-up ให้อาจารย์เห็น effect ได้เลย
    // ═══════════════════════════════════════════════════════
    User(
      username: 'e',
      password: 'e',
      coins: 500,
      wordsFound: 48,            // ยศ 🎓 Scholar (ใกล้ขึ้น Word Master)
      foundWordsList: [
        'ACORN','AFTER','BELLY','BLARE','BROAD','BULLY','CHOIR','CLIMB','CLUNG','COPSE',
        'CREME','DELTA','DEPTH','DIGIT','EJECT','ELOPE','ENTRY','GAMUT','GLAZE','GLYPH',
        'HUMOR','INCUR','KINKY','KNIFE','KNOLL','KRILL','LEDGE','LINEN','LOUSE','LUPUS',
        'MIDST','MOCHA','PANSY','PIANO','PLATE','QUEUE','SHORT','SLYLY','SPOON','TAKER',
        'TOKEN','TONGA','URBAN','VISIT','WARTY','WINCH','WITTY','ZEBRA',
      ],
      currentThemeId: 'dark',
      ownedThemeIds: ['classic','dark'],
      gamesPlayed: 55,
      gamesWon: 48,
      currentStreak: 8,
      maxStreak: 20,
      guessDistribution: [2, 8, 15, 14, 6, 3],
      avatarEmoji: '🐧',
      ownedAvatars: ['🦆','🐔','🥷🏿','🐧'],
      hintCount: 5,              // มี hint เยอะ → กดใช้ในเกมได้เลย
      cleanerCount: 5,           // มี cleaner เยอะ → โชว์ effect keyboard
      extraRowCount: 5,          // มี extra row → โชว์ว่าได้แถว 7
      isSoundEnabled: true,
      isVibrationEnabled: true,
      selectedRankTitle: "🎓 Scholar",
      unlockedRanks: ["🌱 Novice","📖 Bookworm","🎓 Scholar"],
    ),

    // ═══════════════════════════════════════════════════════
    // 🎨  user: f / pass: f  —  "THEME SHOWCASE"
    // โชว์: เปลี่ยนธีม dark/galaxy/lava ให้อาจารย์เห็น UI เปลี่ยนสีทั้งแอป
    //       มีธีมหลายตัวแล้ว แค่กด apply ดูได้เลย
    // ═══════════════════════════════════════════════════════
    User(
      username: 'f',
      password: 'f',
      coins: 2000,
      wordsFound: 65,            // ยศ 🧙‍♂️ Word Master
      foundWordsList: [
        'AGLOW','APPLE','ARDOR','ASHEN','BALMY','BATCH','BAYOU','BEGAN','BROOD','BUTCH',
        'CLUCK','COUCH','CRANK','CREME','DEBAR','DRUNK','DULLY','EERIE','EMPTY','EQUAL',
        'FICUS','FIGHT','FILLY','FORGO','FROZE','GLARE','GRIMY','GRIPE','GUILD','HEDGE',
        'IDIOM','IMAGE','KAYAK','LANCE','LOAMY','LOBBY','MOOSE','MOURN','OTTER','OWNER',
        'PAGAN','PLEAT','PLUMP','POOCH','PRIED','PUREE','QUEST','RELIC','SALLY','SALVO',
        'SCOLD','SEPIA','SERUM','SILLY','SKIER','SMOTE','SPURN','STOIC','TOXIC','VILLA',
        'WEEDY','WIDOW','WILLY','WRING','WROTE',
      ],
      currentThemeId: 'galaxy',
      ownedThemeIds: [
        'classic','pastel','dark','neon',
        'midnight','sunset','sakura','galaxy','lava',
      ], // ธีมหลากหลายทั้ง light/dark → สลับให้ดูได้
      gamesPlayed: 80,
      gamesWon: 65,
      currentStreak: 15,
      maxStreak: 30,
      guessDistribution: [3, 10, 25, 18, 7, 2],
      avatarEmoji: '🦚',
      ownedAvatars: ['🦆','🐔','🦋','🦚','🌈','🌟'],
      hintCount: 2,
      cleanerCount: 1,
      extraRowCount: 1,
      isSoundEnabled: true,
      isVibrationEnabled: false,
      selectedRankTitle: "🧙‍♂️ Word Master",
      unlockedRanks: [
        "🌱 Novice","📖 Bookworm","🎓 Scholar","🧙‍♂️ Word Master",
      ],
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
