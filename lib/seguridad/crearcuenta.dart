import 'package:flutter/material.dart';
import './desing.dart';
import './eventos.dart';
import './iniciarsesion.dart';

class CrearCuentaScreen extends StatelessWidget {
  const CrearCuentaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PanicColors.background, // mismo fondo
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: PanicColors.peach, // contenedor igual
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Ícono de alerta
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: PanicColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        'lib/assets/images/16437dias.jpeg',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text("CREAR CUENTA", style: PanicTextStyles.title),
                  const SizedBox(height: 30),

                  buildInputField("Nombre de usuario:"),
                  const SizedBox(height: 20),
                  buildInputField("Correo electrónico:"),
                  const SizedBox(height: 20),
                  buildInputField("Contraseña:", obscureText: true),
                  const SizedBox(height: 40),

                  // Botón para registrarse
                  ElevatedButton(
                    onPressed: () =>
                        navigateTo(context, const IniciarSesionScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PanicColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.black87, width: 2),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "REGISTRARSE",
                      style: PanicTextStyles.buttonTitle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputField(String label, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: PanicTextStyles.subtitle),
        const SizedBox(height: 5),
        TextField(
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black87, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: PanicColors.primaryDark,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
