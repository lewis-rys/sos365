import 'package:mongo_dart/mongo_dart.dart';

class MongoService {
  static Db? db;
  static DbCollection? usuarios;
  static DbCollection? contactos;
  static DbCollection? alertas;

  // ✅ URI con safeAtlas=true para evitar ConnectionException en Atlas
  static const String _uri =
      "mongodb+srv://jamesreyes001:genessisbb@cluster365.sgyekda.mongodb.net/"
      "SOS365?retryWrites=true&w=majority&safeAtlas=true";

  static Future<void> connect() async {
    try {
      // ✅ Cerrar conexión previa si existe (para reconexiones limpias)
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

  /// Reconecta si la conexión está caída. Útil antes de operaciones críticas.
  static Future<void> ensureConnected() async {
    if (db == null || !db!.isConnected) {
      print("⚠️ MongoDB desconectado, reconectando...");
      await connect();
    }
  }
}
//api: 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