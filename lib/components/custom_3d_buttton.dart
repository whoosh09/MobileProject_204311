import 'package:flutter/material.dart';

enum ButtonState { normal, correct, incorrect }

class Custom3DButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color shadowColor;
  final double height;
  final double width;
  final ButtonState state;
  final Color? textColor;
  final TextStyle? style; // 🆕 Added style support

  const Custom3DButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.shadowColor,
    this.height = 55.0,
    this.width = double.infinity,
    this.state = ButtonState.normal,
    this.textColor,
    this.style,
  });

  @override
  State<Custom3DButton> createState() => _Custom3DButtonState();
}

class _Custom3DButtonState extends State<Custom3DButton> {
  bool _isPressed = false;

  Color get _resolvedBgColor {
    switch (widget.state) {
      case ButtonState.correct:   return Colors.green.shade500;
      case ButtonState.incorrect: return Colors.red.shade500;
      case ButtonState.normal:    return widget.backgroundColor;
    }
  }

  Color get _resolvedShadowColor {
    switch (widget.state) {
      case ButtonState.correct:   return Colors.green.shade800;
      case ButtonState.incorrect: return Colors.red.shade800;
      case ButtonState.normal:    return widget.shadowColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) async {
        setState(() => _isPressed = false);
        await Future.delayed(const Duration(milliseconds: 100));
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: Stack(
          children: [
            Positioned(
              top: 5, bottom: 0, left: 0, right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: _resolvedShadowColor,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              top: _isPressed ? 5.0 : 0.0,
              bottom: _isPressed ? 0.0 : 5.0,
              left: 0, right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _resolvedBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    style: (widget.style ?? const TextStyle()).copyWith(
                      color: widget.textColor ?? Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
