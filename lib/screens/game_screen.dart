/*
 * File: game_screen.dart
 * Description: The core gameplay screen with Power-ups.
 */

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../models/mock_data.dart';
import '../services/audio_helper.dart';
import '../theme/theme_data.dart';
import '../components/custom_keyboard_key.dart';

const Color defaultLightKeyColor = Color(0xFFD3D6DA);
const Color defaultDarkKeyColor = Color(0xFF4F4F4F);
const Color filledBorderColor = Color(0xFF878A8C);

enum LetterStatus { initial, entered, correct, present, absent }

class WordleScreen extends StatefulWidget {
  final User currentUser;
  const WordleScreen({super.key, required this.currentUser});

  @override
  State<WordleScreen> createState() => _WordleScreenState();
}

class _WordleScreenState extends State<WordleScreen> {
  late GameTheme currentTheme;
  int maxRows = 6;
  bool isExtraRowUsed = false;
  String targetWord = "";
  String targetWordTranslation = "";
  Map<String, String> targetWords = {};
  Set<String> validWordsDict = {};
  bool isLoading = true;

  List<String> guesses = List.generate(6, (_) => "");
  List<List<LetterStatus>> gridStatus = List.generate(6, (_) => List.filled(5, LetterStatus.initial));
  int currentRow = 0;

  Map<String, LetterStatus> keyStatus = {};
  bool isAnimating = false;

  @override
  void initState() {
    super.initState();
    currentTheme = ThemeDatabase.getTheme(widget.currentUser.currentThemeId);
    _loadGameData();
  }

  // --- Data Loading Logic ---
  Future<void> _loadGameData() async {
    try {
      final results = await Future.wait([
        rootBundle.loadString('assets/targetwords.json'),
        rootBundle.loadString('assets/validwords.txt'),
      ]);
      final Map<String, dynamic> targetsJson = json.decode(results[0]);
      final List<String> targets = targetsJson.keys.map((w) => w.trim().toUpperCase()).where((w) => w.length == 5).toList();
      targetsJson.forEach((key, value) => targetWords[key.toUpperCase()] = value['th']);
      List<String> valids = results[1].split('\n').map((w) => w.trim().toUpperCase()).where((w) => w.length == 5).toList();

      setState(() {
        if (targets.isNotEmpty) {
          targetWord = targets[Random().nextInt(targets.length)];
          targetWordTranslation = targetWords[targetWord] ?? "";
        } else {
          targetWord = "WORLD";
          targetWordTranslation = "โลก";
        }
        validWordsDict = valids.toSet()..addAll(targets);
        isLoading = false;
        print("Target: $targetWord ($targetWordTranslation)");
      });
    } catch (e) {
      setState(() { targetWord = "ERROR"; isLoading = false; });
    }
  }

  void _resetGame() {
    setState(() {
      final List<String> keys = targetWords.keys.toList();
      if (keys.isNotEmpty) {
        targetWord = keys[Random().nextInt(keys.length)];
        targetWordTranslation = targetWords[targetWord] ?? "";
      }
      guesses = List.filled(6, "");
      currentRow = 0;
      gridStatus = List.generate(6, (_) => List.filled(5, LetterStatus.initial));
      keyStatus = {};
      isAnimating = false;
      maxRows = 6;
      isExtraRowUsed = false;
    });
  }

  // --- Power-ups Logic ---
  void _useHint() {
    if (widget.currentUser.hintCount <= 0 || guesses[currentRow].length >= 5) return;
    setState(() {
      widget.currentUser.hintCount--;
      int emptyIndex = guesses[currentRow].length;
      String correctLetter = targetWord[emptyIndex];
      guesses[currentRow] += correctLetter;
      gridStatus[currentRow][emptyIndex] = LetterStatus.entered;
    });
    widget.currentUser.saveData();
    AppFeedback.playClick(widget.currentUser);
  }

  void _useCleaner() {
    if (widget.currentUser.cleanerCount <= 0) return;
    setState(() {
      widget.currentUser.cleanerCount--;
      List<String> alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".split('');
      List<String> wrongLetters = alphabet
          .where((letter) => !targetWord.contains(letter) && keyStatus[letter] == null)
          .toList()..shuffle();
      for (int i = 0; i < min(3, wrongLetters.length); i++) {
        keyStatus[wrongLetters[i]] = LetterStatus.absent;
      }
    });
    widget.currentUser.saveData();
    AppFeedback.playClick(widget.currentUser);
  }

