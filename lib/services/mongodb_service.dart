import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  static Db? db;
  static DbCollection? usuarios;
  static DbCollection? contactos;
  static DbCollection? alertas;

  static const String _uri =
      "mongodb+srv://REDACTED/REDACTED"
      "SOS365?retryWrites=true&w=majority&safeAtlas=true";

  static Future<void> connect() async {
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
    if (db == null || !db!.isConnected) {
      print("⚠️ MongoDB desconectado, reconectando...");
      await connect();
    }
  }
}
