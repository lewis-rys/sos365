import 'package:flutter/material.dart';
import 'package:sos365/services/mongodb_service.dart';
import 'package:sos365/config/design_auth.dart';
import 'iniciarsesion.dart';

class RecuperarCuenta extends StatefulWidget {
  const RecuperarCuenta({super.key});

  @override
  State<RecuperarCuenta> createState() => _RecuperarCuentaState();
}

class _RecuperarCuentaState extends State<RecuperarCuenta>
    with SingleTickerProviderStateMixin {
  final correoController = TextEditingController();
  DateTime? fechaCumple;

  bool cargando = false;
  bool validado = false;

  final nuevaContrasenaController = TextEditingController();
  final confirmarContrasenaController = TextEditingController();

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
    correoController.dispose();
    nuevaContrasenaController.dispose();
    confirmarContrasenaController.dispose();
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
          data: ThemeData.light().copyWith(
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
        fechaCumple = fecha;
      });
    }
  }

  Future<void> comprobarPropiedad() async {
    if (correoController.text.isEmpty || fechaCumple == null) {
      mostrarError("Completa correo y fecha de cumpleaños");
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      final correo = correoController.text.trim();

      var usuario = await MongoService.usuarios!.findOne({"correo": correo});

      if (usuario == null) {
        mostrarError("No se encontró el correo");
        return;
      }

      DateTime fechaBD = DateTime.parse(usuario["fecha_cumpleanos"].toString());

      if (fechaCumple!.year != fechaBD.year ||
          fechaCumple!.month != fechaBD.month ||
          fechaCumple!.day != fechaBD.day) {
        mostrarError("Fecha de cumpleaños incorrecta");
        return;
      }

      setState(() {
        validado = true;
      });

      await showDialog(
        context: context,
        builder: (context) => ScaleTransition(
          scale: _scaleAnimation,
          child: AlertDialog(
            backgroundColor: PanicColors.peach,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: PanicColors.primary, width: 2),
            ),
            title: const Center(
              child: Text("Cambiar contraseña", style: PanicTextStyles.title),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nuevaContrasenaController,
                  obscureText: true,
                  decoration: PanicDecorations.inputDecoration(
                    "Nueva contraseña",
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: confirmarContrasenaController,
                  obscureText: true,
                  decoration: PanicDecorations.inputDecoration(
                    "Confirmar contraseña",
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cerrar",
                  style: TextStyle(
                    color: PanicColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 213, 0, 0),
                ),
                onPressed: () async {
                  final nueva = nuevaContrasenaController.text.trim();
                  final confirmar = confirmarContrasenaController.text.trim();

                  if (nueva.isEmpty || confirmar.isEmpty) {
                    mostrarError("Completa ambos campos");
                    return;
                  }

                  if (nueva != confirmar) {
                    mostrarError("Las contraseñas no coinciden");
                    return;
                  }

                  await MongoService.usuarios!.updateOne(
                    {"correo": correo},
                    {
                      "\$set": {"contrasena": nueva},
                    },
                  );

                  if (!mounted) return;

                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const IniciarSesion()),
                  );
                },
                child: const Text("Guardar"),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      mostrarError("Error al validar usuario");
    } finally {
      setState(() {
        cargando = false;
      });
    }
  }

  void mostrarError(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.3),
      body: Center(
        child: SingleChildScrollView(
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'lib/assets/images/sos365red.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 20),
                const Text("Recuperar cuenta", style: PanicTextStyles.title),
                const SizedBox(height: 25),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Correo electrónico",
                      style: PanicTextStyles.inputLabel,
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: correoController,
                      decoration: PanicDecorations.inputDecoration(
                        "Correo electrónico",
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Fecha de nacimiento",
                      style: PanicTextStyles.inputLabel,
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: seleccionarFecha,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: PanicColors.primary.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              fechaCumple == null
                                  ? "Seleccionar fecha"
                                  : "${fechaCumple!.day}/${fechaCumple!.month}/${fechaCumple!.year}",
                            ),
                            const Icon(
                              Icons.calendar_month,
                              color: PanicColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
                ),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: cargando ? null : comprobarPropiedad,
                    child: cargando
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Comprobar propiedad"),
                  ),
                ),

                const SizedBox(height: 15),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancelar"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
