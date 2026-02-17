/*
 * File: game_screen.dart
 * Description: The core gameplay screen for the Wordle-style game.
 *
 * Responsibilities:
 * - Implements game logic (Word guessing, 6 attempts limitation)
 * - Loads game assets (Target words and Valid dictionary from .txt files)
 * - Validates user guesses against a dictionary and checks for double-letter logic
 * - Renders the game grid and interactive keyboard with color feedback
 * - Updates user rewards (Coins/Stats) and saves data upon winning
 *
 *
 * Author: Detnarin Karinchai
 * Course: Mobile Application Development Framework
 */
import 'package:translator/translator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'mock_data.dart';

const Color correctColor = Color(0xFF6AAA64);
const Color presentColor = Color(0xFFC9B458);
const Color absentColor = Color(0xFF787C7E);
const Color keyAbsentColor = Color(0xFF787C7E);
const Color defaultKeyColor = Color(0xFFD3D6DA);
const Color defaultBorderColor = Color(0xFFD3D6DA);
const Color filledBorderColor = Color(0xFF878A8C);

enum LetterStatus { initial, entered, correct, present, absent }

class WordleScreen extends StatefulWidget {
  final User currentUser; // เพิ่มตัวรับ User
  const WordleScreen({super.key, required this.currentUser});

  @override
  State<WordleScreen> createState() => _WordleScreenState();
}

