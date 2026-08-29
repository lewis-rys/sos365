import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'services/mongodb_service.dart';
import 'screens/auth/iniciarsesion.dart';
import 'screens/home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MongoService.connect();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget pantallaInicial = const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );

  @override
  void initState() {
    super.initState();
    verificarSesion();
  }

  Future<void> verificarSesion() async {
    final prefs = await SharedPreferences.getInstance();

    String? correo = prefs.getString("correo");

    setState(() {
      if (correo != null) {
        pantallaInicial = const PanicButtonScreen();
      } else {
        pantallaInicial = const IniciarSesion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: pantallaInicial,
    );
  }
}
