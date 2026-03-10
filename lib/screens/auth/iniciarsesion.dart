import 'package:flutter/material.dart';
import '../../config/design_auth.dart';
import '../../utils/eventos_auth.dart';
import 'crearcuenta.dart';
import '../home/home.dart';

class IniciarSesionScreen extends StatelessWidget {
  const IniciarSesionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PanicColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: PanicColors.peach,
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
                  // Logo o ícono de alerta
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: PanicColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        'lib/assets/images/sos365.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    "CONFIRMAR IDENTIDAD",
                    style: PanicTextStyles.title,
                  ),
                  const SizedBox(height: 30),

                  buildInputField("Usuario:"),
                  const SizedBox(height: 20),
                  buildInputField("Contraseña:", obscureText: true),
                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "OLVIDÉ MI CONTRASEÑA",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () => navigateToReplacement(
                      context,
                      const PanicButtonScreen(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PanicColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.black87, width: 2),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "INGRESAR",
                      style: PanicTextStyles.buttonTitle,
                    ),
                  ),
                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: () =>
                        navigateTo(context, const CrearCuentaScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PanicColors.primaryLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.black87, width: 2),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      "CREAR CUENTA",
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
        Text(label, style: PanicTextStyles.inputLabel),
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
