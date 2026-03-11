import 'package:flutter/material.dart';
import '../models/mock_data.dart';
import '../services/audio_helper.dart';
import '../theme/theme_data.dart';
import 'login.dart'; // Add this line! (adjust path if your login.dart is elsewhere)
import '../components/custom_3d_buttton.dart';

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
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    _barController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _barAnim = CurvedAnimation(parent: _barController, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _barController.forward();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _barController.dispose();
    super.dispose();
  }

  String getRankTitle(int words) {
    if (words < 10) return "🌱 Novice";
    if (words < 30) return "📖 Bookworm";
    if (words < 50) return "🎓 Scholar";
    if (words < 100) return "🧙‍♂️ Word Master";
    return "👑 Legend";
  }

  String getRankNext(int words) {
    if (words < 10) return "Bookworm";
    if (words < 30) return "Scholar";
    if (words < 50) return "Word Master";
    if (words < 100) return "Legend";
    return "MAX";
  }

  double getProgressToNextRank(int words) {
    if (words < 10) return words / 10;
    if (words < 30) return (words - 10) / 20;
    if (words < 50) return (words - 30) / 20;
    if (words < 100) return (words - 50) / 50;
    return 1.0;
  }

  Color _rankColor(GameTheme theme) {
    int w = widget.currentUser.wordsFound;
    if (w < 10) return Colors.green.shade400;
    if (w < 30) return Colors.blue.shade400;
    if (w < 50) return Colors.purple.shade400;
    if (w < 100) return Colors.orange.shade400;
    return Colors.amber.shade400;
  }

// ── Settings bottom sheet (called from AppBar in home.dart) ──────────────

  void showSettings(GameTheme theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.backgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: theme.textColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.settings_rounded, color: theme.correct),
                    const SizedBox(width: 8),
                    Text("SETTINGS",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            letterSpacing: 1.5,
                            color: theme.textColor)),
                  ],
                ),
                const SizedBox(height: 24),

                // --- 1. Sound toggle (3D Button) ---
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

                // --- 2. Vibration toggle (3D Button) ---
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

                // --- 3. LOGOUT BUTTON (3D Button) ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: Custom3DButton(
                    text: "LOGOUT",
                    backgroundColor: Colors.redAccent,
                    shadowColor: Colors.red.shade800,
                    onPressed: () {
                      AppFeedback.playClick(widget.currentUser);
                      Navigator.pop(context); // ปิด BottomSheet ก่อน
                      _showLogoutConfirmDialog(theme); // เปิดหน้าต่างยืนยัน
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

  // --- ฟังก์ชันช่วยสร้าง UI Toggle ---
  Widget _buildSettingToggle({
    required IconData icon,
    required String label,
    required bool value,
    required GameTheme theme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: value ? theme.correct.withOpacity(0.12) : theme.textColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: value ? theme.correct.withOpacity(0.4) : theme.textColor.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Icon(icon, color: value ? theme.correct : theme.textColor.withOpacity(0.4), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: theme.textColor)),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 48, height: 26,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: value ? theme.correct : theme.textColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(13),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(width: 20, height: 20, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              ),
            ),
          ],
        ),
      ),
    );
  }

