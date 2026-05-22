import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' hide State, Center;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sos365/config/design_home.dart';
import 'package:sos365/services/mongodb_service.dart';

class HistoryModal extends StatefulWidget {
  const HistoryModal({super.key});

  @override
  State<HistoryModal> createState() => _HistoryModalState();
}

class _HistoryModalState extends State<HistoryModal> {
  List<Map<String, dynamic>> alertas = [];
  bool cargando = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _cargarAlertas();
  }

  Future<void> _cargarAlertas() async {
    try {
      await MongoService.ensureConnected();
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("usuario_id") ?? "";

      if (userId.isEmpty) throw Exception("Usuario no identificado");

      final resultado = await MongoService.alertas!
          .find(where.eq("usuario_id", ObjectId.fromHexString(userId)))
          .toList();

      resultado.sort((a, b) {
        final fa = a["fecha_hora"];
        final fb = b["fecha_hora"];
        if (fa == null || fb == null) return 0;
        return (fb as DateTime).compareTo(fa as DateTime);
      });

      if (mounted) {
        setState(() {
          alertas = resultado;
          cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          cargando = false;
        });
      }
    }
  }

  String _formatFecha(dynamic fecha) {
    if (fecha == null) return "Sin fecha";
    final dt = fecha is DateTime ? fecha : DateTime.tryParse(fecha.toString());
    if (dt == null) return "Sin fecha";
    return "${dt.day.toString().padLeft(2, '0')}/"
        "${dt.month.toString().padLeft(2, '0')}/"
        "${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
  }

  void _abrirDetalle(Map<String, dynamic> alerta) {
    showDialog(
      context: context,
      builder: (_) => _AlertaDetalleModal(alerta: alerta),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModalBase(
      title: "Historial de Alertas",
      onSave: () => Navigator.pop(context),
      child: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.65,
        child: cargando
            ? const Center(child: CircularProgressIndicator(color: Colors.red))
            : error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              )
            : alertas.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.notifications_none,
                      size: 56,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      "No hay alertas registradas",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
                itemCount: alertas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final alerta = alertas[index];
                  final coords = alerta["coordenadas"];
                  final lat = coords?["lat"];
                  final lng = coords?["lng"];

                  return GestureDetector(
                    onTap: () => _abrirDetalle(alerta),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.red.withOpacity(0.25)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.red.withOpacity(0.1),
                            child: const Icon(
                              Icons.notifications_active,
                              color: Colors.redAccent,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatFecha(alerta["fecha_hora"]),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (lat != null && lng != null)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.black38,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          "${(lat as num).toStringAsFixed(5)}, "
                                          "${(lng as num).toStringAsFixed(5)}",
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 11,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// MINI MODAL DE DETALLE DE ALERTA
// ─────────────────────────────────────────────
class _AlertaDetalleModal extends StatelessWidget {
  final Map<String, dynamic> alerta;

  const _AlertaDetalleModal({required this.alerta});

  String _formatFecha(dynamic fecha) {
    if (fecha == null) return "Sin fecha";
    final dt = fecha is DateTime ? fecha : DateTime.tryParse(fecha.toString());
    if (dt == null) return "Sin fecha";
    return "${dt.day.toString().padLeft(2, '0')}/"
        "${dt.month.toString().padLeft(2, '0')}/"
        "${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:"
        "${dt.minute.toString().padLeft(2, '0')}";
  }

  Widget _seccion(
    String titulo,
    IconData icono,
    Widget contenido, {
    Color? iconColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icono, color: iconColor ?? Colors.black45, size: 15),
            const SizedBox(width: 6),
            Text(
              titulo,
              style: const TextStyle(
                color: Colors.black45,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        contenido,
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final coords = alerta["coordenadas"];
    final lat = coords?["lat"] as num?;
    final lng = coords?["lng"] as num?;
    final multimedia = alerta["multimedia"];
    final fecha = _formatFecha(alerta["fecha_hora"]);

    final fotoFrontalId = multimedia?["frontal"]?["foto_id"];
    final fotoTrseraId = multimedia?["trasera"]?["foto_id"];
    final videoId = multimedia?["trasera"]?["video_id"];
    final audioId = multimedia?["audio_id"];

    bool tieneArchivo(dynamic id) {
      if (id == null) return false;
      final hex = id is ObjectId ? id.toHexString() : id.toString();
      return hex != "000000000000000000000000";
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
        ),
        // ✅ ClipRRect evita overflow visual (raya amarilla de Flutter)
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ───────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: const BoxDecoration(color: Color(0xFFFFEBEB)),
                child: Row(
                  children: const [
                    Icon(
                      Icons.notifications_active,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Detalle de Alerta",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Contenido scrollable ──────────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fecha
                      _seccion(
                        "FECHA Y HORA",
                        Icons.access_time,
                        Text(
                          fecha,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // Mapa
                      if (lat != null && lng != null)
                        _seccion(
                          "UBICACIÓN",
                          Icons.location_on,
                          iconColor: Colors.redAccent,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  height: 160,
                                  child: FlutterMap(
                                    options: MapOptions(
                                      initialCenter: LatLng(
                                        lat.toDouble(),
                                        lng.toDouble(),
                                      ),
                                      initialZoom: 16,
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                        userAgentPackageName:
                                            "com.example.sos365",
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            point: LatLng(
                                              lat.toDouble(),
                                              lng.toDouble(),
                                            ),
                                            width: 40,
                                            height: 40,
                                            child: const Icon(
                                              Icons.location_pin,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.my_location,
                                    color: Colors.black38,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      "${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}",
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                      // Multimedia
                      _seccion(
                        "MULTIMEDIA REGISTRADA",
                        Icons.perm_media,
                        Column(
                          children: [
                            _archivoTile(
                              "Foto Frontal",
                              Icons.camera_front,
                              tieneArchivo(fotoFrontalId),
                            ),
                            const SizedBox(height: 8),
                            _archivoTile(
                              "Foto Trasera",
                              Icons.camera_rear,
                              tieneArchivo(fotoTrseraId),
                            ),
                            const SizedBox(height: 8),
                            _archivoTile(
                              "Video (4s)",
                              Icons.videocam,
                              tieneArchivo(videoId),
                            ),
                            const SizedBox(height: 8),
                            _archivoTile(
                              "Audio",
                              Icons.mic,
                              tieneArchivo(audioId),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Footer ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cerrar",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _archivoTile(String nombre, IconData icono, bool disponible) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: disponible
            ? Colors.blue.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: disponible ? Colors.blue.withOpacity(0.15) : Colors.black12,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icono,
            color: disponible ? Colors.blue : Colors.black26,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nombre,
              style: TextStyle(
                color: disponible ? Colors.black87 : Colors.black38,
                fontSize: 13,
              ),
            ),
          ),
          Icon(
            disponible ? Icons.check_circle : Icons.cancel,
            color: disponible ? Colors.green : Colors.black26,
            size: 16,
          ),
        ],
      ),
    );
  }
}
