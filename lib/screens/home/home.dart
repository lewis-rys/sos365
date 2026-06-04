import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'modals/alerta_modal.dart';
import '../auth/iniciarsesion.dart';

import 'modals/profile_modal.dart';
import 'modals/settings_modal.dart';
import 'modals/contact_modal.dart';
import 'modals/history_modal.dart';
import 'modals/info_modal.dart';

import 'package:sos365/config/design_home.dart';

class PanicButtonScreen extends StatefulWidget {
  const PanicButtonScreen({super.key});

  @override
  State<PanicButtonScreen> createState() => _PanicButtonScreenState();
}

class _PanicButtonScreenState extends State<PanicButtonScreen>
    with SingleTickerProviderStateMixin {
  double sliderPosition = 0;
  bool isMenuOpen = false;

  String nombreUsuario = "Usuario";
  String emailUsuario = "";

  final double sliderWidth = 300;
  final double knobSize = 54;

  late AnimationController _menuController;
  late Animation<double> _menuAnimation;

  @override
  void initState() {
    super.initState();
    cargarUsuario();
    _mostrarContactosPrimeraVez();

    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _menuAnimation = CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  void cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nombreUsuario = prefs.getString("nombre") ?? "Usuario";
      emailUsuario = prefs.getString("correo") ?? "";
    });
  }

  Future<void> _mostrarContactosPrimeraVez() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("usuario_id") ?? "";

    if (userId.isEmpty) return;

    final flagKey = "contactos_mostrado_$userId";
    final yaSeMostro = prefs.getBool(flagKey) ?? false;

    if (!yaSeMostro) {
      await prefs.setBool(flagKey, true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          openModal(context, const ContactModal());
        }
      });
    }
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const IniciarSesion()),
      (route) => false,
    );
  }

  // ✅ Compatible con Android e iOS — abre el marcador con el número precargado
  Future<void> llamarEmergencia() async {
    const numero = "911";
    final uri = Uri(scheme: 'tel', path: numero);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo iniciar la llamada de emergencia'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void updateSlider(
    DragUpdateDetails details,
    double maxWidth,
    double knobSize,
    Function(double) onUpdate,
  ) {
    double newPosition = sliderPosition + details.delta.dx;
    if (newPosition < 0) newPosition = 0;
    if (newPosition > maxWidth - knobSize) newPosition = maxWidth - knobSize;
    setState(() => onUpdate(newPosition));
  }

  void handleSliderEnd(
    double currentPosition,
    double maxWidth,
    VoidCallback onSliderComplete,
    VoidCallback onReset,
  ) {
    if (currentPosition >= maxWidth - knobSize) {
      onSliderComplete();
    }
    onReset();
  }

  void resetSlider(VoidCallback resetPosition) {
    setState(resetPosition);
  }

  void openModal(BuildContext context, Widget modal) {
    showDialog(context: context, builder: (_) => modal);
  }

  void activarAlerta() {
    showDialog(
      context: context,
      builder: (_) => AlertaModal(alertaData: {}, nombreUsuario: nombreUsuario),
    );
  }

  Widget buildHeader() {
    return PanicDesign.header(nombreUsuario);
  }

  Widget buildSlider() {
    return PanicDesign.slider(
      sliderPosition: sliderPosition,
      sliderWidth: sliderWidth,
      knobSize: knobSize,
      onDragUpdate: (d) =>
          updateSlider(d, sliderWidth, knobSize, (v) => sliderPosition = v),
      onDragEnd: () => handleSliderEnd(
        sliderPosition,
        sliderWidth,
        llamarEmergencia,
        () => resetSlider(() => sliderPosition = 0),
      ),
    );
  }

  Widget buildCentralButton() {
    return PanicDesign.emergencyButton(onLongPress: activarAlerta);
  }

  Widget buildButtonText() {
    return PanicDesign.buttonText();
  }

  Widget buildFloatingMenu() {
    return Stack(
      children: [
        if (isMenuOpen)
          GestureDetector(
            onTap: toggleMenu,
            child: FadeTransition(
              opacity: _menuAnimation,
              child: Container(
                color: Colors.black.withOpacity(0.4),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: toggleMenu,
                child: AnimatedBuilder(
                  animation: _menuController,
                  builder: (_, __) {
                    return Container(
                      width: 54,
                      height: 54,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black87, width: 1.5),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          3,
                          (_) => Container(
                            width: double.infinity,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 1,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizeTransition(
                sizeFactor: _menuAnimation,
                axisAlignment: -1,
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PanicColors.background,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      menuItem("Perfil", Icons.person, () {
                        toggleMenu();
                        openModal(
                          context,
                          ProfileModal(
                            nombre: nombreUsuario,
                            email: emailUsuario,
                            onSave: (n, e) {
                              setState(() {
                                nombreUsuario = n;
                                emailUsuario = e;
                              });
                            },
                          ),
                        );
                      }),
                      menuItem("Contactos", Icons.contacts, () {
                        toggleMenu();
                        openModal(context, const ContactModal());
                      }),
                      menuItem("Historial", Icons.history, () {
                        toggleMenu();
                        openModal(context, const HistoryModal());
                      }),
                      menuItem("Información", Icons.info, () {
                        toggleMenu();
                        openModal(context, const InfoModal());
                      }),
                      menuItem("Configuración", Icons.settings, () {
                        toggleMenu();
                        openModal(context, const SettingsModal());
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
      if (isMenuOpen) {
        _menuController.forward();
      } else {
        _menuController.reverse();
      }
    });
  }

  Widget menuItem(String titulo, IconData icono, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icono, color: PanicColors.primary, size: 20),
            const SizedBox(width: 10),
            Text(
              titulo,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PanicDesign.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: PanicDesign.screenPadding,
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
                    const SizedBox(height: 160),
                  ],
                ),
              ),
            ),
            buildFloatingMenu(),
          ],
        ),
      ),
    );
  }
}
