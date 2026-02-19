import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mock_data.dart';
import 'theme_data.dart';
import 'game_screen.dart';
import 'store.dart';
import 'dictionary.dart';
import 'profile.dart';
import 'flashcard.dart';

class HomePage extends StatefulWidget {
  final User currentUser;

  const HomePage({super.key, required this.currentUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _refreshState() {
    setState(() {
    });
  }

  void _handleLogout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  List<Widget> get _pages => [
    WordleMainBody(
      currentUser: widget.currentUser,
      onRefresh: _refreshState,
    ),
    StorePage(
      currentUser: widget.currentUser,
      onShopAction: _refreshState,
    ),
    DictionaryPage(currentUser: widget.currentUser),
    FlashcardPage(currentUser: widget.currentUser),
    ProfilePage(currentUser: widget.currentUser),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeDatabase.getTheme(widget.currentUser.currentThemeId);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar( //App bar
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        backgroundColor: theme.backgroundColor,
        elevation: 0,
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.correct.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "💰 ${widget.currentUser.coins}",
                style: TextStyle(
                    color: theme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: theme.textColor.withOpacity(0.1), height: 1.0),
        ),
      ),

      body: _pages[_selectedIndex],

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.textColor.withOpacity(0.1), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: theme.backgroundColor,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: theme.correct,
          unselectedItemColor: theme.textColor.withOpacity(0.4),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded, size: 30), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_rounded, size: 30), label: 'Store'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded, size: 30), label: 'Dictionary'),
            BottomNavigationBarItem(icon: Icon(Icons.style_rounded, size: 30), label: 'Flashcard'),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded, size: 30), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

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
            "WORDLE",
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
            style: TextStyle(color: theme.textColor.withOpacity(0.6), fontSize: 16),
          ),
          const SizedBox(height: 50),

          SizedBox(
            width: 250,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.correct,
                foregroundColor: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WordleScreen(currentUser: currentUser),
                  ),
                );
                onRefresh();
              },
              child: const Text(
                "PLAY",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}