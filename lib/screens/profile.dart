import 'package:flutter/material.dart';
import 'mock_data.dart';
import 'theme_data.dart';

class ProfilePage extends StatefulWidget {
  final User currentUser;
  final VoidCallback onProfileUpdate; // 🆕 รับฟังก์ชันเพื่อสั่งรีเฟรชหน้า Home

  const ProfilePage({
    super.key,
    required this.currentUser,
    required this.onProfileUpdate, // 🆕 ต้องใส่ค่านี้ตอนเรียกใช้
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ฟังก์ชันคำนวณยศ (Rank)
  String getRankTitle(int words) {
    if (words < 10) return "🌱 Novice";
    if (words < 30) return "📖 Bookworm";
    if (words < 50) return "🎓 Scholar";
    if (words < 100) return "🧙‍♂️ Word Master";
    return "👑 Legend";
  }

  // ฟังก์ชันคำนวณเป้าหมายยศถัดไป
  double getProgressToNextRank(int words) {
    if (words < 10) return words / 10;
    if (words < 30) return (words - 10) / 20;
    if (words < 50) return (words - 30) / 20;
    if (words < 100) return (words - 50) / 50;
    return 1.0;
  }

  // หน้าต่างเลือกซื้อ Avatar
  void _showAvatarShop(GameTheme theme) {
    final avatars = [
      {'emoji': '🧑', 'price': 0},
      {'emoji': '👧', 'price': 0},
      {'emoji': '🐱', 'price': 50},
      {'emoji': '🐶', 'price': 50},
      {'emoji': '🤖', 'price': 100},
      {'emoji': '👽', 'price': 100},
      {'emoji': '👑', 'price': 200},
      {'emoji': '🦄', 'price': 300},
    ];

    showModalBottomSheet(
        context: context,
        backgroundColor: theme.backgroundColor,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          // 🆕 ใช้ StatefulBuilder เพื่อให้ BottomSheet รีเฟรชตัวเองได้โดยไม่ต้องปิด
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Choose Avatar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textColor)),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 15,
                        runSpacing: 15,
                        children: avatars.map((av) {
                          bool isOwned = widget.currentUser.avatarEmoji == av['emoji'] || (av['price'] as int) == 0;
                          int price = av['price'] as int;

                          return GestureDetector(
                            onTap: () {
                              if (isOwned) {
                                // ถ้ามีอยู่แล้ว เปลี่ยนเลย
                                setState(() => widget.currentUser.avatarEmoji = av['emoji'] as String);
                                setModalState(() {}); // รีเฟรช BottomSheet
                                widget.currentUser.saveData();
                                widget.onProfileUpdate(); // รีเฟรชหน้า Home
                              } else {
                                // 🆕 ไม่ปิด BottomSheet แต่เรียกหน้าต่าง Confirm ซ้อนขึ้นมาเลย
                                // ส่ง setModalState เข้าไปด้วย เพื่อให้มันอัปเดตตอนซื้อเสร็จ
                                _showConfirmAvatarDialog(av, theme, setModalState);
                                widget.currentUser.saveData();
                                widget.onProfileUpdate(); // รีเฟร
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: theme.textColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: widget.currentUser.avatarEmoji == av['emoji'] ? theme.correct : Colors.transparent, width: 2)
                              ),
                              child: Column(
                                children: [
                                  Text(av['emoji'] as String, style: const TextStyle(fontSize: 35)),
                                  const SizedBox(height: 5),
                                  isOwned
                                      ? Text("OWNED", style: TextStyle(fontSize: 10, color: theme.correct, fontWeight: FontWeight.bold))
                                      : Text("💰 $price", style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold))
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                );
              }
          );
        }
    );
  }

