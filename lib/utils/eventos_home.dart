import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/design_home.dart';
import '../screens/auth/iniciarsesion.dart';
import 'eventos_auth.dart'; // para navigateToReplacement

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
    ];

    return modalBase(
      title: "Contactos de emergencia",
      child: SizedBox(
        height: 450,
        child: Column(
          children: [
            /// ===== AGREGAR CONTACTO =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Agregar contacto"),
                onPressed: () => _openContactForm(context),
              ),
            ),

            const SizedBox(height: 12),

            /// ===== LISTA =====
            Expanded(
              child: ListView.separated(
                itemCount: contactos.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final c = contactos[index];

                  return ExpansionTile(
                    leading: CircleAvatar(child: Text(c["titulo"]![0])),
                    title: Text(
                      c["titulo"]!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(c["parentesco"]!),
                    childrenPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    children: [
                      _infoRow(
                        Icons.person,
                        "Nombre",
                        "${c["nombre"]} ${c["apellido"]}",
                      ),
                      _infoRow(Icons.email, "Correo", c["correo"]!),
                      _infoRow(Icons.phone, "Teléfono", c["telefono"]!),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text("Editar"),
                            onPressed: () =>
                                _openContactForm(context, contacto: c),
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            label: const Text(
                              "Eliminar",
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () =>
                                _confirmDelete(context, c["titulo"]!),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      onSave: () => Navigator.pop(context),
    );
  }

  /// ===== FORM AGREGAR / EDITAR =====
  void _openContactForm(BuildContext context, {Map<String, String>? contacto}) {
    showDialog(
      context: context,
      builder: (_) {
        final isEdit = contacto != null;

        final nombreCtrl = TextEditingController(
          text: contacto?["nombre"] ?? "",
        );
        final apellidoCtrl = TextEditingController(
          text: contacto?["apellido"] ?? "",
        );
        final correoCtrl = TextEditingController(
          text: contacto?["correo"] ?? "",
        );
        final telefonoCtrl = TextEditingController(
          text: contacto?["telefono"] ?? "",
        );
        final parentescoCtrl = TextEditingController(
          text: contacto?["parentesco"] ?? "",
        );

        return AlertDialog(
          title: Text(isEdit ? "Editar contacto" : "Agregar contacto"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _input(nombreCtrl, "Nombre"),
                _input(apellidoCtrl, "Apellido"),
                _input(parentescoCtrl, "Parentesco"),
                _input(correoCtrl, "Correo electrónico"),
                _input(telefonoCtrl, "Teléfono"),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Guardar"),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isEdit
                          ? "Cambios no guardados (demo)"
                          : "Contacto agregado (demo)",
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  /// ===== CONFIRMAR ELIMINAR =====
  void _confirmDelete(BuildContext context, String nombre) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar contacto"),
        content: Text("¿Seguro que deseas eliminar a $nombre?"),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Eliminar"),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Contacto eliminado (demo)")),
              );
            },
          ),
        ],
      ),
    );
  }

  /// ===== INPUT =====
  Widget _input(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text("$label: $value")),
        ],
      ),
    );
  }
}
