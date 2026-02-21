import 'package:flutter/material.dart';

class Custom3DButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color shadowColor;
  final double height;
  final double width;

  const Custom3DButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    required this.shadowColor,
    this.height = 55.0, // Default height
    this.width = double.infinity, // Defaults to stretching full width
  });

  @override
  State<Custom3DButton> createState() => _Custom3DButtonState();
}

class _Custom3DButtonState extends State<Custom3DButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) async {
        setState(() => _isPressed = false);
        // Wait for the bounce back up before triggering the action
        await Future.delayed(const Duration(milliseconds: 100));
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: Stack(
          children: [
            // BOTTOM SHADOW LAYER
            Positioned(
              top: 5,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.shadowColor, // Uses the color you pass in
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            // TOP FACE LAYER
            AnimatedPositioned(
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              top: _isPressed ? 5.0 : 0.0,
              bottom: _isPressed ? 0.0 : 5.0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: widget.backgroundColor, // Uses the color you pass in
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    widget.text, // Uses the text you pass in
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
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