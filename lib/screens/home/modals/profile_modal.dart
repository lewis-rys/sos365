import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos365/config/design_home.dart';
import 'package:sos365/services/mongodb_service.dart';

class ProfileModal extends StatefulWidget {
  final String nombre;
  final String email;
  final void Function(String, String) onSave;

  const ProfileModal({
    super.key,
    required this.nombre,
    required this.email,
    required this.onSave,
  });

  @override
  State<ProfileModal> createState() => _ProfileModalState();
}

class _ProfileModalState extends State<ProfileModal> {
  late TextEditingController nombreController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmarController;

  DateTime? fechaNacimiento;

  bool guardando = false;
  bool verPassword = false;

  @override
  void initState() {
    super.initState();

    nombreController = TextEditingController(text: widget.nombre);
    emailController = TextEditingController(text: widget.email);
    passwordController = TextEditingController();
    confirmarController = TextEditingController();
  }

  @override
  void dispose() {
    nombreController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmarController.dispose();
    super.dispose();
  }

  String formatearFecha(DateTime fecha) {
    final y = fecha.year.toString().padLeft(4, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final d = fecha.day.toString().padLeft(2, '0');
    return "$y-$m-$d 00:00:00.000";
  }

  Future<void> seleccionarFecha() async {
    DateTime initial = fechaNacimiento ?? DateTime(2000);

    DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: initial,
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
        fechaNacimiento = fecha;
      });
    }
  }

  Future<void> guardarCambios() async {
    if (passwordController.text != confirmarController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }

    if (nombreController.text.isEmpty || emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa los campos obligatorios")),
      );
      return;
    }

    setState(() {
      guardando = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String? correoActual = prefs.getString("correo");

      if (correoActual == null) {
        throw Exception("Sesión inválida");
      }

      if (correoActual != emailController.text.trim()) {
        var existente = await MongoService.usuarios!.findOne({
          "correo": emailController.text.trim(),
        });

        if (existente != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ese correo ya está en uso")),
          );
          setState(() => guardando = false);
          return;
        }
      }

      Map<String, dynamic> cambios = {
        "nombre_usuario": nombreController.text.trim(),
        "correo": emailController.text.trim(),
      };

      if (passwordController.text.isNotEmpty) {
        cambios["contrasena"] = passwordController.text.trim();
      }

      if (fechaNacimiento != null) {
        cambios["fecha_cumpleanos"] = formatearFecha(fechaNacimiento!);
      }

      await MongoService.usuarios!.updateOne(
        {"correo": correoActual},
        {"\$set": cambios},
      );

      await prefs.setString("nombre", nombreController.text.trim());
      await prefs.setString("correo", emailController.text.trim());

      widget.onSave(nombreController.text.trim(), emailController.text.trim());

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error al guardar cambios")));
    }

    setState(() {
      guardando = false;
    });
  }

  Widget buildInput(
    String label,
    TextEditingController controller, {
    bool password = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: PanicTextStyles.inputLabel),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: password ? !verPassword : false,
          decoration: PanicDecorations.inputDecoration(label).copyWith(
            suffixIcon: password
                ? IconButton(
                    icon: Icon(
                      verPassword ? Icons.visibility_off : Icons.visibility,
                      color: PanicColors.primary,
                    ),
                    onPressed: () {
                      setState(() {
                        verPassword = !verPassword;
                      });
                    },
                  )
                : null,
          ),
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
            decoration: PanicDecorations.card,
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
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Perfil", style: PanicTextStyles.title),
              const SizedBox(height: 25),
              buildInput("Nombre", nombreController),
              buildInput("Correo", emailController),
              buildInput(
                "Nueva contraseña",
                passwordController,
                password: true,
              ),
              buildInput(
                "Confirmar contraseña",
                confirmarController,
                password: true,
              ),
              selectorFecha(),
              ElevatedButton(
                style: PanicDecorations.primaryButton,
                onPressed: guardando ? null : guardarCambios,
                child: guardando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Continuar y guardar cambios",
                        style: PanicTextStyles.buttonTitle,
                      ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancelar",
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
    );
  }
}
