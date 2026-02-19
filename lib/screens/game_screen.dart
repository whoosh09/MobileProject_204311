/*
 * File: game_screen.dart
 * Description: The core gameplay screen.
 * Updated: FIXED Compilation Errors (appBarColor, Arguments, Constants)
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'mock_data.dart';
import 'theme_data.dart';
import 'package:translator/translator.dart';

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
  final translator = GoogleTranslator();
  late GameTheme currentTheme;

  String targetWord = "";
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
        rootBundle.loadString('assets/targetwords.txt'),
        rootBundle.loadString('assets/validwords.txt'),
      ]);

      final String targetContent = results[0];
      final String validContent = results[1];

      List<String> targets = targetContent.split('\n')
          .map((w) => w.trim().toUpperCase())
          .where((w) => w.length == 5)
          .toList();

      List<String> valids = validContent.split('\n')
          .map((w) => w.trim().toUpperCase())
          .where((w) => w.length == 5)
          .toList();

      setState(() {
        if (targets.isNotEmpty) {
          targetWord = targets[Random().nextInt(targets.length)];
        } else {
          targetWord = "WORLD";
        }
        validWordsDict = valids.toSet();
        validWordsDict.addAll(targets);
        isLoading = false;
        print("Target: $targetWord");
      });
    } catch (e) {
      print("Error loading files: $e");
      setState(() {
        targetWord = "ERROR";
        isLoading = false;
      });
    }
  }

  void onKeyPressed(String val) {
    if (currentRow >= 6 || isLoading) return;

    setState(() {
      if (val == "ENTER") {
        _checkWord();
      } else if (val == "DEL") {
        if (guesses[currentRow].isNotEmpty) {
          guesses[currentRow] =
              guesses[currentRow].substring(0, guesses[currentRow].length - 1);
          gridStatus[currentRow][guesses[currentRow].length] =
              LetterStatus.initial;
        }
      } else {
        if (guesses[currentRow].length < 5) {
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
      return;
    }
    if (!validWordsDict.contains(guess)) {
      _showMessage("Not in word list");
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
    var translation = await translator.translate(targetWord, to: 'th');
    if (guess == targetWord) {
      setState(() {
        widget.currentUser.coins += 10;
        widget.currentUser.wordsFound += 1;
        if (!widget.currentUser.foundWordsList.contains(targetWord)) {
          widget.currentUser.foundWordsList.add(targetWord);
        }
      });
      widget.currentUser.saveData();
      _showEndGameDialog(true, targetWord, translation.text);

    } else if (currentRow == 6) {
      _showEndGameDialog(false, targetWord, translation.text);
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

  void _showEndGameDialog(bool won, String targetWord, String meaning) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: currentTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(
              won ? Icons.emoji_events_rounded : Icons.cancel_outlined,
              color: won ? currentTheme.correct : Colors.redAccent,
              size: 60,
            ),
            const SizedBox(height: 10),
            Text(
              won ? "Nicega! (You Won)" : "Oh no! (Game Over)",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: won ? currentTheme.correct : Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("The answer was", style: TextStyle(color: currentTheme.textColor.withOpacity(0.7))),
            const SizedBox(height: 5),
            Text(
              targetWord.toUpperCase(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: currentTheme.textColor,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              meaning,
              style: const TextStyle(fontSize: 18, color: Colors.blueAccent),
              textAlign: TextAlign.center,
            ),
            if (won) ...[
              Divider(height: 30, color: currentTheme.textColor.withOpacity(0.2)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "💰 +10 Coins",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown),
                ),
              ),
            ]
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: won ? currentTheme.correct : currentTheme.absent,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Back to Menu", style: TextStyle(color: Colors.white)),
            ),
          )
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
          "WORDLE",
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

              return Expanded(
                flex: (char == "ENTER" || char == "DEL") ? 2 : 1,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Material(
                    color: keyColor,
                    borderRadius: BorderRadius.circular(4),
                    child: InkWell(
                      onTap: () => onKeyPressed(char),
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        child: char == "DEL"
                            ? Icon(Icons.backspace_outlined,
                            size: 20, color: textColor)
                            : Text(
                          char,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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

  const FlipTile({
    super.key,
    required this.char,
    required this.status,
    required this.currentTheme,
    required this.delayIndex,
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

    // เช็คว่าสถานะเปลี่ยนจาก "พิมพ์เฉยๆ" เป็น "เฉลยผล" หรือไม่
    if (widget.status != oldWidget.status &&
        widget.status != LetterStatus.initial &&
        widget.status != LetterStatus.entered) {

      // ถ่วงเวลาตามลำดับช่อง (ช่องแรกเริ่มเลย, ช่องสองรอ 200ms, ...)
      Future.delayed(Duration(milliseconds: widget.delayIndex * 200), () {
        if (mounted) {
          _controller.forward(from: 0.0);
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