import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ===== COLORES =====
class PanicColors {
  static const background = Color(0xFFF1F1F1); // Gris claro de fondo general
  static const primary = Color(0xFF8B0000); // Rojo serio principal
  static const primaryDark = Color(0xFF6A1B1B); // Rojo oscuro
  static const primaryLight = Color(0xFFB71C1C); // Rojo más claro
  static const accent = Color(0xFFFF0000); // Rojo brillante para alertas
  static const peach = Color(0xFFFFE5D9); // Fondo de paneles secundarios
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
      BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 5)),
    ],
  );

  static final menu = BoxDecoration(
    color: PanicColors.primary,
    borderRadius: BorderRadius.circular(25),
    boxShadow: const [
      BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4)),
    ],
  );

  static final modalButton = BoxDecoration(
    color: PanicColors.primary,
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
    ],
  );

  /// Animación sutil para botones de emergencia
  static Widget emergencyPulse(Widget child) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 600.ms,
          curve: Curves.easeInOut,
        );
  }
}
