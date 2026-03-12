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
import '../components/custom_3d_buttton.dart';
import '../components/victory_effect.dart';

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
    GameTheme userTheme = ThemeDatabase.getTheme(widget.currentUser.currentThemeId);
    currentTheme = GameTheme(
      id: userTheme.id,
      name: userTheme.name,
      price: userTheme.price,
      correct: const Color(0xFF58CC02),
      present: const Color(0xFFC9B458),
      absent: const Color(0xFF787C7E),
      backgroundColor: userTheme.backgroundColor,
      textColor: userTheme.textColor,
      brightness: userTheme.brightness,
    );

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

    // 🆕 ใช้ WillPopScope ครอบ Scaffold เพื่อดักจับปุ่ม Back ของเครื่องมือถือ
    return WillPopScope(
      onWillPop: _showExitConfirmDialog, // 🆕 เรียกฟังก์ชันยืนยันเมื่อกด Back
      child: Scaffold(
        backgroundColor: currentTheme.backgroundColor,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: currentTheme.textColor),
            onPressed: () async {
              // 🆕 ดักจับปุ่ม Back บน AppBar
              bool shouldExit = await _showExitConfirmDialog();
              if (shouldExit && mounted) {
                Navigator.pop(context); // ถ้ากดยืนยันถึงจะให้ออก
              }
            },
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
                child: _buildGrid(keyTextColor), //
              ),
            ),

            // 2. Power-up Bar
            _buildPowerUpBar(), //

            // 3. Keyboard
            Expanded(
              flex: 2,
              child: _buildKeyboard(keyColor, keyTextColor), //
            ),
          ],
        ),
      ), // ✅ เพิ่มวงเล็บปิดของ Scaffold ตรงนี้
    );   // ✅ วงเล็บปิดของ WillPopScope
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
    // 🆕 เช็คว่าพิมพ์ไม่ครบ
    if (guess.length != 5) {
      _showMessage("Not enough letters");
      if (widget.currentUser.isVibrationEnabled) HapticFeedback.heavyImpact(); // 💥 สั่นแบบหนัก
      return;
    }
    // 🆕 เช็คว่าคำไม่มีในดิกชันนารี
    if (!validWordsDict.contains(guess)) {
      _showMessage("Not in word list");
      if (widget.currentUser.isVibrationEnabled) HapticFeedback.heavyImpact(); // 💥 สั่นแบบหนัก
      return;
    }
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
      String? newlyUnlockedRank; // 🆕 เพิ่มตัวแปรเก็บฉายาใหม่

      setState(() {
        widget.currentUser.gamesPlayed++;
        widget.currentUser.gamesWon++;
        widget.currentUser.currentStreak++;
        if (widget.currentUser.currentStreak > widget.currentUser.maxStreak) {
          widget.currentUser.maxStreak = widget.currentUser.currentStreak;
        }
        widget.currentUser.coins += 10;
        widget.currentUser.wordsFound += 1;
        if (!widget.currentUser.foundWordsList.contains(targetWord)) widget.currentUser.foundWordsList.add(targetWord);
        widget.currentUser.guessDistribution[currentRow - 1]++;

        // ตรวจสอบการปลดล็อก Flashcard
        if (widget.currentUser.wordsFound == 15) isUnlockedFlashcard = true;

        // 🆕 ตรวจสอบการปลดล็อกฉายาใหม่ (Rank)
        if (widget.currentUser.wordsFound == 10) newlyUnlockedRank = "📖 Bookworm";
        if (widget.currentUser.wordsFound == 30) newlyUnlockedRank = "🎓 Scholar";
        if (widget.currentUser.wordsFound == 50) newlyUnlockedRank = "🧙‍♂️ Word Master";
        if (widget.currentUser.wordsFound == 100) newlyUnlockedRank = "👑 Legend";

        // 🆕 เพิ่มฉายาเข้ากระเป๋า และตั้งให้สวมใส่อัตโนมัติเลย!
        if (newlyUnlockedRank != null && !widget.currentUser.unlockedRanks.contains(newlyUnlockedRank)) {
          widget.currentUser.unlockedRanks.add(newlyUnlockedRank!);
          widget.currentUser.selectedRankTitle = newlyUnlockedRank!;
        }
      });
      widget.currentUser.saveData();

      // 🆕 ส่งค่า newlyUnlockedRank เข้าไปใน Dialog ด้วย
      _showEndGameDialog(true, targetWord, targetWordTranslation, justUnlocked: isUnlockedFlashcard, newlyUnlockedRank: newlyUnlockedRank);

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

  // 🆕 ฟังก์ชันโชว์ข้อความกลางจอพร้อมดีไซน์แบบ Modern ขอบมน
  void _showMessage(String msg) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.35, // ลอยอยู่เหนือคีย์บอร์ดและกริดเล็กน้อย
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: currentTheme.textColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5))
                ],
              ),
              child: Text(
                msg,
                style: TextStyle(
                  color: currentTheme.backgroundColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // ยิงข้อความขึ้นจอ
    Overlay.of(context).insert(overlayEntry);

    // ตั้งเวลาให้ข้อความเฟดหายไปเอง
    bool isRemoved = false;
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!isRemoved) {
        overlayEntry.remove();
        isRemoved = true;
      }
    });
  }
  // --- ฟังก์ชันสำหรับโชว์หน้าต่างยืนยันการออกเกม ---
  Future<bool> _showExitConfirmDialog() async {
    AppFeedback.playClick(widget.currentUser);

    // โชว์ Dialog และรอค่า true (กดออก) หรือ false (กดยกเลิก)
    bool? shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: currentTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 10),
            Text("Quit Game?", style: TextStyle(color: currentTheme.textColor, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text("Are you sure you want to leave?\nYour current progress will be lost.",
            style: TextStyle(color: currentTheme.textColor.withOpacity(0.8))),
        actions: [
            ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: () {
              AppFeedback.playClick(widget.currentUser);
              Navigator.of(context).pop(true); // ส่งค่า true กลับไป (ยืนยันการออก)
            },
            child: const Text("Quit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              AppFeedback.playClick(widget.currentUser);
              Navigator.of(context).pop(false); // ส่งค่า false กลับไป (ไม่ให้ออก)
            },
            child: Text("Cancel", style: TextStyle(color: currentTheme.textColor.withOpacity(0.5))),
          ),
        ],
      ),
    );

    return shouldExit ?? false; // ถ้าปัดจอทิ้งให้ถือว่า false
  }

  void _showEndGameDialog(bool won, String targetWord, String meaning, {bool justUnlocked = false, String? newlyUnlockedRank}) {
    showDialog(
      context: context,
      barrierDismissible: false, // บังคับให้ต้องกดปุ่มเพื่อออก
      builder: (context) => Stack(
        alignment: Alignment.center,
        children: [
          // --- 1. กล่อง Popup Dialog (เลเยอร์ด้านหลัง) ---
          Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: currentTheme.backgroundColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: won ? currentTheme.correct.withOpacity(0.5) : Colors.redAccent.withOpacity(0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: won ? currentTheme.correct.withOpacity(0.25) : Colors.redAccent.withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- 🏆 ICON & TITLE ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: won ? currentTheme.correct.withOpacity(0.15) : Colors.redAccent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      won ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied_rounded,
                      color: won ? currentTheme.correct : Colors.redAccent,
                      size: 52,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    won ? "SPLENDID!" : "GAME OVER",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: won ? currentTheme.correct : Colors.redAccent,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    won ? "You guessed the word correctly." : "The hidden word was...",
                    style: TextStyle(color: currentTheme.textColor.withOpacity(0.6), fontSize: 14),
                  ),

                  const SizedBox(height: 24),

                  // --- 🔠 THE WORD DISPLAY ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: currentTheme.textColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: currentTheme.textColor.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          targetWord.toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            color: currentTheme.textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          meaning,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueAccent
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- 🎁 REWARDS SECTION ---
                  if (won) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          "+10 Coins",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: currentTheme.textColor
                          ),
                        ),
                      ],
                    ),
                  ],

                  // --- 🎉 FLASHCARD UNLOCKED ALERt ---
                  if (justUnlocked) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade400, Colors.deepPurple.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.purple.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.style_rounded, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "FLASHCARD UNLOCKED!",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                                ),
                                Text(
                                  "15 words milestone reached ✨",
                                  style: TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                // --- 🌟 RANK UNLOCKED ALERT (เพิ่มใหม่) ---
                  if (newlyUnlockedRank != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars_rounded, color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "NEW TITLE UNLOCKED!",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                                ),
                                Text(
                                  newlyUnlockedRank, // แสดงฉายา เช่น 📖 Bookworm
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // --- 🕹️ BUTTONS ---
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Custom3DButton(
                          text: "MENU",
                          backgroundColor: Colors.grey.shade400,
                          shadowColor: Colors.grey.shade600,
                          onPressed: () {
                            AppFeedback.playClick(widget.currentUser);
                            AppFeedback.triggerHaptic(widget.currentUser);
                            Navigator.pop(context); // ปิด Dialog
                            Navigator.pop(context); // กลับหน้าหลัก
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Custom3DButton(
                          text: won ? "PLAY AGAIN" : "TRY AGAIN",
                          backgroundColor: won ? currentTheme.correct : Colors.blueAccent,
                          shadowColor: won ? Colors.green.shade700 : Colors.blue.shade700,
                          onPressed: () {
                            AppFeedback.playClick(widget.currentUser);
                            AppFeedback.triggerHaptic(widget.currentUser);
                            Navigator.pop(context);
                            _resetGame();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // --- 2. ✨ เอฟเฟกต์พลุกระจาย (เลเยอร์ด้านหน้าสุด จะทำงานเมื่อ won == true เท่านั้น) ---
          if (won) const VictoryEffect(),
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
