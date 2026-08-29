import 'package:flutter/material.dart';
import 'package:sos365/config/design_auth.dart';
import 'package:sos365/services/mongodb_service.dart';

class CrearCuenta extends StatefulWidget {
  const CrearCuenta({super.key});

  @override
  State<CrearCuenta> createState() => _CrearCuentaState();
}

class _CrearCuentaState extends State<CrearCuenta>
    with SingleTickerProviderStateMixin {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmarController = TextEditingController();

  DateTime? fechaNacimiento;
  bool cargando = false;

  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();
    confirmarController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> seleccionarFecha() async {
    DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: PanicColors.primary,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      setState(() {
        fechaNacimiento = fecha;
      });
    }
  }

  Future<void> crearCuenta() async {
    if (passwordController.text != confirmarController.text) {
      mostrarError("Las contraseñas no coinciden");
      return;
    }

    if (fechaNacimiento == null) {
      mostrarError("Selecciona tu fecha de nacimiento");
      return;
    }

    if (nombreController.text.isEmpty ||
        correoController.text.isEmpty ||
        passwordController.text.isEmpty) {
      mostrarError("Completa todos los campos");
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      var existente = await MongoService.usuarios!.findOne({
        "correo": correoController.text.trim(),
      });

      if (existente != null) {
        mostrarError("Ese correo ya está registrado");
        setState(() => cargando = false);
        return;
      }

      String formatearFecha(DateTime fecha) {
        final y = fecha.year.toString().padLeft(4, '0');
        final m = fecha.month.toString().padLeft(2, '0');
        final d = fecha.day.toString().padLeft(2, '0');
        final h = fecha.hour.toString().padLeft(2, '0');
        final mi = fecha.minute.toString().padLeft(2, '0');
        final s = fecha.second.toString().padLeft(2, '0');
        return "$y-$m-$d $h:$mi:$s.000";
      }

      var result = await MongoService.usuarios!.insertOne({
        "nombre_usuario": nombreController.text.trim(),
        "correo": correoController.text.trim(),
        "contrasena": passwordController.text.trim(),
        "fecha_cumpleanos": formatearFecha(fechaNacimiento!),
        "fecha_registro": formatearFecha(DateTime.now()),
      });

      var userId = result.id;

      await MongoService.contactos!.insertOne({
        "usuario_id": userId,
        "contactos": [],
      });

      await MongoService.alertas!.insertOne({
        "usuario_id": userId,
        "historial": [],
      });

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      mostrarError("Error al crear la cuenta");
    }

    setState(() {
      cargando = false;
    });
  }

  void mostrarError(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Widget buildInputField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: PanicTextStyles.inputLabel),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: PanicDecorations.inputDecoration(label),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget selectorFecha() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Fecha de nacimiento", style: PanicTextStyles.inputLabel),
        const SizedBox(height: 6),
        InkWell(
          onTap: seleccionarFecha,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PanicColors.primary.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  fechaNacimiento == null
                      ? "Seleccionar fecha"
                      : "${fechaNacimiento!.day}/${fechaNacimiento!.month}/${fechaNacimiento!.year}",
                ),
                const Icon(Icons.calendar_month, color: PanicColors.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.3),
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Container(
              width: 360,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: PanicColors.peach,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: PanicColors.primary, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 25,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/images/sos365red.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),

                  const Text("Crear Cuenta", style: PanicTextStyles.title),
                  const SizedBox(height: 25),

                  buildInputField("Nombre y Apellido", nombreController),
                  buildInputField("Correo", correoController),
                  buildInputField(
                    "Contraseña",
                    passwordController,
                    obscureText: true,
                  ),
                  buildInputField(
                    "Confirmar contraseña",
                    confirmarController,
                    obscureText: true,
                  ),

                  selectorFecha(),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 213, 0, 0),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: cargando ? null : crearCuenta,
                      child: cargando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Crear cuenta",
                              style: PanicTextStyles.buttonTitle,
                            ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Ya tengo cuenta",
                      style: TextStyle(
                        color: PanicColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
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
}
