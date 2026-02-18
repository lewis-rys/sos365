import 'package:flutter/material.dart';
import 'color.dart';
import 'eventos.dart';

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
            Column(
              children: [
                const SizedBox(height: 20),
                buildHeader(),
                const SizedBox(height: 30),
                buildSlider(),
                const Spacer(),
                buildCentralButton(),
                const SizedBox(height: 16),
                buildButtonText(),
                const Spacer(flex: 2),
              ],
            ),
            buildFloatingMenu(),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() => const Column(
    children: [
      Text("EMERGENCIA", style: PanicTextStyles.title),
      Text(
        "Uso exclusivo en situaciones reales",
        style: PanicTextStyles.subtitle,
      ),
      Text("SOS365 - Disponible 24/7", style: PanicTextStyles.subtitle),
    ],
  );

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

  Widget buildCentralButton() {
    return GestureDetector(
      onLongPress: () => showEmergencyModal(context),
      child: PanicDecorations.emergencyPulse(
        Container(
          width: 240,
          height: 240,
          decoration: PanicDecorations.emergencyButton,
          child: Center(
            child: Image.asset(
              'lib/assets/images/16437dias.jpeg',
              width: 90,
              height: 90,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildButtonText() => const Column(
    children: [
      Text("Botón de Ayuda", style: PanicTextStyles.buttonTitle),
      Text("Mantén presionado 3 segundos", style: PanicTextStyles.subtitle),
    ],
  );

  Widget buildFloatingMenu() => Positioned(
    right: 20,
    bottom: 80,
    child: Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isMenuOpen ? 220 : 0,
          width: 60,
          decoration: PanicDecorations.menu,
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
                icon: const Icon(Icons.contact_emergency, color: Colors.white),
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
        const SizedBox(height: 10),
        FloatingActionButton(
          onPressed: () => setState(() => isMenuOpen = !isMenuOpen),
          child: Icon(isMenuOpen ? Icons.close : Icons.menu),
        ),
      ],
    ),
  );

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
