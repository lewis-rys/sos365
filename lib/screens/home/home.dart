import 'package:flutter/material.dart';
import '../../config/design_home.dart';
import '../../utils/eventos_home.dart';

class PanicButtonScreen extends StatefulWidget {
  const PanicButtonScreen({super.key});

  @override
  State<PanicButtonScreen> createState() => _PanicButtonScreenState();
}

class _PanicButtonScreenState extends State<PanicButtonScreen> {
  double sliderPosition = 0;
  bool isMenuOpen = false;

  final double sliderWidth = 300;
  final double knobSize = 54;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            /// ================= CONTENIDO PRINCIPAL =================
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildHeader(),
                    const SizedBox(height: 30),
                    buildSlider(),
                    const SizedBox(height: 50),
                    buildCentralButton(),
                    const SizedBox(height: 16),
                    buildButtonText(),
                    const SizedBox(height: 160), // ⬇️ botón un poco más abajo
                  ],
                ),
              ),
            ),

            /// ================= MENÚ FLOTANTE =================
            buildFloatingMenu(),
          ],
        ),
      ),
    );
  }

  /// ================= HEADER =================
  Widget buildHeader() => const Column(
    children: [
      Text("EMERGENCIA", style: PanicTextStyles.title),
      SizedBox(height: 6),
      Text(
        "Uso exclusivo en situaciones reales",
        style: PanicTextStyles.subtitle,
      ),
      Text("SOS365 - Disponible 24/7", style: PanicTextStyles.subtitle),
    ],
  );

  /// ================= SLIDER 911 =================
  Widget buildSlider() => Center(
    child: Container(
      width: sliderWidth,
      height: 65,
      decoration: PanicDecorations.slider,
      child: Stack(
        children: [
          const Center(
            child: Text(
              "Desliza para llamar al 911",
              style: PanicTextStyles.sliderText,
            ),
          ),
          Positioned(
            left: sliderPosition,
            top: 5,
            child: GestureDetector(
              onHorizontalDragUpdate: (d) => updateSlider(
                d,
                sliderWidth,
                knobSize,
                setState,
                (v) => sliderPosition = v,
                sliderPosition,
              ),
              onHorizontalDragEnd: (_) => handleSliderEnd(
                sliderPosition,
                sliderWidth,
                () => resetSlider(setState, () => sliderPosition = 0),
              ),
              child: Container(
                width: knobSize,
                height: knobSize,
                decoration: PanicDecorations.knob,
                child: const Icon(Icons.phone, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  /// ================= BOTÓN CENTRAL =================
  Widget buildCentralButton() {
    return PanicDecorations.emergencyPulse(
      GestureDetector(
        onLongPress: () => showEmergencyModal(context),
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

  /// ================= TEXTO INFERIOR =================
  Widget buildButtonText() => const Column(
    children: [
      Text("Botón de Ayuda", style: PanicTextStyles.buttonTitle),
      SizedBox(height: 4),
      Text("Mantén presionado 3 segundos", style: PanicTextStyles.subtitle),
    ],
  );

  /// ================= MENÚ FLOTANTE =================
  Widget buildFloatingMenu() => Positioned(
    right: 20,
    bottom: 20,
    child: SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.45,
        ),
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
                      onPressed: () {
                        setState(() => isMenuOpen = false);
                        openModal(context, const ProfileModal());
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.contact_emergency,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() => isMenuOpen = false);
                        openModal(context, const ContactModal());
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.history, color: Colors.white),
                      onPressed: () {
                        setState(() => isMenuOpen = false);
                        openModal(context, const HistoryModal());
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                      onPressed: () {
                        setState(() => isMenuOpen = false);
                        openModal(context, const InfoModal());
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        setState(() => isMenuOpen = false);
                        openModal(context, const SettingsModal());
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              onPressed: () => setState(() => isMenuOpen = !isMenuOpen),
              child: Icon(isMenuOpen ? Icons.close : Icons.menu),
            ),
          ],
        ),
      ),
    ),
  );

  /// ================= MODAL CONFIRMACIÓN =================
  void showEmergencyModal(BuildContext context) {
    openModal(
      context,
      modalBase(
        title: "Alerta enviada",
        child: const Text(
          "Tu alerta de emergencia ha sido enviada correctamente.",
        ),
        onSave: () => Navigator.pop(context),
      ),
    );
  }
}
