import 'package:flutter/material.dart';
import '../models/mock_data.dart';
import '../services/audio_helper.dart';
import '../theme/theme_data.dart';
import 'login.dart';
import '../components/custom_3d_buttton.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final User currentUser;
  final VoidCallback onProfileUpdate;

  const ProfilePage({
    super.key,
    required this.currentUser,
    required this.onProfileUpdate,
  });

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _barController;
  late Animation<double> _pulseAnim;
  late Animation<double> _barAnim;

  @override
  void initState() {
    super.initState();
    // แอนิเมชันหัวใจเต้นตรง Avatar
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // แอนิเมชันหลอด Progress
    _barController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _barAnim = CurvedAnimation(parent: _barController, curve: Curves.easeOutCubic);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _barController.forward();
    });

    // 🆕 ตรวจสอบการปลดล็อกฉายาใหม่ทันทีที่เข้าหน้า Profile
    _checkAndUnlockRanks();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _barController.dispose();
    super.dispose();
  }

  void _checkAndUnlockRanks() {
    // rank ทั้งหมดที่ควรได้ตาม wordsFound
    final allRanks = ["🌱 Novice", "📖 Bookworm", "🎓 Scholar", "🧙‍♂️ Master", "👑 Legend"];
    final thresholds = [0, 10, 30, 50, 100];

    bool changed = false;
    for (int i = 0; i < allRanks.length; i++) {
      if (widget.currentUser.wordsFound >= thresholds[i] &&
          !widget.currentUser.unlockedRanks.contains(allRanks[i])) {
        widget.currentUser.unlockedRanks.add(allRanks[i]);
        changed = true;
      }
    }

    if (changed) {
      Future.microtask(() {
        setState(() {});
        widget.currentUser.saveData();
      });
    }
  }

  // 🆕 หน้าต่างเลือกฉายา (แก้ไข Scope ให้อยู่นอก build)
  void _showRankPicker(GameTheme theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "SELECT YOUR TITLE",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: theme.textColor, letterSpacing: 1.2),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: widget.currentUser.unlockedRanks.map((title) {
                    bool isSelected = widget.currentUser.selectedRankTitle == title;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? theme.correct.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Text(title.split(' ')[0], style: const TextStyle(fontSize: 22)),
                        title: Text(
                          title.split(' ')[1],
                          style: TextStyle(color: theme.textColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                        ),
                        trailing: isSelected ? Icon(Icons.check_circle, color: theme.correct) : null,
                        onTap: () {
                          setState(() => widget.currentUser.selectedRankTitle = title);
                          widget.currentUser.saveData();
                          Navigator.pop(context);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Logic การคำนวณ Rank
  String getRankTitle(int words) {
    if (words < 10) return "🌱 Novice";
    if (words < 30) return "📖 Bookworm";
    if (words < 50) return "🎓 Scholar";
    if (words < 100) return "🧙‍♂️ Master";
    return "👑 Legend";
  }

  String getRankNext(int words) {
    if (words < 10) return "Bookworm";
    if (words < 30) return "Scholar";
    if (words < 50) return "Master";
    if (words < 100) return "Legend";
    return "MAX";
  }
  int getNextRankThreshold(int words) {
    if (words < 10) return 10;
    if (words < 30) return 30;
    if (words < 50) return 50;
    if (words < 100) return 100;
    return 100; // ตันที่ 100 คำ
  }

  double getProgressToNextRank(int words) {
    if (words < 10) return words / 10;
    if (words < 30) return (words - 10) / 20;
    if (words < 50) return (words - 30) / 20;
    if (words < 100) return (words - 50) / 50;
    return 1.0;
  }

  Color _rankColor(GameTheme theme) {
    final title = widget.currentUser.selectedRankTitle;
    if (title.contains("Novice")) return Colors.green.shade400;
    if (title.contains("Bookworm")) return Colors.blue.shade400;
    if (title.contains("Scholar")) return Colors.purple.shade400;
    if (title.contains("Master")) return Colors.orange.shade400;
    return Colors.amber.shade400; // Legend
  }

  // Settings Bottom Sheet
  void showSettings(GameTheme theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.textColor.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.settings_rounded, color: theme.correct),
                    const SizedBox(width: 8),
                    Text("SETTINGS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 1.5, color: theme.textColor)),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Custom3DButton(
                    text: widget.currentUser.isSoundEnabled ? "🔊 SOUND: ON" : "🔈 SOUND: OFF",
                    backgroundColor: widget.currentUser.isSoundEnabled ? theme.correct : Colors.grey.shade500,
                    shadowColor: widget.currentUser.isSoundEnabled ? Colors.green.shade700 : Colors.grey.shade700,
                    onPressed: () {
                      setState(() => widget.currentUser.isSoundEnabled = !widget.currentUser.isSoundEnabled);
                      setModalState(() {});
                      widget.currentUser.saveData();
                      AppFeedback.playClick(widget.currentUser);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Custom3DButton(
                    text: widget.currentUser.isVibrationEnabled ? "📳 VIBRATION: ON" : "📴 VIBRATION: OFF",
                    backgroundColor: widget.currentUser.isVibrationEnabled ? theme.correct : Colors.grey.shade500,
                    shadowColor: widget.currentUser.isVibrationEnabled ? Colors.green.shade700 : Colors.grey.shade700,
                    onPressed: () {
                      setState(() => widget.currentUser.isVibrationEnabled = !widget.currentUser.isVibrationEnabled);
                      setModalState(() {});
                      widget.currentUser.saveData();
                      AppFeedback.triggerHaptic(widget.currentUser);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Divider(color: theme.textColor.withOpacity(0.1)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Custom3DButton(
                    text: "LOGOUT",
                    backgroundColor: Colors.redAccent,
                    shadowColor: Colors.red.shade800,
                    onPressed: () {
                      AppFeedback.playClick(widget.currentUser);
                      Navigator.pop(context);
                      _showLogoutConfirmDialog(theme);
                    },
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _showLogoutConfirmDialog(GameTheme theme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Logout?", style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/huhquackle.png',
              height: 120,
              fit: BoxFit.contain,
            ),
            Text("Are you sure you want to sign out of your account?", style: TextStyle(color: theme.textColor.withOpacity(0.7))),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: Custom3DButton(
                      text: "LOGOUT",
                      backgroundColor: Colors.redAccent,
                      shadowColor: Colors.red.shade800,
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('loggedInUser');
                        if (!context.mounted) return;
                        Navigator.of(context).pushNamedAndRemoveUntil('/splash', (route) => false);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: Custom3DButton(
                      text: "CANCEL",
                      backgroundColor: Colors.grey.shade400,
                      shadowColor: Colors.grey.shade600,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarShop(GameTheme theme) {

 final avatars = [
      // 🦆 สายฟรีและราคาประหยัด (สัตว์คลาสสิก/สัตว์เลี้ยง)
      {'path': 'assets/emoji/Duck.png', 'price': 0},         // เป็ด (ธีมเกม ฟรี)
      {'path': 'assets/emoji/Chicken.png', 'price': 0},      // ไก่ (ฟรี)
      {'path': 'assets/emoji/Frog.png', 'price': 10},        // กบ
      {'path': 'assets/emoji/pig_face.png', 'price': 10},    // หมู

      // 🍁 สายธรรมชาติและของน่ารัก (Tier 1)
      {'path': 'assets/emoji/maple_leaf.png', 'price': 50},  // ใบเมเปิล
      {'path': 'assets/emoji/Bubbles.png', 'price': 50},     // ฟองสบู่
      {'path': 'assets/emoji/Penguin.png', 'price': 50},     // เพนกวิน
      {'path': 'assets/emoji/Panda.png', 'price': 50},       // แพนด้า
      {'path': 'assets/emoji/teddy_bear.png', 'price': 50},  // ตุ๊กตาหมี

      // 🦋 สายสวยงามและสัตว์หายาก (Tier 2)
      {'path': 'assets/emoji/Butterfly.png', 'price': 100},  // ผีเสื้อ
      {'path': 'assets/emoji/Jellyfish.png', 'price': 100},  // แมงกะพรุน
      {'path': 'assets/emoji/Peacock.png', 'price': 100},    // นกยูง
      {'path': 'assets/emoji/Whale.png', 'price': 100},      // วาฬ
      {'path': 'assets/emoji/Sauropod.png', 'price': 100},   // ไดโนเสาร์คอยาว

      // 🔥 สายเท่และแฟชั่น (Tier 3)
      {'path': 'assets/emoji/Alien.png', 'price': 200},      // เอเลี่ยน
      {'path': 'assets/emoji/t-rex.png', 'price': 200},      // ทีเร็กซ์
      {'path': 'assets/emoji/Fire.png', 'price': 200},       // ไฟ
      {'path': 'assets/emoji/video_game.png', 'price': 250}, // จอยเกม
      {'path': 'assets/emoji/Rainbow.png', 'price': 250},    // รุ้งกินน้ำ

      // 👑 สายเทพ ของแรร์ระดับตำนาน (Tier 4 - Max Level)
      {'path': 'assets/emoji/glowing_star.png', 'price': 500}, // ดาวเรืองแสง
      {'path': 'assets/emoji/Unicorn.png', 'price': 500},      // ยูนิคอร์น
      {'path': 'assets/emoji/Phoenix.png', 'price': 500},      // ฟีนิกซ์
      {'path': 'assets/emoji/trident_emblem.png', 'price': 500},// ตรีศูล
      {'path': 'assets/emoji/Crown.png', 'price': 500},        // มงกุฎ
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
            padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.textColor.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.storefront_rounded, color: theme.correct),
                    const SizedBox(width: 8),
                    Text("Avatar Shop", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textColor, fontFamily: 'monospace')),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.amber.shade600, Colors.orange.shade400]), borderRadius: BorderRadius.circular(20)),
                      child: Text("💰 ${widget.currentUser.coins}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Wrap(
                        spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
                        children: avatars.map((av) {
                          final path = av['path'] as String;
                          final price = av['price'] as int;
                          final bool isOwned = price == 0 || widget.currentUser.ownedAvatars.contains(path);
                          final bool isEquipped = widget.currentUser.avatarEmoji == path;

                          return GestureDetector(
                            onTap: () {
                              if (isOwned) {
                                setState(() => widget.currentUser.avatarEmoji = path);
                                setModalState(() {});
                                widget.currentUser.saveData();
                                widget.onProfileUpdate();
                              } else {
                                _showConfirmAvatarDialog(av, theme, setModalState);
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isEquipped ? theme.correct.withOpacity(0.15) : theme.textColor.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isEquipped ? theme.correct : theme.textColor.withOpacity(0.15), width: isEquipped ? 2.5 : 1),
                              ),
                              child: Column(
                                children: [
                                  Image.asset(path, width: 40, height: 40, fit: BoxFit.contain),
                                  const SizedBox(height: 6),
                                  isOwned
                                      ? Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: theme.correct.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Text(isEquipped ? "EQUIPPED" : "OWNED", style: TextStyle(fontSize: 10, color: theme.correct, fontWeight: FontWeight.bold)))
                                      : Text("💰 $price", style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _showConfirmAvatarDialog(Map<String, Object> av, GameTheme theme, StateSetter setModalState) {
    final int price = av['price'] as int;
    final String path = av['path'] as String; // 🆕
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Confirm Purchase", style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(path, width: 60, height: 60),
            const SizedBox(height: 16),
            Text("Buy this avatar for $price coins?", style: TextStyle(color: theme.textColor.withOpacity(0.8))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: theme.correct),
            onPressed: () {
              Navigator.pop(context);
              _processAvatarPurchase(path, price, setModalState);
            },
            child: const Text("Buy!", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

void _processAvatarPurchase(String path, int price, StateSetter setModalState) { // 🆕 รับ String path
    if (widget.currentUser.coins >= price) {
      AppFeedback.playCash(widget.currentUser);
      setState(() {
        widget.currentUser.coins -= price;
        widget.currentUser.ownedAvatars.add(path);
        widget.currentUser.avatarEmoji = path;
      });
      widget.currentUser.saveData();
      setModalState(() {});
      widget.onProfileUpdate();
    }
  }
  void _showEditUsernameDialog(GameTheme theme) {
    final controller = TextEditingController(text: widget.currentUser.username);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.edit_rounded, color: theme.correct, size: 20),
            const SizedBox(width: 8),
            Text("Edit Username", style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // แสดงราคา
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("💰", style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      "Cost: 100 coins",
                      style: TextStyle(fontSize: 12, color: theme.textColor.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold),
                maxLength: 12,
                decoration: InputDecoration(
                  hintText: "New username",
                  hintStyle: TextStyle(color: theme.textColor.withOpacity(0.3)),
                  counterStyle: TextStyle(color: theme.textColor.withOpacity(0.4)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.textColor.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.correct),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.redAccent),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.redAccent),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return "Please enter a username";
                  if (val.trim().length < 3) return "At least 3 characters";
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: TextStyle(color: theme.textColor.withOpacity(0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.currentUser.coins >= 100 ? theme.correct : Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (widget.currentUser.coins < 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Not enough coins! 💸"), backgroundColor: Colors.redAccent),
                );
                return;
              }
              if (formKey.currentState!.validate()) {
                setState(() {
                  widget.currentUser.username = controller.text.trim(); // ⚠️ ต้องเปลี่ยน username เป็น non-final ก่อน
                  widget.currentUser.coins -= 100;
                });
                widget.currentUser.saveData();
                widget.onProfileUpdate();
                Navigator.pop(context);
              }
            },
            child: const Text("Confirm  💰100", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeDatabase.getTheme(widget.currentUser.currentThemeId);
    final isDark = theme.brightness == Brightness.dark;
    final rankColor = _rankColor(theme);
    int winRate = widget.currentUser.gamesPlayed > 0 ? ((widget.currentUser.gamesWon / widget.currentUser.gamesPlayed) * 100).round() : 0;
    int maxCount = widget.currentUser.guessDistribution.reduce((a, b) => a > b ? a : b);
    if (maxCount == 0) maxCount = 1;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [rankColor.withOpacity(isDark ? 0.35 : 0.2), theme.backgroundColor])),
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 28),
          child: Column(
            children: [
              ScaleTransition(
                scale: _pulseAnim,
                child: GestureDetector(
                  onTap: () => _showAvatarShop(theme),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [rankColor.withOpacity(0.4), rankColor.withOpacity(0.05)]), border: Border.all(color: rankColor, width: 3), boxShadow: [BoxShadow(color: rankColor.withOpacity(0.5), blurRadius: 20)]),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0), // ปรับขนาดให้พอดีวงกลม
                            child: Image.asset(widget.currentUser.avatarEmoji, fit: BoxFit.contain),
                          ),
                        ),
                      ),
                      Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: theme.correct, shape: BoxShape.circle), child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.currentUser.username.toUpperCase(),
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: theme.textColor, fontFamily: 'monospace', letterSpacing: 2),
              ),
              const SizedBox(height: 10),
              // 🆕 ส่วนแสดงฉายาที่กดเลือกได้ (แก้ไข UI ใหม่)
              GestureDetector(
                onTap: () => _showRankPicker(theme),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(color: rankColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: rankColor.withOpacity(0.4))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.currentUser.selectedRankTitle, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: rankColor)),
                      const SizedBox(width: 4),
                      Icon(Icons.unfold_more_rounded, size: 14, color: rankColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.currentUser.wordsFound >= 100
                            ? "MAX RANK REACHED"
                            : "Progress to ${getRankNext(widget.currentUser.wordsFound)}",
                          style: TextStyle(fontSize: 11, color: theme.textColor.withOpacity(0.5), fontFamily: 'monospace'),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.currentUser.wordsFound >= 100
                          ? "${widget.currentUser.wordsFound} words"
                          : "${widget.currentUser.wordsFound} / ${getNextRankThreshold(widget.currentUser.wordsFound)}",
                        style: TextStyle(fontSize: 11, color: rankColor, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        Container(height: 12, color: theme.textColor.withOpacity(0.08)),
                        AnimatedBuilder(
                          animation: _barAnim,
                          builder: (_, __) => FractionallySizedBox(
                            widthFactor: getProgressToNextRank(widget.currentUser.wordsFound) * _barAnim.value,
                            child: Container(height: 12, decoration: BoxDecoration(gradient: LinearGradient(colors: [rankColor.withOpacity(0.7), rankColor]), boxShadow: [BoxShadow(color: rankColor.withOpacity(0.6), blurRadius: 6)])),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Statistics & Distribution
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel("📊  STATISTICS", theme),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _StatCard(label: "Played", value: "${widget.currentUser.gamesPlayed}", icon: Icons.sports_esports_rounded, color: Colors.blue.shade400, theme: theme)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(label: "Win Rate", value: "$winRate%", icon: Icons.emoji_events_rounded, color: Colors.amber.shade500, theme: theme)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // 🆕 เอา Emoji ออก และเอา isBig: true ออก เพื่อให้ทุกกล่องใช้มาตรฐานเดียวกัน
                  Expanded(child: _StatCard(label: "Streak", value: "${widget.currentUser.currentStreak}", icon: Icons.local_fire_department_rounded, color: Colors.orange.shade400, theme: theme)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(label: "Best", value: "${widget.currentUser.maxStreak}", icon: Icons.bolt_rounded, color: Colors.purple.shade400, theme: theme)),
                ],
              ),
            ],
          ),
        ),
        // Guess Distribution
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel("🎯  GUESS DISTRIBUTION", theme),
              const SizedBox(height: 14),
              ...List.generate(6, (index) {
                int count = widget.currentUser.guessDistribution[index];
                double widthFactor = count / maxCount;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(width: 28, height: 28, decoration: BoxDecoration(color: count > 0 ? theme.correct.withOpacity(0.15) : theme.textColor.withOpacity(0.06), borderRadius: BorderRadius.circular(6)), child: Center(child: Text("${index + 1}", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: count > 0 ? theme.correct : theme.textColor.withOpacity(0.3))))),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _barAnim,
                          builder: (_, __) => LayoutBuilder(builder: (ctx, constraints) {
                            double barWidth = count > 0 ? (widthFactor * _barAnim.value * constraints.maxWidth).clamp(36.0, constraints.maxWidth) : 36.0;
                            return Stack(
                              children: [
                                // 1. พื้นหลังหลอด
                                Container(height: 28, decoration: BoxDecoration(color: theme.textColor.withOpacity(0.05), borderRadius: BorderRadius.circular(8))),

                                // 2. หลอดสีตาม Theme (จะขยายตาม Animation)
                                if (count > 0)
                                  Container(
                                    width: barWidth,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [theme.correct.withOpacity(0.7), theme.correct]),
                                      borderRadius: BorderRadius.circular(8)
                                    )
                                  ),

                                // 3. เลเยอร์บนสุด: ขีดสีขาว + ตัวเลข
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // 🔹 สร้างขีดสีขาว (Notches) 🔹
                                        Row(
                                          children: List.generate(6, (i) => Container(
                                            margin: const EdgeInsets.only(right: 3),
                                            width: 4,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              // ทำให้ขีดสว่างตามจำนวนรอบที่ทาย
                                              color: i < (index + 1)
                                                  ? Colors.white.withOpacity(0.9)
                                                  : Colors.white.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                          )),
                                        ),

                                        // 🔹 ตัวเลขบอกจำนวน 🔹
                                        Text(
                                          "$count",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            // 🆕 ตัวเลขเปลี่ยนสีตามโหมด (Dark=ขาว, Light=ดำ/เทาเข้ม)
                                            color: count > 0
                                                ? (isDark ? Colors.white : Colors.black87)
                                                : theme.textColor.withOpacity(0.3),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _sectionLabel(String text, GameTheme theme) {
    return Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 1.5, color: theme.textColor.withOpacity(0.45)));
  }
}

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  final GameTheme theme;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.theme
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? color.withOpacity(0.08) : color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20), // 🆕 เพิ่มความมนให้ดูสมูทขึ้น
        border: Border.all(color: color.withOpacity(0.25))
      ),
      child: Row(
        children: [
          // 🆕 1. ปรับพื้นหลังไอคอนเป็นวงกลม จะดูเข้ากับ UI โดยรวมมากกว่า
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle
            ),
            child: Icon(icon, color: color, size: 24) // 🆕 ขยายไอคอนนิดนึงให้สมดุล
          ),
          const SizedBox(width: 12),
          // 🆕 2. จัดระเบียบตัวเลขและข้อความ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    // ✅ ฟิกซ์ขนาดฟอนต์ที่ 24 ให้ตัวเลขเท่ากันทุกการ์ด
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: theme.textColor, fontFamily: 'monospace')
                  ),
                ),
                const SizedBox(height: 2), // 🆕 เพิ่มช่องว่างระหว่างเลขกับ Text นิดนึง
                Text(
                  label.toUpperCase(), // 🆕 ดันเป็นตัวพิมพ์ใหญ่หมด
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0, // 🆕 ถ่างช่องไฟให้ดู Modern
                    color: theme.textColor.withOpacity(0.5),
                    fontFamily: 'monospace'
                  )
                )
              ]
            ),
          ),
        ],
      ),
    );
  }
}