  void _useExtraRow() {
    if (widget.currentUser.extraRowCount <= 0 || isExtraRowUsed) return;
    setState(() {
      widget.currentUser.extraRowCount--;
      isExtraRowUsed = true;
      maxRows = 7;
      guesses.add("");
      gridStatus.add(List.filled(5, LetterStatus.initial));
    });
    widget.currentUser.saveData();
    AppFeedback.playClick(widget.currentUser);
  }

  void _showUseItemDialog(String title, String description, VoidCallback onConfirm) {
    AppFeedback.playClick(widget.currentUser);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: currentTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Use $title?", style: TextStyle(color: currentTheme.textColor, fontWeight: FontWeight.bold)),
        content: Text(description, style: TextStyle(color: currentTheme.textColor.withOpacity(0.7))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: currentTheme.correct),
            onPressed: () { Navigator.pop(context); onConfirm(); },
            child: const Text("Use Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- Build Method (Combined & Fixed) ---
  @override
  Widget build(BuildContext context) {
    bool isDark = currentTheme.brightness == Brightness.dark;
    Color keyColor = isDark ? defaultDarkKeyColor : defaultLightKeyColor;
    Color keyTextColor = isDark ? Colors.white : Colors.black;

    if (isLoading) {
      return Scaffold(
        backgroundColor: currentTheme.backgroundColor,
        body: Center(child: CircularProgressIndicator(color: currentTheme.textColor)),
      );
    }

    return Scaffold(
      backgroundColor: currentTheme.backgroundColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: currentTheme.textColor),
          onPressed: () { AppFeedback.playClick(widget.currentUser); Navigator.pop(context); },
        ),
        title: Text("QUACKLE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, color: currentTheme.textColor)),
        centerTitle: true,
        backgroundColor: currentTheme.backgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Game Grid
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: _buildGrid(keyTextColor),
            ),
          ),

          // 2. Power-up Bar
          _buildPowerUpBar(),

          // 3. Keyboard
          Expanded(
            flex: 2,
            child: _buildKeyboard(keyColor, keyTextColor),
          ),
        ],
      ),
    );
  }

  // --- UI Sub-widgets ---
  Widget _buildGrid(Color defaultTextColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(maxRows, (rowIndex) {
        return Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (colIndex) {
              String char = (guesses[rowIndex].length > colIndex) ? guesses[rowIndex][colIndex] : "";
              return FlipTile(
                char: char,
                status: gridStatus[rowIndex][colIndex],
                currentTheme: currentTheme,
                delayIndex: colIndex,
                currentUser: widget.currentUser,
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildPowerUpBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _powerUpButton(
            icon: Icons.lightbulb_outline,
            count: widget.currentUser.hintCount,
            label: "Hint",
            onTap: () => _showUseItemDialog("Hint Reveal", "Reveals one correct letter.", _useHint),
            color: Colors.orange,
          ),
          _powerUpButton(
            icon: Icons.auto_fix_high,
            count: widget.currentUser.cleanerCount,
            label: "Cleaner",
            onTap: () => _showUseItemDialog("Keyboard Cleaner", "Removes 3 wrong letters.", _useCleaner),
            color: Colors.blue,
          ),
          _powerUpButton(
            icon: Icons.add_circle_outline,
            count: widget.currentUser.extraRowCount,
            label: "Extra Row",
            onTap: () => _showUseItemDialog("Extra Row", "Adds a 7th guess row.", _useExtraRow),
            color: Colors.green,
            isLocked: isExtraRowUsed,
          ),
        ],
      ),
    );
  }

  Widget _powerUpButton({required IconData icon, required int count, required String label, required VoidCallback onTap, required Color color, bool isLocked = false}) {
    bool hasItem = count > 0 && !isLocked;
    return GestureDetector(
      onTap: hasItem ? onTap : null,
      child: Opacity(
        opacity: hasItem ? 1.0 : 0.3,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
                  child: Icon(icon, color: color, size: 22),
                ),
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text("$count", style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: currentTheme.textColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboard(Color defaultKeyColor, Color defaultTextColor) {
    const keys = [
      ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
      ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
      ["ENTER", "Z", "X", "C", "V", "B", "N", "M", "DEL"]
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: keys.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((char) {
              Color keyColor = defaultKeyColor;
              Color textColor = defaultTextColor;

              if (char != "ENTER" && char != "DEL") {
                LetterStatus? status = keyStatus[char];
                if (status != null) {
                  textColor = Colors.white;
                  switch (status) {
                    case LetterStatus.correct: keyColor = currentTheme.correct; break;
                    case LetterStatus.present: keyColor = currentTheme.present; break;
                    case LetterStatus.absent: keyColor = currentTheme.absent; break;
                    default: keyColor = defaultKeyColor; textColor = defaultTextColor;
                  }
                }
              }

              return Custom3DKey(
                char: char,
                keyColor: keyColor,
                textColor: textColor,
                flex: (char == "ENTER" || char == "DEL") ? 2 : 1,
                onTap: () => onKeyPressed(char),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  // --- Game Core Logic ---
  void onKeyPressed(String val) {
    if (currentRow >= maxRows || isLoading) return;

    setState(() {
      if (val == "ENTER") {
        AppFeedback.playKeyboardTap(widget.currentUser);
        _checkWord();
      } else if (val == "DEL") {
        AppFeedback.playKeyboardTap(widget.currentUser);
        if (guesses[currentRow].isNotEmpty) {
          guesses[currentRow] = guesses[currentRow].substring(0, guesses[currentRow].length - 1);
          gridStatus[currentRow][guesses[currentRow].length] = LetterStatus.initial;
        }
      } else {
        if (guesses[currentRow].length < 5) {
          AppFeedback.playKeyboardTap(widget.currentUser);
          int currentIndex = guesses[currentRow].length;
          guesses[currentRow] += val;
          gridStatus[currentRow][currentIndex] = LetterStatus.entered;
        }
      }
    });
  }

  Future<void> _checkWord() async {
    String guess = guesses[currentRow];
    if (guess.length != 5) { _showMessage("Not enough letters"); return; }
    if (!validWordsDict.contains(guess)) { _showMessage("Not in word list"); return; }
    if (isAnimating) return;

    setState(() { isAnimating = true; });

    List<String> targetChars = targetWord.split('');
    List<LetterStatus> rowStatus = List.filled(5, LetterStatus.absent);

    for (int i = 0; i < 5; i++) {
      if (guess[i] == targetChars[i]) {
        rowStatus[i] = LetterStatus.correct;
        targetChars[i] = '';
      }
    }
    for (int i = 0; i < 5; i++) {
      if (rowStatus[i] != LetterStatus.correct) {
        int indexInTarget = targetChars.indexOf(guess[i]);
        if (indexInTarget != -1) {
          rowStatus[i] = LetterStatus.present;
          targetChars[indexInTarget] = '';
        }
      }
    }

    setState(() {
      for (int i = 0; i < 5; i++) gridStatus[currentRow][i] = rowStatus[i];
      currentRow++;
    });

    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    setState(() {
      for (int i = 0; i < 5; i++) {
        String char = guess[i];
        LetterStatus currentStatus = rowStatus[i];
        if (keyStatus[char] != LetterStatus.correct) {
          if (currentStatus == LetterStatus.correct) keyStatus[char] = LetterStatus.correct;
          else if (keyStatus[char] != LetterStatus.present && currentStatus == LetterStatus.present) keyStatus[char] = LetterStatus.present;
          else if (keyStatus[char] == null && currentStatus == LetterStatus.absent) keyStatus[char] = LetterStatus.absent;
        }
      }
      isAnimating = false;
    });

    if (guess == targetWord) {
      AppFeedback.playWin(widget.currentUser);
      bool isUnlockedFlashcard = false;
      setState(() {
        widget.currentUser.coins += 10;
        widget.currentUser.wordsFound += 1;
        if (!widget.currentUser.foundWordsList.contains(targetWord)) widget.currentUser.foundWordsList.add(targetWord);
        widget.currentUser.guessDistribution[currentRow - 1]++;
        if (widget.currentUser.wordsFound == 15) isUnlockedFlashcard = true;
      });
      widget.currentUser.saveData();
      _showEndGameDialog(true, targetWord, targetWordTranslation, justUnlocked: isUnlockedFlashcard);
    } else if (currentRow == maxRows) {
      AppFeedback.playLose(widget.currentUser);
      setState(() {
        widget.currentUser.gamesPlayed++;
        widget.currentUser.currentStreak = 0;
      });
      widget.currentUser.saveData();
      _showEndGameDialog(false, targetWord, targetWordTranslation);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center, style: TextStyle(color: currentTheme.backgroundColor)),
        duration: const Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
        backgroundColor: currentTheme.textColor,
      ),
    );
  }

  void _showEndGameDialog(bool won, String targetWord, String meaning, {bool justUnlocked = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: currentTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(won ? Icons.emoji_events_rounded : Icons.cancel_outlined, color: won ? currentTheme.correct : Colors.redAccent, size: 60),
            const SizedBox(height: 10),
            Text(won ? "Nicega! (You Won)" : "Oh no! (Game Over)", textAlign: TextAlign.center, style: TextStyle(color: won ? currentTheme.correct : Colors.redAccent, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("The answer was", style: TextStyle(color: currentTheme.textColor.withOpacity(0.7))),
            Text(targetWord.toUpperCase(), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2, color: currentTheme.textColor)),
            Text(meaning, style: const TextStyle(fontSize: 18, color: Colors.blueAccent), textAlign: TextAlign.center),
            if (won) ...[
              const Divider(height: 30),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(20)), child: const Text("💰 +10 Coins", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown))),
            ],
            if (justUnlocked) ...[
              const SizedBox(height: 20),
              Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.purple.shade100, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.purple, width: 2)),
                child: const Column(children: [Icon(Icons.lock_open_rounded, color: Colors.purple, size: 30), Text("FLASHCARD UNLOCKED!", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple))]),
              ),
            ]
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: () { AppFeedback.playKeyboardTap(widget.currentUser); Navigator.pop(context); Navigator.pop(context); }, child: const Text("Menu")),
              ElevatedButton(onPressed: () { AppFeedback.playClick(widget.currentUser); Navigator.pop(context); _resetGame(); }, child: const Text("Play Again")),
            ],
          ),
        ],
      ),
    );
  }
}

