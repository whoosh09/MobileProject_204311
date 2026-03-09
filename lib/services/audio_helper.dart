import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../models/mock_data.dart';

class AppFeedback {
  // เสียงคลิกมาตรฐาน
  // static void playClick(User user) {
  //   if (user.isSoundEnabled) {
  //     SystemSound.play(SystemSoundType.click);
  //   }
  // }
  // สร้าง Player ตัวเดียวใช้ร่วมกัน
  static final AudioPlayer _player = AudioPlayer();

  // เสียงจากระบบ (เผื่อเลือกใช้)
  static void playSystemClick(User user) {
    if (user.isSoundEnabled) SystemSound.play(SystemSoundType.click);
  }

  // ฟังก์ชันกลางสำหรับเล่นเสียง
  static Future<void> _playSound(String fileName, bool isEnabled) async {
    if (isEnabled) {
      try {
        // ใส่แค่ sounds/ เพราะ AssetSource จะวิ่งไปที่ folder assets ให้เอง
        await _player.play(AssetSource('sounds/$fileName'));
      } catch (e) {
        print("Audio Error: $e");
      }
    }
  }

  static void playClick(User user) {
    _playSound('buttonclick.mp3', user.isSoundEnabled);
  }

  static void playFlip(User user) {
    _playSound('flipcard.mp3', user.isSoundEnabled);
  }

  static void playWin(User user) {
    _playSound('win.mp3', user.isSoundEnabled);
  }

  static void playLose(User user) {
    _playSound('lose.mp3', user.isSoundEnabled);
  }

  static void playStartGame(User user) {
    _playSound('play.mp3', user.isSoundEnabled);
  }

  static void playKeyboardTap(User user) {
    _playSound('keyboard_sound.ogg', user.isSoundEnabled);
  }

  // การสั่นมาตรฐาน
  static void triggerHaptic(User user) {
    if (user.isVibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  // เสียงและสั่นตอน "พิมพ์ตัวอักษร" หรือ "สำเร็จ"
  static void triggerSuccess(User user) {
    if (user.isSoundEnabled) SystemSound.play(SystemSoundType.click);
    if (user.isVibrationEnabled) HapticFeedback.lightImpact();
  }

  // static Future<void> _playFile(String fileName, bool isEnabled) async {
  //   if (isEnabled) {
  //     try {
  //       print("🔊 Attempting to play: sounds/$fileName"); // ดูใน Console ว่าบรรทัดนี้ขึ้นไหม
  //       await _player.stop();
  //       await _player.play(AssetSource('sounds/$fileName'));
  //     } catch (e) {
  //       print("❌ Audio Error: $e");
  //     }
  //   }
  // }
}