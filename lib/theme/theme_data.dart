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
      correct: const Color(0xFF58CC02),
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
      present: const Color(0xFFFFD166),
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
      correct: const Color(0xFF81C784),
      present: const Color(0xFFFFD166),
      absent: Colors.grey.shade500,
      // UI Colors (พื้นหลังเทาเข้ม)
      backgroundColor: const Color(0xFF212121),
      textColor: Colors.white70,
      brightness: Brightness.dark,
    ),
    // 5. ธีมมิดไนท์ (มืดสนิท)
    GameTheme(
      id: 'midnight',
      name: 'Midnight Purple',
      price: 300,
      correct: const Color(0xFF9D50BB),
      present: const Color(0xFF6E48AA),
      absent: const Color(0xFF2D3436),
      backgroundColor: const Color(0xFF0F0C29),
      textColor: Colors.white,
      brightness: Brightness.dark,
    ),
    // 6. ธีมซากุระ (พาสเทลชมพู)
    GameTheme(
      id: 'sakura',
      name: 'Sakura Blossom',
      price: 400,
      correct: const Color(0xFFFF7597),
      present: const Color(0xFFFFB7B2),
      absent: const Color(0xFFE0E0E0),
      backgroundColor: const Color(0xFFFFF0F3),
      textColor: const Color(0xFFC9184A),
      brightness: Brightness.light,
    ),
    // 7. ธีมมหาสมุทร (เย็นตา)
    GameTheme(
      id: 'ocean',
      name: 'Deep Ocean',
      price: 500,
      correct: const Color(0xFF0077B6),
      present: const Color(0xFF90E0EF),
      absent: const Color(0xFFCFD8DC),
      backgroundColor: const Color(0xFFCAF0F8),
      textColor: const Color(0xFF03045E),
      brightness: Brightness.light,
    ),
    // 8. ธีมลาวา (ดุเดือด)
    GameTheme(
      id: 'lava',
      name: 'Volcanic Lava',
      price: 1000,
      correct: const Color(0xFFD00000),
      present: const Color(0xFFFF8C00),
      absent: const Color(0xFF3D3D3D),
      backgroundColor: const Color(0xFF1A1A1A),
      textColor: const Color(0xFFFFE3E3),
      brightness: Brightness.dark,
    ),
  ];

  static GameTheme getTheme(String id) {
    return themes.firstWhere((t) => t.id == id, orElse: () => themes[0]);
  }
}
