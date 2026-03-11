import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/custom_3d_buttton.dart';
import '../models/mock_data.dart';
import '../theme/theme_data.dart';
import 'game_screen.dart';
import 'store.dart';
import 'dictionary.dart';
import 'profile.dart';
import 'flashcard.dart';
import '../services/audio_helper.dart';

class HomePage extends StatefulWidget {
  final User currentUser;

  const HomePage({super.key, required this.currentUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // 🆕 GlobalKey lets us call showSettings() on ProfilePage from the AppBar
  final GlobalKey<ProfilePageState> _profileKey = GlobalKey<ProfilePageState>();

  void _refreshState() {
    setState(() {});
  }

  // 🆕 Build pages lazily so ProfilePage gets the key attached
  List<Widget> get _pages => [
    WordleMainBody(
      currentUser: widget.currentUser,
      onRefresh: _refreshState,
    ),
    FlashcardPage(currentUser: widget.currentUser),
    DictionaryPage(currentUser: widget.currentUser),
    StorePage(
      currentUser: widget.currentUser,
      onShopAction: _refreshState,
    ),
    ProfilePage(
      key: _profileKey, // 🆕 attach key so AppBar can reach into ProfilePage
      currentUser: widget.currentUser,
      onProfileUpdate: _refreshState,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  // 🆕 Whether the user is currently on the Profile tab (index 4)
  bool get _onProfileTab => _selectedIndex == 4;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeDatabase.getTheme(widget.currentUser.currentThemeId);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        actions: [
          // ── Coin badge (เพิ่ม GestureDetector เพื่อให้มีเสียง) ───────────────────────────────
          Center(
            child: GestureDetector(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB700), Color(0xFFFF8C00)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withAlpha(89),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("💰", style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      "${widget.currentUser.coins}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Settings button (เพิ่มเสียงและสั่น) ─────────────────────
          if (_onProfileTab)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: IconButton(
                icon: Icon(
                  Icons.settings_rounded,
                  color: theme.textColor.withAlpha(191),
                  size: 26,
                ),
                tooltip: "Settings",
                onPressed: () {
                  // ✨ เพิ่มเสียงและสั่นก่อนเปิด Settings
                  AppFeedback.playClick(widget.currentUser);
                  AppFeedback.triggerHaptic(widget.currentUser);

                  // Reach into ProfilePage and open the settings bottom sheet
                  _profileKey.currentState?.showSettings(theme);
                },
              ),
            ),

          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.textColor.withAlpha(25),
            height: 1.0,
          ),
        ),
      ),

      body: _pages[_selectedIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
                color: theme.textColor.withAlpha(25), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.backgroundColor,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: (index) {
            AppFeedback.playClick(widget.currentUser);   // เสียงคลิก
            AppFeedback.triggerHaptic(widget.currentUser); // สั่น
            _onItemTapped(index);                        // เปลี่ยนหน้า (ฟังก์ชันเดิม)
          },
          selectedItemColor: theme.correct,
          unselectedItemColor: theme.textColor.withAlpha(102),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded, size: 30), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.style_rounded, size: 30), label: 'Flashcard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_rounded, size: 30),
                label: 'Dictionary'),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_rounded, size: 30),
                label: 'Store'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded, size: 30), label: 'Profile'),

          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WordleMainBody  (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class WordleMainBody extends StatelessWidget {
  final User currentUser;
  final VoidCallback onRefresh;

  const WordleMainBody({
    super.key,
    required this.currentUser,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = ThemeDatabase.getTheme(currentUser.currentThemeId);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grid_on_rounded, size: 80, color: theme.correct),
          const SizedBox(height: 20),
          Text(
            "QUACKLE",
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Words Found: ${currentUser.wordsFound}",
            style: TextStyle(
                color: theme.textColor.withAlpha(153), fontSize: 16),
          ),
          const SizedBox(height: 50),

          // --- ปุ่ม PLAY ที่แก้ไขแล้ว ---
          Custom3DButton(
            width: 260.0,
            text: 'PLAY',
            onPressed: () {
              // 1. สั่งเล่นเสียงและสั่นทันที (ไม่รอ async)
              // แนะนำ: ถ้า playStartGame ช้า ลองใช้ playKeyboardTap ควบคู่ไปด้วยเพื่อให้มีเสียง "คลิก" ทันที
              AppFeedback.playKeyboardTap(currentUser);
              AppFeedback.playStartGame(currentUser);
              AppFeedback.triggerHaptic(currentUser);

              // 2. หน่วงเวลาการเปลี่ยนหน้าเล็กน้อย (ประมาณ 120ms)
              // เพื่อให้เสียงออกมาก่อนที่เครื่องจะไปโฟกัสกับการวาดหน้าจอใหม่
              Future.delayed(const Duration(milliseconds: 50), () async {
                if (!context.mounted) return;

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WordleScreen(currentUser: currentUser),
                  ),
                );

                // 3. รีเฟรชหน้า Home เมื่อกลับมา
                onRefresh();
              });
            },
            backgroundColor: theme.correct,
            shadowColor: theme.correct.withAlpha(128),
          ),
        ],
      ),
    );
  }
}