// --- หน้าต่างยืนยันการ Logout ---
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
            Text(
              "Are you sure you want to sign out of your account?",
              style: TextStyle(color: theme.textColor.withOpacity(0.7)),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Custom3DButton(
                    text: "CANCEL",
                    backgroundColor: Colors.grey.shade400,
                    shadowColor: Colors.grey.shade600,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: Custom3DButton(
                    text: "LOGOUT",
                    backgroundColor: Colors.redAccent,
                    shadowColor: Colors.red.shade800,
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: const [], // ปล่อยว่างไว้เพราะเราย้ายปุ่มไปอยู่ใน content แทนเพื่อให้จัด Layout 3D ง่ายขึ้น
      ),
    );
  }

  // ── Avatar shop ───────────────────────────────────────────────────────────

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
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                        color: theme.textColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.storefront_rounded, color: theme.correct),
                    const SizedBox(width: 8),
                    Text("Avatar Shop",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.textColor,
                            fontFamily: 'monospace')),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.amber.shade600, Colors.orange.shade400]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("💰", style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text("${widget.currentUser.coins}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: avatars.map((av) {
                    final String emoji = av['emoji'] as String;
                    final int price = av['price'] as int;

                    final bool isOwned = price == 0 ||
                        widget.currentUser.ownedAvatars.contains(emoji);
                    final bool isEquipped = widget.currentUser.avatarEmoji == emoji;

                    return GestureDetector(
                      onTap: () {
                        if (isOwned) {
                          setState(() => widget.currentUser.avatarEmoji = emoji);
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
                          color: isEquipped
                              ? theme.correct.withOpacity(0.15)
                              : theme.textColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isEquipped
                                ? theme.correct
                                : theme.textColor.withOpacity(0.15),
                            width: isEquipped ? 2.5 : 1,
                          ),
                          boxShadow: isEquipped
                              ? [BoxShadow(color: theme.correct.withOpacity(0.3), blurRadius: 12)]
                              : null,
                        ),
                        child: Column(
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 36)),
                            const SizedBox(height: 6),
                            isOwned
                                ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  color: theme.correct.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                isEquipped ? "EQUIPPED" : "OWNED",
                                style: TextStyle(
                                    fontSize: 10,
                                    color: theme.correct,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                                : Text("💰 $price",
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        });
      },
    );
  }

  void _showConfirmAvatarDialog(
      Map<String, Object> av, GameTheme theme, StateSetter setModalState) {
    final int price = av['price'] as int;
    final String emoji = av['emoji'] as String;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.shopping_bag_rounded, color: Colors.amber, size: 28),
            const SizedBox(width: 10),
            Text("Confirm Purchase",
                style: TextStyle(
                    color: theme.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ],
        ),
        content: Text("Buy avatar '$emoji' for $price coins?",
            style: TextStyle(color: theme.textColor.withOpacity(0.8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: TextStyle(color: theme.textColor.withOpacity(0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: theme.correct,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(context);
              _processAvatarPurchase(emoji, price, setModalState);
            },
            child: const Text("Buy!",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _processAvatarPurchase(String emoji, int price, StateSetter setModalState) {
    if (widget.currentUser.coins >= price) {
      setState(() {
        widget.currentUser.coins -= price;
        widget.currentUser.ownedAvatars.add(emoji);
        widget.currentUser.avatarEmoji = emoji;
      });

      widget.currentUser.saveData();
      setModalState(() {});
      widget.onProfileUpdate();

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Avatar Unlocked! ✨"),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 1200),
            behavior: SnackBarBehavior.floating),
      );
    } else {
      AppFeedback.triggerHaptic(widget.currentUser);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Not enough coins! 💰"),
            backgroundColor: Colors.redAccent,
            duration: Duration(milliseconds: 1200),
            behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeDatabase.getTheme(widget.currentUser.currentThemeId);
    final isDark = theme.brightness == Brightness.dark;
    final rankColor = _rankColor(theme);

    int winRate = widget.currentUser.gamesPlayed > 0
        ? ((widget.currentUser.gamesWon / widget.currentUser.gamesPlayed) * 100).round()
        : 0;

    int maxCount = widget.currentUser.guessDistribution.reduce((a, b) => a > b ? a : b);
    if (maxCount == 0) maxCount = 1;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // ── HERO HEADER ───────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                rankColor.withOpacity(isDark ? 0.35 : 0.2),
                theme.backgroundColor,
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 28),
          child: Column(
            children: [
              // Avatar
              ScaleTransition(
                scale: _pulseAnim,
                child: GestureDetector(
                  onTap: () => _showAvatarShop(theme),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            rankColor.withOpacity(0.4),
                            rankColor.withOpacity(0.05)
                          ]),
                          border: Border.all(color: rankColor, width: 3),
                          boxShadow: [BoxShadow(color: rankColor.withOpacity(0.5), blurRadius: 20)],
                        ),
                        child: Center(
                          child: Text(widget.currentUser.avatarEmoji,
                              style: const TextStyle(fontSize: 52)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.correct,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: theme.correct.withOpacity(0.5), blurRadius: 8)],
                        ),
                        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                widget.currentUser.username.toUpperCase(),
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: theme.textColor,
                    fontFamily: 'monospace',
                    letterSpacing: 2),
              ),

              const SizedBox(height: 6),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                decoration: BoxDecoration(
                  color: rankColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: rankColor.withOpacity(0.4)),
                ),
                child: Text(
                  getRankTitle(widget.currentUser.wordsFound),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: rankColor),
                ),
              ),

              const SizedBox(height: 18),

              // XP bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "Progress to ${getRankNext(widget.currentUser.wordsFound)}",
                          style: TextStyle(
                              fontSize: 11,
                              color: theme.textColor.withOpacity(0.5),
                              fontFamily: 'monospace')),
                      Text("${widget.currentUser.wordsFound} words",
                          style: TextStyle(
                              fontSize: 11,
                              color: rankColor,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold)),
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
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [rankColor.withOpacity(0.7), rankColor]),
                                boxShadow: [BoxShadow(color: rankColor.withOpacity(0.6), blurRadius: 6)],
                              ),
                            ),
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

        // ── STATISTICS ────────────────────────────────────────────────
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
                  Expanded(child: _StatCard(label: "Streak", value: "🔥 ${widget.currentUser.currentStreak}", icon: Icons.local_fire_department_rounded, color: Colors.orange.shade400, theme: theme, isBig: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(label: "Best", value: "⚡ ${widget.currentUser.maxStreak}", icon: Icons.bolt_rounded, color: Colors.purple.shade400, theme: theme, isBig: true)),
                ],
              ),
            ],
          ),
        ),

        // ── GUESS DISTRIBUTION ────────────────────────────────────────
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
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: count > 0 ? theme.correct.withOpacity(0.15) : theme.textColor.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: count > 0
                                  ? theme.correct.withOpacity(0.4)
                                  : theme.textColor.withOpacity(0.1)),
                        ),
                        child: Center(
                          child: Text("${index + 1}",
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  color: count > 0
                                      ? theme.correct
                                      : theme.textColor.withOpacity(0.3))),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _barAnim,
                          builder: (_, __) {
                            double animatedFactor = widthFactor * _barAnim.value;
                            return LayoutBuilder(builder: (ctx, constraints) {
                              double fullWidth = constraints.maxWidth;
                              double barWidth = count > 0
                                  ? (animatedFactor * fullWidth).clamp(36.0, fullWidth)
                                  : 36.0 * _barAnim.value.clamp(0.0, 1.0);
                              return Stack(
                                children: [
                                  Container(
                                    height: 28,
                                    decoration: BoxDecoration(
                                        color: theme.textColor.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  if (count > 0)
                                    Container(
                                      width: barWidth,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          theme.correct.withOpacity(0.7),
                                          theme.correct
                                        ]),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [BoxShadow(color: theme.correct.withOpacity(0.35), blurRadius: 6, offset: const Offset(0, 2))],
                                      ),
                                    ),
                                  Positioned.fill(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: List.generate(6, (i) => Container(
                                              margin: const EdgeInsets.only(right: 2),
                                              width: 5,
                                              height: 14,
                                              decoration: BoxDecoration(
                                                color: i < (index + 1)
                                                    ? Colors.white.withOpacity(count > 0 ? 0.5 : 0.15)
                                                    : Colors.white.withOpacity(0.08),
                                                borderRadius: BorderRadius.circular(1),
                                              ),
                                            )),
                                          ),
                                          Text("$count",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'monospace',
                                                  color: count > 0
                                                      ? Colors.white
                                                      : theme.textColor.withOpacity(0.25))),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            });
                          },
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
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
        letterSpacing: 1.5,
        color: theme.textColor.withOpacity(0.45),
      ),
    );
  }
}

// ── STAT CARD ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final GameTheme theme;
  final bool isBig;

  const _StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.theme,
    this.isBig = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.08) : color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: isBig ? 20 : 22,
                      fontWeight: FontWeight.w900,
                      color: theme.textColor,
                      fontFamily: 'monospace')),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: theme.textColor.withOpacity(0.5),
                      fontFamily: 'monospace')),
            ],
          ),
        ],
      ),
    );
  }
}
