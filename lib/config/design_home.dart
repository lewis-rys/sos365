import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PanicColors {
  static const background = Color(0xFFF5F5F5);

  static const primary = Color(0xFFD50000);
  static const primaryDark = Color(0xFFB71C1C);
  static const primaryLight = Color(0xFFFF3B3B);

  static const accent = Color(0xFFFF1744);

  static const modalBackground = Color(0xFFFFFFFF);

  static const sliderKnob = Color(0xFFFFFFFF);

  static const menuBackground = Color(0xFFD50000);
}

class PanicTextStyles {
  static const title = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: Color.fromRGBO(0, 0, 0, 0.87),
    fontFamily: 'Roboto',
  );

  static const subtitle = TextStyle(
    fontSize: 15,
    color: Colors.black54,
    fontFamily: 'Roboto',
  );

  static const buttonTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: 'Roboto',
  );

  static const sliderText = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  static const modalButtonText = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    fontFamily: 'Roboto',
  );

  static const inputLabel = TextStyle(
    fontSize: 14,
    color: Colors.black87,
    fontWeight: FontWeight.w600,
    fontFamily: 'Roboto',
  );
}

class PanicDecorations {
  static final slider = BoxDecoration(
    gradient: const LinearGradient(
      colors: [PanicColors.primaryDark, PanicColors.primary],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    borderRadius: BorderRadius.circular(36),
    boxShadow: const [
      BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
    ],
  );

  static const knob = BoxDecoration(
    color: PanicColors.sliderKnob,
    shape: BoxShape.circle,
    boxShadow: const [
      BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 2)),
    ],
  );

  static const emergencyButton = BoxDecoration(
    gradient: const LinearGradient(
      colors: [PanicColors.primaryDark, PanicColors.primary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    shape: BoxShape.circle,
    boxShadow: const [
      BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 5)),
    ],
  );

  static final menu = BoxDecoration(
    color: PanicColors.menuBackground,
    borderRadius: BorderRadius.circular(25),
    boxShadow: const [
      BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4)),
    ],
  );

  static final modalContainer = BoxDecoration(
    color: PanicColors.modalBackground,
    borderRadius: BorderRadius.circular(16),
    boxShadow: const [
      BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6)),
    ],
  );

  static final card = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
    ],
  );

  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: PanicColors.primary,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static Widget emergencyPulse(Widget child) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: PanicColors.primary.withOpacity(0.6),
                    blurRadius: 35,
                    spreadRadius: 6,
                  ),
                  BoxShadow(
                    color: PanicColors.primaryLight.withOpacity(0.4),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.08, 1.08),
              duration: 1000.ms,
              curve: Curves.easeInOut,
            ),

        child
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.05, 1.05),
              duration: 1000.ms,
              curve: Curves.easeInOut,
            ),
      ],
    );
  }
}

class PanicDesign {
  static const background = PanicColors.background;

  static const screenPadding = EdgeInsets.symmetric(vertical: 20);

  static Widget header(String nombreUsuario) {
    return Column(
      children: [
        Text("Hola $nombreUsuario", style: PanicTextStyles.subtitle),
        const SizedBox(height: 6),
        const Text("EMERGENCIA", style: PanicTextStyles.title),
        const SizedBox(height: 6),
        const Text(
          "Uso exclusivo en situaciones reales",
          style: PanicTextStyles.subtitle,
        ),
        const Text("SOS365 - Disponible 24/7", style: PanicTextStyles.subtitle),
      ],
    );
  }

  static Widget slider({
    required double sliderPosition,
    required double sliderWidth,
    required double knobSize,
    required Function(DragUpdateDetails) onDragUpdate,
    required VoidCallback onDragEnd,
  }) {
    return Center(
      child: Container(
        width: sliderWidth,
        height: 65,
        decoration: PanicDecorations.slider,
        child: Stack(
          children: [
            const Center(
              child: Text(
                "Desliza para llamar 911",
                style: PanicTextStyles.sliderText,
              ),
            ),
            Positioned(
              left: sliderPosition,
              top: 5,
              child: GestureDetector(
                onHorizontalDragUpdate: onDragUpdate,
                onHorizontalDragEnd: (_) => onDragEnd(),
                child: Container(
                  width: knobSize,
                  height: knobSize,
                  decoration: PanicDecorations.knob,
                  child: const Icon(Icons.phone, color: PanicColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget emergencyButton({required VoidCallback onLongPress}) {
    return PanicDecorations.emergencyPulse(
      GestureDetector(
        onLongPress: onLongPress,
        child: Container(
          width: 240,
          height: 240,
          decoration: PanicDecorations.emergencyButton,
          child: Center(
            child: Image.asset(
              'lib/assets/images/sos365.png',
              width: 90,
              height: 90,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  static Widget buttonText() {
    return const Column(
      children: [
        Text("Botón de Ayuda", style: PanicTextStyles.buttonTitle),
        SizedBox(height: 4),
        Text("Mantén presionado 3 segundos", style: PanicTextStyles.subtitle),
      ],
    );
  }

  static Widget floatingMenu({
    required bool isMenuOpen,
    required VoidCallback toggleMenu,
    required VoidCallback onProfile,
    required VoidCallback onContacts,
    required VoidCallback onHistory,
    required VoidCallback onInfo,
    required VoidCallback onSettings,
  }) {
    return Positioned(
      right: 20,
      bottom: 20,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isMenuOpen ? 220 : 0,
              width: 60,
              decoration: PanicDecorations.menu,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person, color: Colors.white),
                      onPressed: onProfile,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.contact_emergency,
                        color: Colors.white,
                      ),
                      onPressed: onContacts,
                    ),
                    IconButton(
                      icon: const Icon(Icons.history, color: Colors.white),
                      onPressed: onHistory,
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                      onPressed: onInfo,
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: onSettings,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              backgroundColor: PanicColors.primary,
              onPressed: toggleMenu,
              child: Icon(isMenuOpen ? Icons.close : Icons.menu),
            ),
          ],
        ),
      ),
    );
  }
}

class ModalBase extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onSave;

  const ModalBase({
    super.key,
    required this.title,
    required this.child,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: PanicColors.modalBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: PanicDecorations.modalContainer,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: PanicTextStyles.title),
            const SizedBox(height: 16),
            child,
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: PanicColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onSave,
                child: const Text(
                  "Aceptar",
                  style: PanicTextStyles.modalButtonText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
