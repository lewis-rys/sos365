import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'color.dart';
import 'seguridad/iniciarsesion.dart';
import 'seguridad/eventos.dart'; // para navigateToReplacement

/// ===== FUNCIONES DE EMERGENCIA =====
Future<void> makeCall(String number) async {
  final uri = Uri(scheme: 'tel', path: number);
  if (await canLaunchUrl(uri)) await launchUrl(uri);
}

void updateSlider(
  DragUpdateDetails d,
  double sliderWidth,
  double knobSize,
  void Function(void Function()) setState,
  Function(double) setValue,
  double current,
) {
  setState(() {
    double value = current + d.delta.dx;
    setValue(value.clamp(0, sliderWidth - knobSize - 10));
  });
}

void handleSliderEnd(double position, double sliderWidth, VoidCallback reset) {
  if (position > sliderWidth * 0.6) makeCall("911");
  Future.delayed(const Duration(milliseconds: 600), reset);
}

void resetSlider(
  void Function(void Function()) setState,
  VoidCallback resetValue,
) {
  setState(resetValue);
}

/// ===== MODALES =====
void openModal(BuildContext context, Widget content) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: content.animate().fade(duration: 300.ms).scale(duration: 300.ms),
    ),
  );
}

Widget modalBase({
  required String title,
  required Widget child,
  VoidCallback? onSave,
}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFFFE5D9),
      borderRadius: BorderRadius.circular(25),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        child,
        if (onSave != null) ...[
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: PanicColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: const Size(double.infinity, 45),
            ),
            child: const Text(
              "CONTINUAR...",
              style: PanicTextStyles.modalButtonText,
            ),
          ),
        ],
      ],
    ),
  );
}

/// ===== MODALES ESPECÍFICOS =====
class ProfileModal extends StatelessWidget {
  const ProfileModal({super.key});

  @override
  Widget build(BuildContext context) {
    return modalBase(
      title: "Perfil",
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nombre
          TextField(
            decoration: InputDecoration(
              labelText: "Nombre",
              prefixIcon: Icon(Icons.person),
            ),
          ),

          SizedBox(height: 15),

          // Correo
          TextField(
            decoration: InputDecoration(
              labelText: "Correo electrónico",
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),

          SizedBox(height: 15),

          // Contraseña
          TextField(
            decoration: InputDecoration(
              labelText: "Contraseña",
              prefixIcon: Icon(Icons.lock),
            ),
            obscureText: true,
          ),
        ],
      ),
      onSave: () => Navigator.pop(context), // Botón Aceptar del modal global
    );
  }
}

class HistoryModal extends StatelessWidget {
  const HistoryModal({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> historiales = [
      {
        "fecha": "15/02/2026",
        "detalle": "Emergencia activada por incendio en laboratorio.",
      },
      {
        "fecha": "14/02/2026",
        "detalle": "Emergencia activada por accidente en cancha deportiva.",
      },
      {
        "fecha": "13/02/2026",
        "detalle": "Emergencia activada por robo en oficina administrativa.",
      },
    ];

    return modalBase(
      title: "Historial",
      onSave: () => Navigator.pop(context),
      child: SizedBox(
        height: 300,
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: historiales.length,
                itemBuilder: (context, index) {
                  final historial = historiales[index];
                  return ExpansionTile(
                    title: Text(
                      historial["fecha"]!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(historial["detalle"]!),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoModal extends StatelessWidget {
  const InfoModal({super.key});

  @override
  Widget build(BuildContext context) {
    return modalBase(
      title: "Información",
      child: const Text("Información sobre SOS365"),
      onSave: () => Navigator.pop(context),
    );
  }
}

class SettingsModal extends StatefulWidget {
  const SettingsModal({super.key});

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  bool gps = true;
  bool camara = true;
  bool microfono = false;
  bool galeria = true;
  bool almacenamiento = false;

  @override
  Widget build(BuildContext context) {
    return modalBase(
      title: "Configuración",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ===== SWITCHES DE PERMISOS =====
          SwitchListTile(
            title: const Text("GPS / Ubicación"),
            secondary: const Icon(Icons.location_on),
            value: gps,
            onChanged: (value) {
              setState(() => gps = value);
            },
          ),

          SwitchListTile(
            title: const Text("Cámara"),
            secondary: const Icon(Icons.camera_alt),
            value: camara,
            onChanged: (value) {
              setState(() => camara = value);
            },
          ),

          SwitchListTile(
            title: const Text("Micrófono"),
            secondary: const Icon(Icons.mic),
            value: microfono,
            onChanged: (value) {
              setState(() => microfono = value);
            },
          ),

          SwitchListTile(
            title: const Text("Galería"),
            secondary: const Icon(Icons.photo),
            value: galeria,
            onChanged: (value) {
              setState(() => galeria = value);
            },
          ),

          SwitchListTile(
            title: const Text("Almacenamiento"),
            secondary: const Icon(Icons.folder),
            value: almacenamiento,
            onChanged: (value) {
              setState(() => almacenamiento = value);
            },
          ),

          const SizedBox(height: 30),

          // ===== BOTÓN CERRAR SESIÓN (SE MANTIENE) =====
          ElevatedButton(
            onPressed: () {
              navigateToReplacement(context, const IniciarSesionScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 116, 8, 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.black, width: 2),
              ),
              minimumSize: const Size(double.infinity, 45),
            ),
            child: const Text(
              "CERRAR SESIÓN",
              style: PanicTextStyles.modalButtonText,
            ),
          ),
        ],
      ),

      // Botón aceptar del modalBase (sin cambios)
      onSave: () => Navigator.pop(context),
    );
  }
}

class ContactModal extends StatelessWidget {
  const ContactModal({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> contactos = [
      {
        "titulo": "Mamá",
        "correo": "juan.perez@email.com",
        "nombre": "Juan",
        "apellido": "Pérez",
        "parentesco": "Padre",
        "telefono": "555-123-4567",
      },
      {
        "titulo": "Papá",
        "correo": "maria.lopez@email.com",
        "nombre": "María",
        "apellido": "López",
        "parentesco": "Madre",
        "telefono": "555-234-5678",
      },
      {
        "titulo": "Hermano",
        "correo": "carlos.gomez@email.com",
        "nombre": "Carlos",
        "apellido": "Gómez",
        "parentesco": "Hermano",
        "telefono": "555-345-6789",
      },
      {
        "titulo": "Amiga Ana",
        "correo": "ana.martinez@email.com",
        "nombre": "Ana",
        "apellido": "Martínez",
        "parentesco": "Amiga",
        "telefono": "555-456-7890",
      },
      {
        "titulo": "Tío Luis",
        "correo": "luis.hernandez@email.com",
        "nombre": "Luis",
        "apellido": "Hernández",
        "parentesco": "Tío",
        "telefono": "555-567-8901",
      },
    ];

    return modalBase(
      title: "Contactos",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: contactos.map((contacto) {
          return ExpansionTile(
            title: Text(
              contacto["titulo"]!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            children: [
              _infoRow(Icons.email, "Correo", contacto["correo"]!),
              _infoRow(Icons.person, "Nombre", contacto["nombre"]!),
              _infoRow(Icons.person_outline, "Apellido", contacto["apellido"]!),
              _infoRow(
                Icons.family_restroom,
                "Parentesco",
                contacto["parentesco"]!,
              ),
              _infoRow(Icons.phone, "Teléfono", contacto["telefono"]!),
              const SizedBox(height: 10),
            ],
          );
        }).toList(),
      ),
      onSave: () => Navigator.pop(context),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text("$label: $value", style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
