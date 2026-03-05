import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class Custom3DKey extends StatefulWidget {
  final String char;
  final Color keyColor;
  final Color textColor;
  final int flex;
  final VoidCallback onTap;

  const Custom3DKey({
    super.key,
    required this.char,
    required this.keyColor,
    required this.textColor,
    required this.flex,
    required this.onTap,
  });

  @override
  State<Custom3DKey> createState() => _Custom3DKeyState();
}

class _Custom3DKeyState extends State<Custom3DKey> {
  bool _isPressed = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();


    _audioPlayer.play(AssetSource('keyboard_sound.ogg'), volume: 1);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: widget.flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            height: 45.0,
            margin: EdgeInsets.only(
              top: _isPressed ? 4.0 : 0.0,
              bottom: _isPressed ? 0.0 : 4.0,
            ),
            decoration: BoxDecoration(
              color: widget.keyColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: _isPressed
                  ? []
                  : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: widget.char == "DEL"
                ? Icon(Icons.backspace_outlined, size: 22, color: widget.textColor)
                : Text(
              widget.char,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: widget.char == "ENTER" ? 12 : 16,
                color: widget.textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
