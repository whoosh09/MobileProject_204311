import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  /// A smart style that automatically applies Kanit for Thai characters
  /// while falling back to the default font (DINNextRounded) for English.
  static TextStyle smartStyle(String text, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) {
    // Check if the string contains any Thai characters
    bool hasThai = RegExp(r'[\u0E00-\u0E7F]').hasMatch(text);

    if (hasThai) {
      return GoogleFonts.kanit(
        fontSize: fontSize,
        fontWeight: fontWeight ?? FontWeight.w500, // Thai looks better a bit lighter
        color: color,
        // We usually don't set letterSpacing for Thai as it can look weird
      );
    } else {
      return TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );
    }
  }
}
