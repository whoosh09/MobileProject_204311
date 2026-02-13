import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 1. จำเป็นสำหรับการอ่านไฟล์
import 'dart:math'; // 2. จำเป็นสำหรับการสุ่ม

// --- Constants & Enum (เหมือนเดิม) ---
const Color correctColor = Color(0xFF6AAA64);
const Color presentColor = Color(0xFFC9B458);
const Color absentColor = Color(0xFF787C7E);
const Color keyAbsentColor = Color(0xFF787C7E);
const Color defaultKeyColor = Color(0xFFD3D6DA);
const Color defaultBorderColor = Color(0xFFD3D6DA);
const Color filledBorderColor = Color(0xFF878A8C);

enum LetterStatus { initial, entered, correct, present, absent }

class WordleScreen extends StatefulWidget {
  const WordleScreen({super.key});

  @override
  State<WordleScreen> createState() => _WordleScreenState();
}

class _WordleScreenState extends State<WordleScreen> {
  // เปลี่ยนจาก final เป็น String ธรรมดา เพราะเราจะเปลี่ยนค่ามัน
  String targetWord = "";
  bool isLoading = true; // ตัวแปรเช็คสถานะการโหลดไฟล์

  List<String> guesses = List.filled(6, "");
  int currentRow = 0;
  List<List<LetterStatus>> gridStatus = List.generate(
      6,
          (_) => List.filled(5, LetterStatus.initial)
  );

  Map<String, LetterStatus> keyStatus = {};

  @override
  void initState() {
    super.initState();
    _loadTargetWord(); // เรียกฟังก์ชันโหลดคำเมื่อหน้าจอเริ่มทำงาน
  }

  // --- ฟังก์ชันใหม่: โหลดคำศัพท์จากไฟล์ ---
  Future<void> _loadTargetWord() async {
    try {
      // อ่านไฟล์จาก assets
      final String response = await rootBundle.loadString('assets/targetwords.txt');

      // แยกบรรทัดเป็น List
      List<String> words = response.split('\n');

      // Clean ข้อมูล: ตัดช่องว่าง, เอาเฉพาะคำที่มี 5 ตัวอักษร, ทำเป็นตัวใหญ่หมด
      List<String> validWords = words
          .map((w) => w.trim().toUpperCase())
          .where((w) => w.length == 5)
          .toList();

      if (validWords.isNotEmpty) {
        // สุ่มคำ
        final random = Random();
        setState(() {
          targetWord = validWords[random.nextInt(validWords.length)];
          isLoading = false; // โหลดเสร็จแล้ว
          print("Target Word: $targetWord"); // (Optional) แอบดูคำตอบใน Console
        });
      } else {
        // กรณีไฟล์ว่าง หรือไม่มีคำ 5 ตัวอักษร ให้ใช้ค่า Default
        setState(() {
          targetWord = "WORLD";
          isLoading = false;
        });
      }
    } catch (e) {
      // กรณีอ่านไฟล์ไม่ได้
      print("Error loading file: $e");
      setState(() {
        targetWord = "ERROR"; // หรือค่า Default อื่นๆ
        isLoading = false;
      });
    }
  }

  void onKeyPressed(String val) {
    if (currentRow >= 6 || isLoading) return; // เพิ่มเงื่อนไข isLoading

    setState(() {
      if (val == "ENTER") {
        _checkWord();
      } else if (val == "DEL") {
        if (guesses[currentRow].isNotEmpty) {
          guesses[currentRow] = guesses[currentRow].substring(0, guesses[currentRow].length - 1);
          gridStatus[currentRow][guesses[currentRow].length] = LetterStatus.initial;
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
    if (guesses[currentRow].length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not enough letters"), duration: Duration(milliseconds: 500)),
      );
      return;
    }

    String guess = guesses[currentRow];

    for (int i = 0; i < 5; i++) {
      String char = guess[i];
      LetterStatus status;

      if (targetWord[i] == char) {
        status = LetterStatus.correct;
      } else if (targetWord.contains(char)) {
        status = LetterStatus.present;
      } else {
        status = LetterStatus.absent;
      }

      gridStatus[currentRow][i] = status;

      if (keyStatus[char] != LetterStatus.correct) {
        if (status == LetterStatus.correct) {
          keyStatus[char] = LetterStatus.correct;
        } else if (keyStatus[char] != LetterStatus.present && status == LetterStatus.present) {
          keyStatus[char] = LetterStatus.present;
        } else if (keyStatus[char] == null && status == LetterStatus.absent) {
          keyStatus[char] = LetterStatus.absent;
        }
      }
    }

    currentRow++;

    // (Optional) เช็คชนะ/แพ้ ตรงนี้ได้
    if (guess == targetWord) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("YOU WON! 🎉")));
    } else if (currentRow == 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Game Over! Word was $targetWord")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // ถ้ากำลังโหลดไฟล์ ให้หมุนติ้วๆ ไปก่อน
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
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          const Divider(height: 1),
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

  // ... (ส่วน _buildGrid และ _buildKeyboard เหมือนเดิมเป๊ะ ไม่ต้องแก้ครับ) ...
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
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
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
                    case LetterStatus.correct: keyColor = correctColor; break;
                    case LetterStatus.present: keyColor = presentColor; break;
                    case LetterStatus.absent: keyColor = keyAbsentColor; break;
                    default: keyColor = defaultKeyColor; textColor = Colors.black;
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
                            ? Icon(Icons.backspace_outlined, size: 20, color: textColor)
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