import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';
import 'mock_data.dart';
import 'theme_data.dart';

class FlashcardPage extends StatefulWidget {
  final User currentUser;

  const FlashcardPage({super.key, required this.currentUser});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool isFront = true;
  int currentIndex = 0;
  bool isLoading = true;

  Map<String, String> wordMeanings = {};
  List<String> unlockedWords = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/targetwords.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      unlockedWords = widget.currentUser.foundWordsList;

      for (var word in unlockedWords) {
        String lowerWord = word.toLowerCase();
        if (data.containsKey(lowerWord) && data[lowerWord]['th'] != null) {
          wordMeanings[word] = data[lowerWord]['th'];
        } else {
          wordMeanings[word] = "ไม่มีคำแปล";
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error loading targetwords.json: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _flipCard() {
    if (_controller.isAnimating) return;
    if (isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    isFront = !isFront;
  }

  void _nextCard() {
    if (currentIndex < unlockedWords.length - 1) {
      setState(() {
        currentIndex++;
        _resetCard();
      });
    }
  }

  void _prevCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        _resetCard();
      });
    }
  }

  void _resetCard() {
    if (!isFront) {
      _controller.value = 0;
      isFront = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeDatabase.getTheme(widget.currentUser.currentThemeId);

    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.correct));
    }

    // --- 🔒 ระบบล็อคโหมด Flashcard ถ้าหาคำได้ไม่ถึง 15 คำ ---
    if (widget.currentUser.wordsFound < 15) {
      int wordsNeeded = 15 - widget.currentUser.wordsFound;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded, size: 100, color: theme.textColor.withOpacity(0.3)),
              const SizedBox(height: 20),
              Text(
                "MODE LOCKED",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.textColor),
              ),
              const SizedBox(height: 15),
              Text(
                "Find $wordsNeeded more words to unlock\nthe Flashcard Mode!",
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.textColor.withOpacity(0.7), fontSize: 18),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.correct.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.correct.withOpacity(0.5)),
                ),
                child: Text(
                  "Progress: ${widget.currentUser.wordsFound} / 15",
                  style: TextStyle(color: theme.correct, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              )
            ],
          ),
        ),
      );
    }

    if (unlockedWords.isEmpty) {
      return Center(child: Text("No cards available.", style: TextStyle(color: theme.textColor)));
    }

    String currentWord = unlockedWords[currentIndex];
    String currentMeaning = wordMeanings[currentWord] ?? "";

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(
            "FLASHCARDS",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.textColor),
          ),
          const SizedBox(height: 10),
          Text(
            "Tap to flip • Card ${currentIndex + 1} of ${unlockedWords.length}",
            style: TextStyle(color: theme.textColor.withOpacity(0.6), fontSize: 14),
          ),

          const Spacer(),

          GestureDetector(
            onTap: _flipCard,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final angle = _animation.value * pi;
                bool showFront = angle < (pi / 2);

                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  alignment: Alignment.center,
                  child: showFront
                  // เรียกใช้ _buildCardSide ตรงนี้
                      ? _buildCardSide(currentWord.toUpperCase(), true, theme)
                      : Transform(
                    transform: Matrix4.identity()..rotateY(pi),
                    alignment: Alignment.center,
                    child: _buildCardSide(currentMeaning, false, theme),
                  ),
                );
              },
            ),
          ),

          const Spacer(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                iconSize: 40,
                color: currentIndex > 0 ? theme.correct : theme.textColor.withOpacity(0.2),
                icon: const Icon(Icons.arrow_circle_left_rounded),
                onPressed: currentIndex > 0 ? _prevCard : null,
              ),
              IconButton(
                iconSize: 40,
                color: currentIndex < unlockedWords.length - 1 ? theme.correct : theme.textColor.withOpacity(0.2),
                icon: const Icon(Icons.arrow_circle_right_rounded),
                onPressed: currentIndex < unlockedWords.length - 1 ? _nextCard : null,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- ส่วนที่ขาดหายไป คือฟังก์ชันนี้ครับ ---
  Widget _buildCardSide(String text, bool isFrontSide, GameTheme theme) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: isFrontSide
            ? (theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white)
            : theme.correct,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
        border: Border.all(
          color: isFrontSide ? theme.correct.withOpacity(0.5) : Colors.transparent,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isFrontSide ? "WORD" : "MEANING",
            style: TextStyle(
              color: isFrontSide ? theme.textColor.withOpacity(0.5) : Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isFrontSide ? 36 : 28,
              fontWeight: FontWeight.bold,
              color: isFrontSide ? theme.textColor : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}