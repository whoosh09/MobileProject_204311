/*
 * File: game_screen.dart
 * Description: The core gameplay screen.
 * Updated: FIXED Compilation Errors (appBarColor, Arguments, Constants)
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

  String targetWord = "";
  String targetWordTranslation = "";
  Map<String, String> targetWords = {};
  Set<String> validWordsDict = {};
  bool isLoading = true;

  List<String> guesses = List.filled(6, "");
  int currentRow = 0;
  List<List<LetterStatus>> gridStatus = List.generate(
      6, (_) => List.filled(5, LetterStatus.initial));

  Map<String, LetterStatus> keyStatus = {};

  @override
  void initState() {
    super.initState();
    currentTheme = ThemeDatabase.getTheme(widget.currentUser.currentThemeId);
    _loadGameData();
  }

  Future<void> _loadGameData() async {
    try {
      final results = await Future.wait([
        rootBundle.loadString('assets/targetwords.json'),
        rootBundle.loadString('assets/validwords.txt'),
      ]);

      final String targetContent = results[0];
      final String validContent = results[1];

      final Map<String, dynamic> targetsJson = json.decode(targetContent);
      final List<String> targets = targetsJson.keys.map((w) => w.trim().toUpperCase()).where((w) => w.length == 5).toList();
      targetsJson.forEach((key, value) {
        targetWords[key.toUpperCase()] = value['th'];
      });


      List<String> valids = validContent.split('\n')
          .map((w) => w.trim().toUpperCase())
          .where((w) => w.length == 5)
          .toList();

      setState(() {
        if (targets.isNotEmpty) {
          targetWord = targets[Random().nextInt(targets.length)];
          targetWordTranslation = targetWords[targetWord] ?? "";
        } else {
          targetWord = "WORLD";
          targetWordTranslation = "โลก";
        }
        validWordsDict = valids.toSet();
        validWordsDict.addAll(targets);
        isLoading = false;
        print("Target: $targetWord ($targetWordTranslation)");
      });
    } catch (e) {
      print("Error loading files: $e");
      setState(() {
        targetWord = "ERROR";
        isLoading = false;
      });
    }
  }
  void _resetGame() {
    setState(() {
      // 1. สุ่มคำศัพท์ใหม่จาก Map targetWords ที่โหลดมาแล้ว
      final List<String> keys = targetWords.keys.toList();
      if (keys.isNotEmpty) {
        targetWord = keys[Random().nextInt(keys.length)];
        targetWordTranslation = targetWords[targetWord] ?? "";
      }

      // 2. ล้างข้อมูลการเล่นเก่า
      guesses = List.filled(6, "");
      currentRow = 0;
      gridStatus = List.generate(6, (_) => List.filled(5, LetterStatus.initial));
      keyStatus = {};
      isAnimating = false;
    });
    print("New Target: $targetWord ($targetWordTranslation)");
  }

  void onKeyPressed(String val) {
    if (currentRow >= 6 || isLoading) return;

    setState(() {
      if (val == "ENTER") {
        AppFeedback.playKeyboardTap(widget.currentUser);
        _checkWord();
      } else if (val == "DEL") {
        AppFeedback.playKeyboardTap(widget.currentUser);
        if (guesses[currentRow].isNotEmpty) {
          guesses[currentRow] =
              guesses[currentRow].substring(0, guesses[currentRow].length - 1);
          gridStatus[currentRow][guesses[currentRow].length] =
              LetterStatus.initial;
        }
      } else {
        if (guesses[currentRow].length < 5) {
          // ✨ เสียงและสั่นตอนพิมพ์ตัวอักษรลงตาราง
          AppFeedback.playKeyboardTap(widget.currentUser);

          int currentIndex = guesses[currentRow].length;
          guesses[currentRow] += val;
          gridStatus[currentRow][currentIndex] = LetterStatus.entered;
        }
      }
    });
  }

// เพิ่มตัวแปรกันเบิ้ล (ถ้ายังไม่มีให้ประกาศเพิ่มด้านบน class)
  bool isAnimating = false;

  Future<void> _checkWord() async {
    String guess = guesses[currentRow];

    // 1. เช็คความถูกต้องเบื้องต้น
    if (guess.length != 5) {
      _showMessage("Not enough letters");
      AppFeedback.triggerHaptic(widget.currentUser); // ✅ เพิ่มบรรทัดนี้ (สั่นเตือน)
      return;
    }
    if (!validWordsDict.contains(guess)) {
      _showMessage("Not in word list");
      AppFeedback.triggerHaptic(widget.currentUser); // ✅ เพิ่มบรรทัดนี้ (สั่นเตือน)
      return;
    }

    // ถ้ากำลังหมุนอยู่ ห้ามกดซ้ำ
    if (isAnimating) return;
    setState(() {
      isAnimating = true;
    });

    List<String> targetChars = targetWord.split('');
    List<LetterStatus> rowStatus = List.filled(5, LetterStatus.absent);

    // รอบ 1: สีเขียว (Correct)
    for (int i = 0; i < 5; i++) {
      if (guess[i] == targetChars[i]) {
        rowStatus[i] = LetterStatus.correct;
        targetChars[i] = '';
      }
    }

    // รอบ 2: สีเหลือง (Present)
    for (int i = 0; i < 5; i++) {
      if (rowStatus[i] != LetterStatus.correct) {
        String char = guess[i];
        int indexInTarget = targetChars.indexOf(char);
        if (indexInTarget != -1) {
          rowStatus[i] = LetterStatus.present;
          targetChars[indexInTarget] = '';
        }
      }
    }
    setState(() {
      for (int i = 0; i < 5; i++) {
        gridStatus[currentRow][i] = rowStatus[i];
      }
      currentRow++;
    });

    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    setState(() {
      for (int i = 0; i < 5; i++) {
        String char = guess[i];
        LetterStatus currentStatus = rowStatus[i];

        if (keyStatus[char] != LetterStatus.correct) {
          if (currentStatus == LetterStatus.correct) {
            keyStatus[char] = LetterStatus.correct;
          } else if (keyStatus[char] != LetterStatus.present &&
              currentStatus == LetterStatus.present) {
            keyStatus[char] = LetterStatus.present;
          } else if (keyStatus[char] == null &&
              currentStatus == LetterStatus.absent) {
            keyStatus[char] = LetterStatus.absent;
          }
        }
      }
      isAnimating = false;
    });

    if (guess == targetWord) {
      AppFeedback.playWin(widget.currentUser);
      bool isUnlockedFlashcard = false; // ตัวแปรเช็คการปลดล็อค

      setState(() {
        // 🆕 --- MISSING STAT UPDATES ADDED HERE ---
        widget.currentUser.gamesPlayed++;
        widget.currentUser.gamesWon++;
        widget.currentUser.currentStreak++;

        // Update max streak if the current streak beats the record
        if (widget.currentUser.currentStreak > widget.currentUser.maxStreak) {
          widget.currentUser.maxStreak = widget.currentUser.currentStreak;
        }
        // ------------------------------------------

        widget.currentUser.coins += 10;
        widget.currentUser.wordsFound += 1;

        if (!widget.currentUser.foundWordsList.contains(targetWord)) {
          widget.currentUser.foundWordsList.add(targetWord);
        }
        widget.currentUser.guessDistribution[currentRow - 1]++; // บันทึกว่าทายถูกในแถวที่เท่าไหร่

        // เช็คว่าหาคำศัพท์ครบ 15 คำ "พอดี" ในรอบนี้ไหม
        if (widget.currentUser.wordsFound == 15) {
          isUnlockedFlashcard = true; // เตรียมแจ้งเตือน
        }
      });

      widget.currentUser.saveData();
      _showEndGameDialog(true, targetWord, targetWordTranslation, justUnlocked: isUnlockedFlashcard);

    } else if (currentRow == 6) {
      // --- แพ้ ---
      AppFeedback.playLose(widget.currentUser);
      setState(() {
        // 🆕 อัปเดตสถิติการเล่น (Lose)
        widget.currentUser.gamesPlayed++;
        widget.currentUser.currentStreak = 0; // สตรีคขาด!
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
        margin: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
        backgroundColor: currentTheme.textColor,
      ),
    );
  }

  void _showEndGameDialog(bool won, String targetWord, String meaning, {bool justUnlocked = false}) {
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "QUACKLE",
          style: TextStyle(
              fontWeight: FontWeight.bold, letterSpacing: 2, color: currentTheme.textColor),
        ),
        centerTitle: true,
        backgroundColor: currentTheme.backgroundColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: currentTheme.textColor.withOpacity(0.1), height: 1.0),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: _buildGrid(keyTextColor),
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildKeyboard(keyColor, keyTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(Color defaultTextColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (rowIndex) {
        return Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (colIndex) {
              String char = "";
              if (guesses[rowIndex].length > colIndex) {
                char = guesses[rowIndex][colIndex];
              }
              // ส่ง colIndex ไปด้วย
              return _buildCell(char, gridStatus[rowIndex][colIndex], defaultTextColor, colIndex);
            }),
          ),
        );
      }),
    );
  }

  Widget _buildCell(String char, LetterStatus status, Color defaultTextColor, int delayIndex) {
    Color color = Colors.transparent;
    Color borderColor = currentTheme.textColor.withOpacity(0.3);
    Color textColor = defaultTextColor;

    switch (status) {
      case LetterStatus.correct:
        color = currentTheme.correct;
        borderColor = Colors.transparent;
        textColor = Colors.white;
        break;
      case LetterStatus.present:
        color = currentTheme.present;
        borderColor = Colors.transparent;
        textColor = Colors.white;
        break;
      case LetterStatus.absent:
        color = currentTheme.absent;
        borderColor = Colors.transparent;
        textColor = Colors.white;
        break;
      case LetterStatus.entered:
        borderColor = filledBorderColor;
        textColor = defaultTextColor;
        break;
      case LetterStatus.initial:
        break;
    }

    if (currentTheme.brightness == Brightness.dark && status == LetterStatus.initial) {
      color = Colors.white.withOpacity(0.05);
    }

    return FlipTile(
      char: char,
      status: status,
      currentTheme: currentTheme, // ส่งธีมเข้าไป
      delayIndex: delayIndex,     // ส่งลำดับคอลัมน์เข้าไป (0-4)
      currentUser: widget.currentUser,
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
      color: currentTheme.backgroundColor,
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

              // Calling your new component here!
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
}
// --- เพิ่ม Class นี้ไว้ล่างสุดของไฟล์ game_screen.dart (นอก class WordleScreen) ---

class FlipTile extends StatefulWidget {
  final String char;
  final LetterStatus status;
  final GameTheme currentTheme;
  final int delayIndex; // ลำดับคอลัมน์ (0,1,2,3,4) เพื่อถ่วงเวลาให้พลิกไม่พร้อมกัน
  final User currentUser;

  const FlipTile({
    super.key,
    required this.char,
    required this.status,
    required this.currentTheme,
    required this.delayIndex,
    required this.currentUser,
  });

  @override
  State<FlipTile> createState() => _FlipTileState();
}

class _FlipTileState extends State<FlipTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // ความเร็วในการหมุน
    );

    _animation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
  }

  @override
  void didUpdateWidget(FlipTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ถ้าสถานะกลับเป็น initial ให้รีเซ็ตแอนิเมชั่นทันที
    if (widget.status == LetterStatus.initial) {
      _controller.reset();
      return;
    }
    // เช็คว่าสถานะเปลี่ยนจาก "พิมพ์เฉยๆ" เป็น "เฉลยผล" หรือไม่
    if (widget.status != oldWidget.status &&
        widget.status != LetterStatus.initial &&
        widget.status != LetterStatus.entered) {

      // ถ่วงเวลาตามลำดับช่อง (ช่องแรกเริ่มเลย, ช่องสองรอ 200ms, ...)
      Future.delayed(Duration(milliseconds: widget.delayIndex * 200), () {
        if (mounted) {
          _controller.forward(from: 0.0);
          AppFeedback.playClick(widget.currentUser);
          AppFeedback.triggerHaptic(widget.currentUser);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // คำนวณมุมหมุน
        double angle = _animation.value;
        // เช็คว่าหมุนเกิน 90 องศาหรือยัง (ถ้าเกินแล้วให้เปลี่ยนสี)
        bool isFlipped = angle >= (pi / 2);

        // ถ้าหมุนเกิน 90 องศา ให้พลิกภาพกลับหัวไม่ให้ตัวหนังสือกลับด้าน
        double displayAngle = isFlipped ? angle - pi : angle;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // ทำให้ดูมีความลึก (3D)
            ..rotateX(displayAngle), // หมุนแกน X (พลิกบนลงล่าง)
          alignment: Alignment.center,
          child: _buildContent(isFlipped),
        );
      },
    );
  }

  Widget _buildContent(bool isFlipped) {
    // ถ้าพลิกแล้ว (isFlipped) ให้ใช้สีตามผลลัพธ์ (เขียว/เหลือง/เทา)
    // ถ้ายังไม่พลิก ให้ใช้สีขาว/ขอบเทา (เหมือนตอนพิมพ์)

    LetterStatus displayStatus = isFlipped ? widget.status : LetterStatus.entered;

    // Logic การเลือกสี (เหมือนเดิมแต่ย้ายมาในนี้)
    Color color = Colors.transparent;
    Color borderColor = widget.currentTheme.textColor.withOpacity(0.3);
    Color textColor = widget.currentTheme.textColor; // สีเริ่มต้นตามธีม

    if (displayStatus == LetterStatus.entered) {
      // ตอนยังไม่พลิก
      borderColor = filledBorderColor;
      // ถ้ายังไม่มีตัวอักษร ให้ใช้ขอบจาง
      if (widget.char.isEmpty) borderColor = widget.currentTheme.textColor.withOpacity(0.3);
    } else {
      // ตอนพลิกแล้ว (เฉลย)
      textColor = Colors.white;
      borderColor = Colors.transparent;
      switch (displayStatus) {
        case LetterStatus.correct: color = widget.currentTheme.correct; break;
        case LetterStatus.present: color = widget.currentTheme.present; break;
        case LetterStatus.absent: color = widget.currentTheme.absent; break;
        default: break;
      }
    }

    // จัดการสีพื้นหลังตอนเริ่ม (สำหรับธีมมืด)
    if (widget.currentTheme.brightness == Brightness.dark &&
        displayStatus == LetterStatus.initial) {
      color = Colors.white.withOpacity(0.05);
    }

    return Container(
      margin: const EdgeInsets.all(3),
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        widget.char,
        style: TextStyle(
            fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }
}