class _WordleScreenState extends State<WordleScreen> {
  final translator = GoogleTranslator();
  String targetWord = "";
  // เพิ่ม Set สำหรับเก็บคำศัพท์ทั้งหมด เพื่อใช้ตรวจสอบว่ามีคำนี้จริงไหม
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
    _loadGameData();
  }

  // --- โหลดข้อมูลทั้ง 2 ไฟล์พร้อมกัน ---
  Future<void> _loadGameData() async {
    try {
      // โหลด 2 ไฟล์พร้อมกันเพื่อความเร็ว
      final results = await Future.wait([
        rootBundle.loadString('assets/targetwords.txt'),
        rootBundle.loadString('assets/validwords.txt'),
      ]);

      final String targetContent = results[0];
      final String validContent = results[1];

      // เตรียม List คำตอบ (Target)
      List<String> targets = targetContent.split('\n')
          .map((w) => w.trim().toUpperCase())
          .where((w) => w.length == 5)
          .toList();

      // อันนี้เตรียม Dictionary (กูใช้ Set จะได้ให้ค้นหาเร็ว O(1))
      List<String> valids = validContent.split('\n')
          .map((w) => w.trim().toUpperCase())
          .where((w) => w.length == 5)
          .toList();

      setState(() {
        // เลือกคำตอบ
        if (targets.isNotEmpty) {
          targetWord = targets[Random().nextInt(targets.length)];
        } else {
          targetWord = "WORLD"; //กันไว้
        }

        // สร้าง Dictionary (เอาคำตอบมารวมด้วย กันพลาดกรณีคำตอบไม่อยู่ใน dict)
        validWordsDict = valids.toSet();
        validWordsDict.addAll(targets); 

        isLoading = false;
        print("Target: $targetWord"); //ดูคำตอบใน Consoleได้
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

  void _checkWord() {
    String guess = guesses[currentRow];
    // เช็คความยาวตอนผู้เล่นพิมพ์ไม่ครบแต่กดส่ง
    if (guess.length != 5) {
      _showMessage("Not enough letters");
      return;
    }
    //  เช็คว่ามีคำนี้ใน Dictionary มั้ย
    if (!validWordsDict.contains(guess)) {
      _showMessage("Not in word list");
      // สั่งให้ Grid สั่น (Optional) หรือแค่แจ้งเตือนก็ได้
      return; 
    }

    // --- Logic ตรวจสี ---
    List<String> targetChars = targetWord.split('');
    List<LetterStatus> rowStatus = List.filled(5, LetterStatus.absent);

    // รอบที่ 1 สีเขียว (Correct)
    for (int i = 0; i < 5; i++) {
      if (guess[i] == targetChars[i]) {
        rowStatus[i] = LetterStatus.correct;
        targetChars[i] = '';
      }
    }

    // รอบที่ 2 สีเหลือง (Present)
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

    // อัปเดต Grid และ Keyboard
    setState(() {
      for (int i = 0; i < 5; i++) {
        gridStatus[currentRow][i] = rowStatus[i];
      }

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

      currentRow++;
    });

    var translation = translator.translate(targetWord, to: 'th');
    // String thaiMeaning = translation.text;
    String message = "✨ Y O U  W O N ! ✨\n\n"
        "ศัพท์: $targetWord\n"
    // "แปล: $thaiMeaning\n\n"
        "💰 รับรางวัล +10 Coins";
    // เช็คแพ้/ชนะ


    if (guess == targetWord) {
      setState(() {
        widget.currentUser.coins += 10;
        widget.currentUser.wordsFound += 1;
        if (!widget.currentUser.foundWordsList.contains(targetWord)) {
          widget.currentUser.foundWordsList.add(targetWord);
        }
      });
      widget.currentUser.saveData();
      _showEndGameDialog(true, targetWord);
      //_showEndGameDialog(true, targetWord, translation.text);
    } else if (currentRow == 6) {
      _showEndGameDialog(false, targetWord);
    }
  }
  
  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars(); // ลบอันเก่าออกก่อนเพื่อให้ขึ้นอันใหม่ทันที
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center),
        duration: const Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
        backgroundColor: Colors.black87,
      ),
    );
  }

  // ปรับแก้ parameter ให้รับคำศัพท์และคำแปล
  void _showEndGameDialog(bool won, String targetWord) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            // แสดงไอคอนตามผลแพ้/ชนะ
            Icon(
              won ? Icons.emoji_events_rounded : Icons.cancel_outlined,
              color: won ? Colors.amber : Colors.redAccent,
              size: 60,
            ),
            const SizedBox(height: 10),
            Text(
              won ? "Nicega! (You Won)" : "Oh no! (Game Over)",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: won ? correctColor : Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        // ส่วนเนื้อหา: จัดคำศัพท์และคำแปลให้สวยงาม
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("The answer was", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 5),
            Text(
              targetWord.toUpperCase(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "test meaning",
              // meaning, // แสดงคำแปลภาษาไทยตรงนี้
              style: const TextStyle(fontSize: 18, color: Colors.blueAccent),
              textAlign: TextAlign.center,
            ),
            if (won) ...[ // ถ้าชนะ ให้โชว์เหรียญที่ได้ด้วย
              const Divider(height: 30),
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
                backgroundColor: won ? correctColor : Colors.grey,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(context); // ปิด Dialog
                Navigator.pop(context); // กลับหน้า Home
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
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "WORDLE",
          style: TextStyle(
              fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade300, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: _buildGrid(),
            ),
          ),
          Expanded(
            flex: 1,
            child: _buildKeyboard(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
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
              return _buildCell(char, gridStatus[rowIndex][colIndex]);
            }),
          ),
        );
      }),
    );
  }

  Widget _buildCell(String char, LetterStatus status) {
    Color color = Colors.white;
    Color borderColor = defaultBorderColor;
    Color textColor = Colors.black;

    switch (status) {
      case LetterStatus.correct:
        color = correctColor;
        borderColor = Colors.transparent;
        textColor = Colors.white;
        break;
      case LetterStatus.present:
        color = presentColor;
        borderColor = Colors.transparent;
        textColor = Colors.white;
        break;
      case LetterStatus.absent:
        color = absentColor;
        borderColor = Colors.transparent;
        textColor = Colors.white;
        break;
      case LetterStatus.entered:
        borderColor = filledBorderColor;
        textColor = Colors.black;
        break;
      case LetterStatus.initial:
        break;
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
        char,
        style: TextStyle(
            fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildKeyboard() {
    const keys = [
      ["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
      ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
      ["ENTER", "Z", "X", "C", "V", "B", "N", "M", "DEL"]
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: keys.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((char) {
              Color keyColor = defaultKeyColor;
              Color textColor = Colors.black;

              if (char != "ENTER" && char != "DEL") {
                LetterStatus? status = keyStatus[char];
                if (status != null) {
                  textColor = Colors.white;
                  switch (status) {
                    case LetterStatus.correct:
                      keyColor = correctColor;
                      break;
                    case LetterStatus.present:
                      keyColor = presentColor;
                      break;
                    case LetterStatus.absent:
                      keyColor = keyAbsentColor;
                      break;
                    default:
                      keyColor = defaultKeyColor;
                      textColor = Colors.black;
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