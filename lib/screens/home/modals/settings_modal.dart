import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:sos365/config/design_home.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/iniciarsesion.dart';

class SettingsModal extends StatefulWidget {
  const SettingsModal({super.key});

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  bool camara = false;
  bool microfono = false;
  bool almacenamiento = false;
  bool telefono = false;
  bool ubicacion = false;

  @override
  void initState() {
    super.initState();
    verificarPermisos();
  }

  Future<void> verificarPermisos() async {
    camara = await Permission.camera.isGranted;
    microfono = await Permission.microphone.isGranted;
    almacenamiento = await Permission.photos.isGranted;
    ubicacion = await Permission.location.isGranted;

    if (Platform.isAndroid) {
      telefono = await Permission.phone.isGranted;
    }

    setState(() {});
  }

  Future<void> solicitarPermiso(
    Permission permiso,
    Function(bool) actualizar,
  ) async {
    final status = await permiso.request();

    if (status.isGranted) {
      setState(() => actualizar(true));
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else {
      setState(() => actualizar(false));
    }
  }

  Widget permisoItem(
    String titulo,
    bool valor,
    Permission permiso,
    Function(bool) actualizar,
  ) {
    return SwitchListTile(
      title: Text(titulo, style: PanicTextStyles.inputLabel),
      value: valor,
      onChanged: (v) => solicitarPermiso(permiso, actualizar),
      activeColor: PanicColors.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  Future<void> cerrarSesion(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("usuario_id");
    await prefs.remove("correo");
    await prefs.remove("nombre");
    await prefs.remove("sesion_activa");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const IniciarSesion()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Configuración", style: PanicTextStyles.title),
              const SizedBox(height: 20),

              permisoItem(
                "Cámara",
                camara,
                Permission.camera,
                (v) => camara = v,
              ),
              permisoItem(
                "Micrófono",
                microfono,
                Permission.microphone,
                (v) => microfono = v,
              ),
              permisoItem(
                "Fotos / Almacenamiento",
                almacenamiento,
                Permission.photos,
                (v) => almacenamiento = v,
              ),
              permisoItem(
                "Ubicación",
                ubicacion,
                Permission.location,
                (v) => ubicacion = v,
              ),

              if (Platform.isAndroid)
                permisoItem(
                  "Teléfono",
                  telefono,
                  Permission.phone,
                  (v) => telefono = v,
                ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: PanicDecorations.primaryButton,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                "Cerrar sesión",
                                style: PanicTextStyles.title,
                              ),
                              const SizedBox(height: 15),
                              const Text(
                                "¿Seguro que deseas cerrar tu sesión?",
                                style: PanicTextStyles.subtitle,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  OutlinedButton(
                                    onPressed: () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: PanicColors.primary,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "Cancelar",
                                      style: TextStyle(
                                        color: PanicColors.primary,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: PanicDecorations.primaryButton,
                                    onPressed: () => cerrarSesion(context),
                                    child: const Text(
                                      "Cerrar sesión",
                                      style: PanicTextStyles.buttonTitle,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Cerrar sesión",
                    style: PanicTextStyles.buttonTitle,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: PanicColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Continuar",
                    style: TextStyle(
                      color: PanicColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
