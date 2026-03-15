/*
 * File: audio_helper.dart
 * Description: Provides centralised audio playback and haptic feedback
 * utilities for the Quackle application via a single shared AudioPlayer.
 *
 * Responsibilities:
 * - Plays sound effects from the assets/sounds/ directory
 * - Provides haptic feedback wrappers that respect user preferences
 * - All methods are static and gated by the User's sound/vibration settings
 *
 * Dependencies:
 * - audioplayers
 * - flutter/services (HapticFeedback, SystemSound)
 * - User (mock_data.dart)
 *
 * Notes:
 * - No UI logic should appear in this file
 * - Uses async network/disk operations; errors are caught and printed
 *
 * Author: Quackle Team
 * Course: 204311-Mobile Application Development Framework
 */

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../models/mock_data.dart';

/// Static utility class for all sound effects and haptic feedback.
///
/// All playback methods check [User.isSoundEnabled] or [User.isVibrationEnabled]
/// before performing any action, ensuring user preferences are always respected.
class AppFeedback {

  static final AudioPlayer _player = AudioPlayer();

  /// Plays the system click sound if [user] has sound enabled.
  static void playSystemClick(User user) {
    if (user.isSoundEnabled) SystemSound.play(SystemSoundType.click);
  }

  /// Plays an audio asset from `assets/sounds/[fileName]`.
  ///
  /// Does nothing when [isEnabled] is `false`. Catches and prints any
  /// playback errors to avoid crashing the UI.
  static Future<void> _playSound(String fileName, bool isEnabled) async {
    if (isEnabled) {
      try {
        await _player.play(AssetSource('sounds/$fileName'));
      } catch (e) {
        print("Audio Error: $e");
      }
    }
  }

  /// Plays the button-click sound effect.
  static void playClick(User user) {
    _playSound('buttonclick.mp3', user.isSoundEnabled);
  }

  /// Plays the flashcard flip sound effect.
  static void playFlip(User user) {
    _playSound('flipcard.mp3', user.isSoundEnabled);
  }

  /// Plays the win/victory jingle.
  static void playWin(User user) {
    _playSound('win.mp3', user.isSoundEnabled);
  }

  /// Plays the lose/game-over sound effect.
  static void playLose(User user) {
    _playSound('lose.mp3', user.isSoundEnabled);
  }

  /// Plays the game-start fanfare.
  static void playStartGame(User user) {
    _playSound('play.mp3', user.isSoundEnabled);
  }

  /// Plays the keyboard key-tap sound effect.
  static void playKeyboardTap(User user) {
    _playSound('keyboard_sound.ogg', user.isSoundEnabled);
  }

  /// Plays the coin/purchase sound effect.
  static void playCash(User user) {
    _playSound('buy.mp3', user.isSoundEnabled);
  }

  /// Plays the correct-answer chime.
  static void playCorrect(User user) {
    _playSound('correct.mp3', user.isSoundEnabled);
  }

  /// Plays the wrong-answer buzz.
  static void playWrong(User user) {
    _playSound('wrong.mp3', user.isSoundEnabled);
  }

  /// Triggers a medium haptic impact if [user] has vibration enabled.
  static void triggerHaptic(User user) {
    if (user.isVibrationEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  /// Plays a system click sound and triggers a light haptic impact,
  /// both gated by the user's respective preference settings.
  static void triggerSuccess(User user) {
    if (user.isSoundEnabled) SystemSound.play(SystemSoundType.click);
    if (user.isVibrationEnabled) HapticFeedback.lightImpact();
  }
}
