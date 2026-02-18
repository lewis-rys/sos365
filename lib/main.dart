import 'package:flutter/material.dart';
import 'color.dart';
import 'seguridad/iniciarsesion.dart'; // <- apuntando a la nueva interfaz

void main() {
  runApp(const PanicApp());
}

class PanicApp extends StatelessWidget {
  const PanicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: PanicColors.background,
        colorSchemeSeed: PanicColors.primary,
      ),
      home:
          const IniciarSesionScreen(), // <- ejecuta la pantalla de inicio de sesión
    );
  }
}