// --- FlipTile Component (Unchanged) ---
class FlipTile extends StatefulWidget {
  final String char;
  final LetterStatus status;
  final GameTheme currentTheme;
  final int delayIndex;
  final User currentUser;
  const FlipTile({super.key, required this.char, required this.status, required this.currentTheme, required this.delayIndex, required this.currentUser});
  @override
  State<FlipTile> createState() => _FlipTileState();
}

class _FlipTileState extends State<FlipTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _animation = Tween<double>(begin: 0, end: pi).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack));
  }
  @override
  void didUpdateWidget(FlipTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == LetterStatus.initial) { _controller.reset(); return; }
    if (widget.status != oldWidget.status && widget.status != LetterStatus.initial && widget.status != LetterStatus.entered) {
      Future.delayed(Duration(milliseconds: widget.delayIndex * 200), () {
        if (mounted) { _controller.forward(from: 0.0); AppFeedback.playClick(widget.currentUser); AppFeedback.triggerHaptic(widget.currentUser); }
      });
    }
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _controller, builder: (context, child) {
      double angle = _animation.value;
      bool isFlipped = angle >= (pi / 2);
      double displayAngle = isFlipped ? angle - pi : angle;
      return Transform(transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateX(displayAngle), alignment: Alignment.center, child: _buildContent(isFlipped));
    });
  }
  Widget _buildContent(bool isFlipped) {
    LetterStatus displayStatus = isFlipped ? widget.status : LetterStatus.entered;
    Color color = Colors.transparent;
    Color borderColor = widget.currentTheme.textColor.withOpacity(0.3);
    Color textColor = widget.currentTheme.textColor;
    if (displayStatus == LetterStatus.entered) {
      borderColor = filledBorderColor;
      if (widget.char.isEmpty) borderColor = widget.currentTheme.textColor.withOpacity(0.3);
    } else {
      textColor = Colors.white; borderColor = Colors.transparent;
      switch (displayStatus) {
        case LetterStatus.correct: color = widget.currentTheme.correct; break;
        case LetterStatus.present: color = widget.currentTheme.present; break;
        case LetterStatus.absent: color = widget.currentTheme.absent; break;
        default: break;
      }
    }
    if (widget.currentTheme.brightness == Brightness.dark && displayStatus == LetterStatus.initial) color = Colors.white.withOpacity(0.05);
    return Container(margin: const EdgeInsets.all(3), width: 50, height: 50, decoration: BoxDecoration(color: color, border: Border.all(color: borderColor, width: 2)), alignment: Alignment.center,
      child: Text(widget.char, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
    );
  }
}