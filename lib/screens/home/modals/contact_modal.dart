import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mongo_dart/mongo_dart.dart' hide State, Center;
import 'package:sos365/config/design_auth.dart';
import 'package:sos365/services/mongodb_service.dart';

class ContactModal extends StatefulWidget {
  const ContactModal({super.key});

  @override
  State<ContactModal> createState() => _ContactModalState();
}

class _ContactModalState extends State<ContactModal> {
  List<Map<String, dynamic>> contactos = [];
  bool cargando = true;
  late String idUsuario;

  ObjectId? get _objectId =>
      idUsuario.isNotEmpty ? ObjectId.fromHexString(idUsuario) : null;

  @override
  void initState() {
    super.initState();
    _cargarUsuarioYContactos();
  }

  Future<void> _cargarUsuarioYContactos() async {
    setState(() => cargando = true);

    final prefs = await SharedPreferences.getInstance();
    idUsuario = prefs.getString("usuario_id") ?? "";

    final id = _objectId;
    if (id == null) {
      setState(() {
        contactos = [];
        cargando = false;
      });
      return;
    }

    final docs = await MongoService.contactos!.find({
      "usuario_id": id,
    }).toList();

    if (docs.isEmpty) {
      setState(() {
        contactos = [];
        cargando = false;
      });
      return;
    }

    final doc = docs.first;

    setState(() {
      contactos = doc["contactos"] != null
          ? List<Map<String, dynamic>>.from(doc["contactos"])
          : [];
      cargando = false;
    });
  }

  bool _validarContacto(Map<String, dynamic> contacto) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final telefonoRegex = RegExp(r'^\d{10,15}$');

    return emailRegex.hasMatch(contacto["correo"]) &&
        telefonoRegex.hasMatch(contacto["telefono"]);
  }

  Future<void> _guardarContacto(
    Map<String, dynamic> contacto, {
    int? index,
  }) async {
    if (!_validarContacto(contacto)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Correo o teléfono inválido")),
      );
      return;
    }

    final id = _objectId;
    if (id == null) return;

    final docs = await MongoService.contactos!.find({
      "usuario_id": id,
    }).toList();

    Map<String, dynamic>? doc = docs.isNotEmpty ? docs.first : null;

    if (doc == null) {
      await MongoService.contactos!.insertOne({
        "usuario_id": id,
        "contactos": [contacto],
      });
      setState(() => contactos.add(contacto));
    } else {
      List lista = doc["contactos"] ?? [];

      if (index != null) {
        lista[index] = contacto;
        setState(() => contactos[index] = contacto);
      } else {
        if (lista.length >= 5) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Máximo 5 contactos")));
          return;
        }
        lista.add(contacto);
        setState(() => contactos.add(contacto));
      }

      await MongoService.contactos!.updateOne(
        {"_id": doc["_id"]},
        {
          "\$set": {"contactos": lista},
        },
      );
    }
  }

  Future<void> _eliminarContacto(int index) async {
    final id = _objectId;
    if (id == null) return;

    final doc = await MongoService.contactos!.findOne({"usuario_id": id});

    if (doc != null) {
      List lista = doc["contactos"] ?? [];
      lista.removeAt(index);

      await MongoService.contactos!.updateOne(
        {"_id": doc["_id"]},
        {
          "\$set": {"contactos": lista},
        },
      );

      setState(() => contactos.removeAt(index));
    }
  }

  /// ================= MODAL VER =================
  void _mostrarMiniModalLectura(Map<String, dynamic> contacto) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Información", style: PanicTextStyles.title),
              const SizedBox(height: 20),
              _infoText("Nombre", contacto["nombre"]),
              _infoText("Apellido", contacto["apellido"]),
              _infoText("Parentesco", contacto["parentesco"]),
              _infoText("Correo", contacto["correo"]),
              _infoText("Teléfono", contacto["telefono"]),
              const SizedBox(height: 20),
              ElevatedButton(
                style: PanicDecorations.primaryButton,
                onPressed: () => Navigator.pop(context),
                child: const Text("Cerrar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= MODAL EDITAR =================
  void _mostrarMiniModalEdicion({Map<String, dynamic>? contacto, int? index}) {
    final nombre = TextEditingController(text: contacto?["nombre"] ?? "");
    final apellido = TextEditingController(text: contacto?["apellido"] ?? "");
    final parentesco = TextEditingController(
      text: contacto?["parentesco"] ?? "",
    );
    final correo = TextEditingController(text: contacto?["correo"] ?? "");
    final telefono = TextEditingController(text: contacto?["telefono"] ?? "");

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(25),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  contacto != null ? "Editar contacto" : "Nuevo contacto",
                  style: PanicTextStyles.title,
                ),
                const SizedBox(height: 20),
                _inputField("Nombre", nombre),
                _inputField("Apellido", apellido),
                _inputField("Parentesco", parentesco),
                _inputField("Correo", correo),
                _inputField("Teléfono", telefono),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancelar"),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: PanicDecorations.primaryButton,
                        onPressed: () {
                          _guardarContacto({
                            "nombre": nombre.text.trim(),
                            "apellido": apellido.text.trim(),
                            "parentesco": parentesco.text.trim(),
                            "correo": correo.text.trim(),
                            "telefono": telefono.text.trim(),
                          }, index: index);

                          Navigator.pop(context);
                        },
                        child: Text(
                          contacto != null ? "Actualizar" : "Agregar",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: PanicTextStyles.inputLabel),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: PanicDecorations.inputDecoration(label),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _infoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text("$label: $value", style: PanicTextStyles.subtitle),
    );
  }

  /// ================= UI PRINCIPAL =================
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(25),
        child: cargando
            ? const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Contactos", style: PanicTextStyles.title),
                    const SizedBox(height: 20),

                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      child: contactos.isEmpty
                          ? const Center(child: Text("Sin contactos"))
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: contactos.length,
                              itemBuilder: (_, i) {
                                final c = contactos[i];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: PanicDecorations.card,
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: PanicColors.primary,
                                        child: Text(
                                          c["nombre"][0],
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(child: Text(c["nombre"])),
                                      IconButton(
                                        icon: const Icon(Icons.visibility),
                                        onPressed: () =>
                                            _mostrarMiniModalLectura(c),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () =>
                                            _mostrarMiniModalEdicion(
                                              contacto: c,
                                              index: i,
                                            ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => _eliminarContacto(i),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      style: PanicDecorations.primaryButton,
                      onPressed: contactos.length >= 5
                          ? null
                          : () => _mostrarMiniModalEdicion(),
                      child: const Text("Agregar contacto"),
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cerrar"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
