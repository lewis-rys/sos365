import 'package:flutter/material.dart';
import '../../config/design_auth.dart';
import '../../utils/eventos_auth.dart';
import 'iniciarsesion.dart';

class CrearCuentaScreen extends StatefulWidget {
  const CrearCuentaScreen({super.key});

  @override
  State<CrearCuentaScreen> createState() => _CrearCuentaScreenState();
}

class _CrearCuentaScreenState extends State<CrearCuentaScreen> {
  DateTime? _fechaseleccionada;

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
                  // Ícono
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
                  const SizedBox(height: 30),

                  // Botón fecha
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? fecha = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                      );

                      if (fecha != null) {
                        setState(() {
                          _fechaseleccionada = fecha;
                        });
                      }
                    },
                    child: const Text("Seleccionar fecha de cumpleaños"),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    _fechaseleccionada != null
                        ? '${_fechaseleccionada!.day}/${_fechaseleccionada!.month}/${_fechaseleccionada!.year}'
                        : 'No se ha seleccionado fecha',
                    style: PanicTextStyles.subtitle,
                  ),

                  const SizedBox(height: 30),

                  // Botón registrarse
                  ElevatedButton(
                    onPressed: () =>
                        navigateTo(context, const IniciarSesionScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PanicColors.primary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.black87, width: 2),
                      ),
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
              borderSide: const BorderSide(color: Colors.black87),
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
