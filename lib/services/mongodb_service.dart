import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  static Db? db;
  static DbCollection? usuarios;
  static DbCollection? contactos;
  static DbCollection? alertas;

  static const String _uri = String.fromEnvironment('MONGO_URI');

  static Future<void> connect() async {
    if (_uri.isEmpty) {
      print("MongoDB no configurado. Usa un backend seguro para producción.");
      return;
    }

    try {
      if (db != null && db!.isConnected) {
        await db!.close();
      }

      db = await Db.create(_uri);
      await db!.open();

      usuarios = db!.collection("usuarios");
      contactos = db!.collection("contactos");
      alertas = db!.collection("alertas");

      print("✅ Conectado a MongoDB Atlas");
    } catch (e) {
      print("❌ Error conectando a MongoDB: $e");
      rethrow;
    }
  }

  static Future<void> ensureConnected() async {
    if (_uri.isEmpty) {
      throw StateError(
        "MongoDB no está configurado. La app debe conectarse mediante un backend.",
      );
    }

    if (db == null || !db!.isConnected) {
      print("⚠️ MongoDB desconectado, reconectando...");
      await connect();
    }
  }
}
