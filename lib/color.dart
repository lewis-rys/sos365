import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ===== COLORES Y ESTILOS =====
class PanicColors {
  static const background = Color(0xFFF1F1F1); // Fondo general
  static const primary = Color(0xFF8B0000); // Rojo principal
  static const primaryDark = Color(0xFF6A1B1B);
  static const primaryLight = Color(0xFFB71C1C);
  static const accent = Color(0xFFFF0000);
}

class PanicTextStyles {
  static const title = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: 2,
    color: Colors.red,
  );

  static const subtitle = TextStyle(fontSize: 14, color: Colors.black54);

  static const buttonTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const sliderText = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static const modalButtonText = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );
}

/// ===== DECORACIONES =====
class PanicDecorations {
  static final slider = BoxDecoration(
    gradient: const LinearGradient(
      colors: [PanicColors.primaryDark, PanicColors.primaryLight],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    borderRadius: BorderRadius.circular(40),
    boxShadow: const [
      BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
    ],
  );

  static const knob = BoxDecoration(
    color: Colors.black,
    shape: BoxShape.circle,
  );

  static const emergencyButton = BoxDecoration(
    color: PanicColors.primary,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(color: Colors.redAccent, blurRadius: 30, spreadRadius: 6),
    ],
  );

  static final menu = BoxDecoration(
    color: PanicColors.primary,
    borderRadius: BorderRadius.circular(30),
    boxShadow: const [
      BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4)),
    ],
  );

  static final modalButton = BoxDecoration(
    color: PanicColors.primary,
    borderRadius: BorderRadius.circular(15),
    boxShadow: const [
      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
    ],
  );

  /// Animación pulsante para botones de emergencia
  static Animate emergencyPulse(Widget child) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: 600.ms,
          curve: Curves.easeInOut,
        );
  }
}
