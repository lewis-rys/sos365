import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ===== COLORES =====
class PanicColors {
  static const background = Color(0xFFF1F1F1);
  static const primary = Color(0xFF8B0000);
  static const primaryDark = Color(0xFF6A1B1B);
  static const primaryLight = Color(0xFFB71C1C);
  static const accent = Color(0xFFFF0000);
  static const peach = Color.fromARGB(255, 255, 255, 255);
}

/// ===== TIPOGRAFÍA =====
class PanicTextStyles {
  static const title = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    color: Colors.black87,
  );

  static const subtitle = TextStyle(fontSize: 14, color: Colors.black54);

  static const buttonTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
}

/// ===== DECORACIONES =====
class PanicDecorations {
  static BoxDecoration card = BoxDecoration(
    color: PanicColors.peach,
    borderRadius: BorderRadius.circular(22),
    boxShadow: const [
      BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6)),
    ],
  );

  static InputDecoration inputDecoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PanicColors.primary, width: 2),
      ),
    );
  }

  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: PanicColors.primary,
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static Widget fadeIn(Widget child) {
    return child.animate().fade(duration: 400.ms).moveY(begin: 20, end: 0);
  }
}
