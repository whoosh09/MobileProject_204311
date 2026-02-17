import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ต้องใช้สำหรับ SystemUiOverlayStyle

class GameTheme {
  final String id;
  final String name;
  final int price;

  final Color correct;   // สีถูก (เขียว)
  final Color present;   // สีเกือบถูก (เหลือง)
  final Color absent;    // สีผิด (เทา)

  // --- สีสำหรับ UI โดยรวม (เพิ่มใหม่) ---
  final Color backgroundColor; // สีพื้นหลังแอป
  final Color textColor;       // สีตัวอักษรตรง Appbar/Heading
  final Brightness brightness; // ความสว่าง (เพื่อปรับสี icon status bar มือถือ)
  GameTheme({
    required this.id,
    required this.name,
    required this.price,
    required this.correct,
    required this.present,
    required this.absent,
    // รับค่าสี UI ใหม่
    required this.backgroundColor,
    required this.textColor,
    required this.brightness,
  });
}

class ThemeDatabase {
  static List<GameTheme> themes = [
    // 1. ธีมคลาสสิก (สว่าง)
    GameTheme(
      id: 'classic',
      name: 'Classic Green',
      price: 0,
      correct: const Color(0xFF6AAA64),
      present: const Color(0xFFC9B458),
      absent: const Color(0xFF787C7E),
      // UI Colors
      backgroundColor: Colors.white,
      textColor: Colors.black,
      brightness: Brightness.light,
    ),
    // 2. ธีมพาสเทล (สว่าง)
    GameTheme(
      id: 'pastel',
      name: 'Sweet Pastel',
      price: 50,
      correct: const Color(0xFF88C9A1),
      present: const Color(0xFFFFD166),
      absent: Colors.grey.shade500,
      // UI Colors (พื้นหลังสีครีมอ่อนๆ)
      backgroundColor: const Color(0xFFFFFBE6),
      textColor: Colors.brown,
      brightness: Brightness.light,
    ),
    // 3. ธีมนีออน (มืด)
    GameTheme(
      id: 'neon',
      name: 'Cyber Neon',
      price: 100,
      correct: const Color(0xFF00FF00),
      present: const Color(0xFFFF00FF),
      absent: Colors.grey.shade500,
      // UI Colors (พื้นหลังดำสนิท)
      backgroundColor: const Color(0xFF121212),
      textColor: Colors.white,
      brightness: Brightness.dark,
    ),
    // 4. ธีมดาร์ก (มืด)
    GameTheme(
      id: 'dark',
      name: 'Dark Mode',
      price: 200,
      correct: Color(0xFF81C784),
      present: Colors.purpleAccent,
      absent: Colors.grey.shade500,
      // UI Colors (พื้นหลังเทาเข้ม)
      backgroundColor: const Color(0xFF212121),
      textColor: Colors.white70,
      brightness: Brightness.dark,
    ),
  ];

  static GameTheme getTheme(String id) {
    return themes.firstWhere((t) => t.id == id, orElse: () => themes[0]);
  }
}