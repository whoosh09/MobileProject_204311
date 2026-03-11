import 'package:flutter/material.dart';

enum ButtonState { normal, correct, incorrect }

class Custom3DButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final ButtonState state;

  // 🆕 นำสีกลับมาเพื่อให้หน้าอื่นๆ ไม่ Error (ตั้งให้เป็นตัวเลือก Nullable)
  final Color? backgroundColor;
  final Color? shadowColor;
  final Color textColor;

  const Custom3DButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.state = ButtonState.normal,
    this.backgroundColor, // เปิดรับสีจากหน้าอื่นๆ
    this.shadowColor,     // เปิดรับเงาจากหน้าอื่นๆ
    this.textColor = Colors.white,
  });

  @override
  State<Custom3DButton> createState() => _Custom3DButtonState();
}

class _Custom3DButtonState extends State<Custom3DButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // 1. ดึงสีเริ่มต้น: ถ้าหน้าไหนส่ง backgroundColor มาให้ใช้สีนั้น
    // แต่ถ้าไม่ส่งมา ให้ใช้สีเทาเป็นค่าเริ่มต้น
    Color bgColor = widget.backgroundColor ?? const Color(0xFFF0F0F0);
    Color shadowCol = widget.shadowColor ?? const Color(0xFFD6D6D6);
    Color txtColor = widget.textColor;

    // 2. ถ้าเป็นหน้า Flashcard แล้วมีการตอบถูก/ผิด ให้เขียนทับสีด้วย State
    if (widget.state == ButtonState.correct) {
      bgColor = Colors.green;
      shadowCol = Colors.green.shade700;
      txtColor = Colors.white;
    } else if (widget.state == ButtonState.incorrect) {
      bgColor = Colors.redAccent;
      shadowCol = Colors.red.shade800;
      txtColor = Colors.white;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.width,
        margin: EdgeInsets.only(top: _isPressed ? 6.0 : 0.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: shadowCol,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: txtColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
