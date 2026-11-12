import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sos365/services/mongodb_service.dart';
import 'package:sos365/services/password_service.dart';
import 'package:sos365/screens/home/home.dart';
import 'package:sos365/config/design_auth.dart';
import 'crearcuenta.dart';
import 'recuperarcuenta.dart';

class IniciarSesion extends StatefulWidget {
  const IniciarSesion({super.key});

  @override
  State<IniciarSesion> createState() => _IniciarSesionState();
}

class _IniciarSesionState extends State<IniciarSesion>
    with SingleTickerProviderStateMixin {
  final correoController = TextEditingController();
  final passwordController = TextEditingController();

  bool cargando = false;
  bool verPassword = false;

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
    passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> iniciarSesion() async {
    if (correoController.text.isEmpty || passwordController.text.isEmpty) {
      mostrarError("Completa todos los campos");
      return;
    }

    setState(() {
      cargando = true;
    });

    try {
      var usuario = await MongoService.usuarios!.findOne({
        "correo": correoController.text.trim(),
      });

      if (usuario == null) {
        mostrarError("El correo no está registrado");
        setState(() => cargando = false);
        return;
      }

      final salt = usuario["contrasena_salt"]?.toString();
      final hash = usuario["contrasena_hash"]?.toString();
      if (salt == null ||
          hash == null ||
          hash != PasswordService.hash(passwordController.text.trim(), salt)) {
        mostrarError("Contraseña incorrecta");
        setState(() => cargando = false);
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString("usuario_id", usuario["_id"].toHexString());

      await prefs.setString("correo", usuario["correo"]);
      await prefs.setString("nombre", usuario["nombre_usuario"]);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PanicButtonScreen()),
      );
    } catch (e) {
      mostrarError("Error al iniciar sesión");
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
    bool password = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: PanicTextStyles.inputLabel),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: password ? !verPassword : obscureText,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.3),
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'lib/assets/images/sos365red.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),

                  const Text("Iniciar Sesión", style: PanicTextStyles.title),
                  const SizedBox(height: 25),

                  buildInputField("Correo", correoController),
                  buildInputField(
                    "Contraseña",
                    passwordController,
                    password: true,
                  ),

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
                      onPressed: cargando ? null : iniciarSesion,
                      child: cargando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Entrar",
                              style: PanicTextStyles.buttonTitle,
                            ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: PanicColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CrearCuenta(),
                          ),
                        );
                      },
                      child: const Text(
                        "Crear cuenta",
                        style: TextStyle(
                          color: PanicColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RecuperarCuenta(),
                          ),
                        );
                      },
                      child: const Text(
                        "Recuperar contraseña",
                        style: TextStyle(
                          color: PanicColors.primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
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