  // --- 🆕 หน้าต่างยืนยันการซื้อรูปโปรไฟล์ ---
  void _showConfirmAvatarDialog(Map<String, Object> av, GameTheme theme, StateSetter setModalState) {
    int price = av['price'] as int;
    String emoji = av['emoji'] as String;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.shopping_bag_rounded, color: Colors.amber, size: 28),
            const SizedBox(width: 10),
            Text("Confirm Purchase", style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        content: Text(
          "Do you want to buy avatar '$emoji' for $price coins?",
          style: TextStyle(color: theme.textColor.withOpacity(0.8), fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // ปิดแค่หน้าต่าง Confirm (BottomSheet ยังอยู่)
            child: Text("Cancel", style: TextStyle(color: theme.textColor.withOpacity(0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.correct,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context); // ปิดแค่หน้าต่าง Confirm
              _processAvatarPurchase(emoji, price, setModalState); // ดำเนินการหักเงิน
            },
            child: const Text("Buy", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- 🆕 ฟังก์ชันดำเนินการหักเงินและรีเฟรช ---
  void _processAvatarPurchase(String emoji, int price, StateSetter setModalState) {
    if (widget.currentUser.coins >= price) {
      // 1. อัปเดตข้อมูลผู้ใช้
      setState(() {
        widget.currentUser.coins -= price;
        widget.currentUser.avatarEmoji = emoji;
      });
      widget.currentUser.saveData();

      // 2. สั่งรีเฟรช UI ทั้ง 2 ส่วน
      setModalState(() {}); // รีเฟรช BottomSheet (ให้ปุ่มเปลี่ยนเป็น OWNED)
      widget.onProfileUpdate(); // รีเฟรชหน้า Home (ให้เหรียญด้านบนลดลง)

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Avatar Unlocked! ✨"),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 1000),
            behavior: SnackBarBehavior.floating,
          )
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Not enough coins! 💰"),
            backgroundColor: Colors.redAccent,
            duration: Duration(milliseconds: 1000),
            behavior: SnackBarBehavior.floating,
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeDatabase.getTheme(widget.currentUser.currentThemeId);

    // คำนวณ Win Rate
    int winRate = widget.currentUser.gamesPlayed > 0
        ? ((widget.currentUser.gamesWon / widget.currentUser.gamesPlayed) * 100).round()
        : 0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // --- 1. Header (Avatar & Rank) ---
        Column(
          children: [
            GestureDetector(
              onTap: () => _showAvatarShop(theme),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.correct.withOpacity(0.2),
                    child: Text(widget.currentUser.avatarEmoji, style: const TextStyle(fontSize: 50)),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: theme.correct, shape: BoxShape.circle),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  )
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(widget.currentUser.username.toUpperCase(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textColor)),
            const SizedBox(height: 5),
            Text(getRankTitle(widget.currentUser.wordsFound), style: TextStyle(fontSize: 16, color: theme.present, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // EXP Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: getProgressToNextRank(widget.currentUser.wordsFound),
                minHeight: 10,
                backgroundColor: theme.textColor.withOpacity(0.1),
                color: theme.correct,
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        // --- 2. Detailed Stats ---
        Text("STATISTICS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textColor)),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatBox("Played", widget.currentUser.gamesPlayed.toString(), theme),
            _buildStatBox("Win %", "$winRate", theme),
            _buildStatBox("Current\nStreak", widget.currentUser.currentStreak.toString(), theme),
            _buildStatBox("Max\nStreak", widget.currentUser.maxStreak.toString(), theme),
          ],
        ),

        const SizedBox(height: 30),

        // --- 3. Guess Distribution (กราฟแท่ง) ---
        Text("GUESS DISTRIBUTION", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textColor)),
        const SizedBox(height: 10),
        Column(
          children: List.generate(6, (index) {
            int count = widget.currentUser.guessDistribution[index];
            int maxCount = widget.currentUser.guessDistribution.reduce((curr, next) => curr > next ? curr : next);
            if (maxCount == 0) maxCount = 1;

            double widthPercent = count / maxCount;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text("${index + 1}", style: TextStyle(color: theme.textColor, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: widthPercent > 0 ? widthPercent : 0.05,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: count > 0 ? theme.correct : theme.textColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4)
                          ),
                          child: Text(count.toString(), textAlign: TextAlign.right, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          }),
        ),

        const SizedBox(height: 30),

        // --- 4. Settings ---
        Text("SETTINGS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textColor)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: theme.textColor.withOpacity(0.1))
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: Text("Sound Effects", style: TextStyle(color: theme.textColor)),
                secondary: Icon(Icons.volume_up_rounded, color: theme.correct),
                activeColor: theme.correct,
                value: widget.currentUser.isSoundEnabled,
                onChanged: (bool value) {
                  setState(() => widget.currentUser.isSoundEnabled = value);
                  widget.currentUser.saveData();
                },
              ),
              Divider(height: 1, color: theme.textColor.withOpacity(0.1)),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              )
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, GameTheme theme) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textColor)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: theme.textColor.withOpacity(0.6))),
      ],
    );
  }
}