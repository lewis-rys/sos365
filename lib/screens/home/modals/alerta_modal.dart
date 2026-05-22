import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mongo_dart/mongo_dart.dart' hide State, Center;
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart' as audioplayers;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:sos365/config/design_home.dart';
import 'package:sos365/services/mongodb_service.dart';

class AlertaModal extends StatefulWidget {
  final Map<String, dynamic> alertaData;
  final String nombreUsuario;

  const AlertaModal({
    super.key,
    required this.alertaData,
    required this.nombreUsuario,
  });

  @override
  State<AlertaModal> createState() => _AlertaModalState();
}

class _AlertaModalState extends State<AlertaModal> {
  bool cargando = true;
  bool alertaEnviada = false;
  String? errorAlerta;
  String mensajeCarga = "Iniciando protocolo..."; // Mensaje dinámico

  // ✅ NUEVO: lista de correos a los que se envió la alerta
  List<String> correosNotificados = [];

  CameraController? _cameraController;

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _recorderReady = false;

  final audioplayers.AudioPlayer _audioPlayer = audioplayers.AudioPlayer();
  String? audioPath;
  bool _audioPlaying = false;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;
  StreamSubscription? _audioPositionSub;
  StreamSubscription? _audioDurationSub;
  StreamSubscription? _audioStateSub;

  Map<String, dynamic> multimedia = {};
  VideoPlayerController? _videoBack;
  LatLng? ubicacion;

  @override
  void initState() {
    super.initState();
    _setupAudioListeners();
    _initProceso();
  }

  void _setupAudioListeners() {
    _audioPositionSub = _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _audioPosition = pos);
    });
    _audioDurationSub = _audioPlayer.onDurationChanged.listen((dur) {
      if (mounted) setState(() => _audioDuration = dur);
    });
    _audioStateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(
          () => _audioPlaying = state == audioplayers.PlayerState.playing,
        );
      }
    });
  }

  @override
  void dispose() {
    _audioPositionSub?.cancel();
    _audioDurationSub?.cancel();
    _audioStateSub?.cancel();
    unawaited(_cleanupResources());
    super.dispose();
  }

  Future<void> _cleanupResources() async {
    try {
      if (_cameraController != null &&
          _cameraController!.value.isRecordingVideo) {
        await _cameraController!.stopVideoRecording();
      }
      if (_recorder.isRecording) await _recorder.stopRecorder();
    } catch (_) {}
    if (_recorderReady) {
      try {
        await _recorder.closeRecorder();
      } catch (_) {}
    }
    await _disposeCamera();
    _videoBack?.dispose();
    _audioPlayer.dispose();
  }

  Future<void> _initProceso() async {
    try {
      setState(() {
        cargando = true;
        mensajeCarga = "Obteniendo ubicación...";
      });

      final coords = await _obtenerCoordenadas();
      final userId = await _obtenerUsuarioId();

      if (userId.isEmpty) {
        throw Exception("Usuario ID no encontrado. Inicia sesión primero.");
      }

      ubicacion = LatLng(coords["lat"]!, coords["lng"]!);
      await _initRecorder();

      final cams = await availableCameras();
      if (cams.isEmpty) throw Exception("No hay cámaras disponibles");

      CameraDescription? frontCam, backCam;
      for (var cam in cams) {
        if (cam.lensDirection == CameraLensDirection.front) frontCam = cam;
        if (cam.lensDirection == CameraLensDirection.back) backCam = cam;
      }
      frontCam ??= cams.length > 1 ? cams[1] : cams.first;
      backCam ??= cams.first;

      // --- CAPTURA DE MEDIOS ---
      setState(() => mensajeCarga = "Capturando foto frontal...");
      final fotoFrontal = await _capturarFoto(frontCam, "front.jpg");

      setState(() => mensajeCarga = "Capturando foto trasera...");
      final fotoTrasera = await _capturarFoto(backCam, "back.jpg");

      setState(() => mensajeCarga = "Grabando video y audio (4s)...");
      final videoTrasera = await _capturarVideoConAudio(backCam);

      // --- SUBIDA A MONGO ---
      setState(() => mensajeCarga = "Sincronizando con el servidor...");
      await MongoService.ensureConnected();

      final uploadResults = await Future.wait([
        _subirArchivo(fotoFrontal),
        _subirArchivo(fotoTrasera),
        _subirArchivo(""),
        _subirArchivo(videoTrasera),
        _subirArchivo(audioPath ?? ""),
      ]);

      multimedia = {
        "frontal": {
          "foto": fotoFrontal,
          "video": "",
          "foto_id": uploadResults[0],
          "video_id": uploadResults[2],
        },
        "trasera": {
          "foto": fotoTrasera,
          "video": videoTrasera,
          "foto_id": uploadResults[1],
          "video_id": uploadResults[3],
        },
        "audio": audioPath ?? "",
        "audio_id": uploadResults[4],
      };

      // Preparar visualización
      if (videoTrasera.isNotEmpty) {
        _videoBack = VideoPlayerController.file(File(videoTrasera))
          ..initialize().then((_) {
            if (mounted) setState(() {});
          });
      }

      if (audioPath != null && audioPath!.isNotEmpty) {
        await _audioPlayer.setSourceDeviceFile(audioPath!);
      }

      widget.alertaData.clear();
      widget.alertaData.addAll({
        "usuario_id": ObjectId.fromHexString(userId),
        "fecha_hora": DateTime.now(),
        "coordenadas": coords,
        "multimedia": multimedia,
        "estado": "pendiente",
      });

      // ✅ ENVÍO DE ALERTA Y CORREOS
      setState(() => mensajeCarga = "Enviando alertas a tus contactos...");
      await _enviarAlertaYCorreos(userId);

      if (mounted) {
        setState(() {
          cargando = false;
          alertaEnviada = true;
        });
      }
    } catch (e) {
      debugPrint("error AlertaModal: $e");
      if (mounted) {
        setState(() {
          cargando = false;
          errorAlerta = "Error crítico: ${e.toString()}";
        });
      }
    }
  }

  Future<void> _enviarAlertaYCorreos(String userId) async {
    await MongoService.ensureConnected();

    // 1. Guardar en MongoDB
    await MongoService.alertas!.insertOne(widget.alertaData);

    // 2. Buscar contactos del usuario
    if (MongoService.contactos != null) {
      final contactos = await MongoService.contactos!
          .find(where.eq("usuario_id", ObjectId.fromHexString(userId)))
          .toList();

      if (contactos.isNotEmpty) {
        // ✅ Los correos están dentro del array "contactos" de cada documento
        final correos = <String>[];
        for (final doc in contactos) {
          final lista = doc["contactos"];
          if (lista is List) {
            for (final c in lista) {
              final correo = c["correo"];
              if (correo != null && correo.toString().isNotEmpty) {
                correos.add(correo.toString());
              }
            }
          }
        }

        // ✅ Guardar correos para mostrarlos en la UI
        if (mounted) {
          setState(() {
            correosNotificados = correos;
          });
        }

        try {
          await _enviarCorreo(correos);
        } catch (e) {
          debugPrint("Error en envío de email: $e");
          // No lanzamos error aquí para permitir que el modal se cierre aunque el mail falle
        }
      }
    }
  }

  /// ✅ ACTUALIZADO: Envío via SMTP Brevo (reemplaza la API REST anterior)
  Future<void> _enviarCorreo(List<String> correos) async {
    if (correos.isEmpty) return;

    // ── Credenciales SMTP Brevo ──────────────────────────────────────────────
    const smtpHost = 'smtp-relay.brevo.com';
    const smtpPort = 587;
    const smtpUser = 'a6a573001@smtp-brevo.com';
    const smtpPass =
        'REDACTED_BREVO_SMTP_SECRET';
    const senderEmail = 'sos365oficial@gmail.com';
    const senderName = 'SOS365';
    // ────────────────────────────────────────────────────────────────────────

    final smtpServer = SmtpServer(
      smtpHost,
      port: smtpPort,
      username: smtpUser,
      password: smtpPass,
      ssl: false,
      allowInsecure: true,
    );

    // Construir adjuntos
    final List<Attachment> attachments = [];

    Future<void> addAttachment(String path, String name) async {
      try {
        final file = File(path);
        if (await file.exists()) {
          attachments.add(FileAttachment(file)..fileName = name);
        }
      } catch (_) {}
    }

    if (multimedia["frontal"]?["foto"] != null &&
        (multimedia["frontal"]["foto"] as String).isNotEmpty) {
      await addAttachment(multimedia["frontal"]["foto"], "frontal.jpg");
    }

    if (multimedia["trasera"]?["foto"] != null &&
        (multimedia["trasera"]["foto"] as String).isNotEmpty) {
      await addAttachment(multimedia["trasera"]["foto"], "trasera.jpg");
    }

    if (multimedia["trasera"]?["video"] != null &&
        (multimedia["trasera"]["video"] as String).isNotEmpty) {
      await addAttachment(multimedia["trasera"]["video"], "video.mp4");
    }

    if (multimedia["audio"] != null &&
        (multimedia["audio"] as String).isNotEmpty) {
      await addAttachment(multimedia["audio"], "audio.aac");
    }

    final String cuerpo =
        "Usuario en peligro: ${widget.nombreUsuario}\n"
        "Ubicacion: ${ubicacion?.latitude}, ${ubicacion?.longitude}\n"
        "Mapa: https://www.google.com/maps?q=${ubicacion?.latitude},${ubicacion?.longitude}\n"
        "Hora: ${DateTime.now()}";

    final message = Message()
      ..from = Address(senderEmail, senderName)
      ..recipients.addAll(correos.map((e) => Address(e)))
      ..subject = "⚠️ ALERTA SOS365 - ${widget.nombreUsuario}"
      ..text = cuerpo
      ..attachments.addAll(attachments);

    final sendReport = await send(message, smtpServer);
    debugPrint("✅ Correo enviado via SMTP Brevo: $sendReport");
  }

  Future<String> _capturarFoto(CameraDescription cam, String fileName) async {
    await _disposeCamera();
    _cameraController = CameraController(
      cam,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _cameraController!.initialize();
    final pic = await _cameraController!.takePicture();
    final dir = await getTemporaryDirectory();
    final dest = "${dir.path}/$fileName";
    await File(pic.path).copy(dest);
    await _disposeCamera();
    return dest;
  }

  Future<String> _capturarVideoConAudio(CameraDescription cam) async {
    await _disposeCamera();
    _cameraController = CameraController(
      cam,
      ResolutionPreset.medium,
      enableAudio: true,
    );
    await _cameraController!.initialize();
    final dir = await getTemporaryDirectory();
    final videoPath = "${dir.path}/back.mp4";
    final audioPathTemp = "${dir.path}/audio.aac";

    await _recorder.startRecorder(toFile: audioPathTemp);
    await _cameraController!.startVideoRecording();

    await Future.delayed(const Duration(seconds: 4)); // Tiempo de grabación

    await _stopRecorderSafe();
    final videoFile = await _cameraController!.stopVideoRecording();

    await File(videoFile.path).copy(videoPath);
    audioPath = audioPathTemp;
    await _disposeCamera();
    return videoPath;
  }

  Future<void> _disposeCamera() async {
    if (_cameraController != null) {
      if (_cameraController!.value.isRecordingVideo) {
        try {
          await _cameraController!.stopVideoRecording();
        } catch (_) {}
      }
      await _cameraController!.dispose();
      _cameraController = null;
    }
  }

  Future<void> _stopRecorderSafe() async {
    try {
      if (_recorder.isRecording) await _recorder.stopRecorder();
    } catch (_) {}
  }

  Future<void> _initRecorder() async {
    await _recorder.openRecorder();
    _recorderReady = true;
  }

  Future<ObjectId> _subirArchivo(String path) async {
    if (path.isEmpty) return ObjectId.fromHexString("000000000000000000000000");
    final file = File(path);
    if (!await file.exists())
      return ObjectId.fromHexString("000000000000000000000000");
    final bytes = await file.readAsBytes();
    final grid = GridFS(MongoService.db!);
    final input = grid.createFile(Stream.value(bytes), path.split('/').last);
    await input.save();
    return input.id;
  }

  Future<Map<String, double>> _obtenerCoordenadas() async {
    final pos = await Geolocator.getCurrentPosition();
    return {"lat": pos.latitude, "lng": pos.longitude};
  }

  Future<String> _obtenerUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("usuario_id") ?? "";
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  // --- UI WIDGETS ---

  Widget _mapa() {
    if (ubicacion == null) return const SizedBox(height: 150);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 150,
        width: double.infinity,
        child: FlutterMap(
          options: MapOptions(initialCenter: ubicacion!, initialZoom: 16),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: "com.example.sos365",
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: ubicacion!,
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
    );
  }

  Widget _photoLabel(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _audioPlayerWidget() {
    final bool hasAudio = audioPath != null && audioPath!.isNotEmpty;
    final double progress = _audioDuration.inMilliseconds > 0
        ? (_audioPosition.inMilliseconds / _audioDuration.inMilliseconds).clamp(
            0.0,
            1.0,
          )
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.mic, color: Colors.redAccent, size: 16),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Audio grabado",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "${_fmt(_audioPosition)} / ${_fmt(_audioDuration)}",
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Colors.redAccent,
              inactiveTrackColor: Colors.white12,
            ),
            child: Slider(
              value: progress,
              onChanged: hasAudio
                  ? (val) => _audioPlayer.seek(
                      Duration(
                        milliseconds: (val * _audioDuration.inMilliseconds)
                            .toInt(),
                      ),
                    )
                  : null,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.replay_10,
                  color: Colors.white70,
                  size: 22,
                ),
                onPressed: hasAudio
                    ? () {
                        final np = _audioPosition - const Duration(seconds: 10);
                        _audioPlayer.seek(
                          np < Duration.zero ? Duration.zero : np,
                        );
                      }
                    : null,
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: hasAudio
                    ? () async {
                        if (_audioPlaying) {
                          await _audioPlayer.pause();
                        } else {
                          if (_audioPosition >= _audioDuration) {
                            await _audioPlayer.seek(Duration.zero);
                          }
                          await _audioPlayer.play(
                            audioplayers.DeviceFileSource(audioPath!),
                          );
                        }
                      }
                    : null,
                child: CircleAvatar(
                  backgroundColor: hasAudio ? Colors.redAccent : Colors.grey,
                  radius: 24,
                  child: Icon(
                    _audioPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(
                  Icons.forward_10,
                  color: Colors.white70,
                  size: 22,
                ),
                onPressed: hasAudio
                    ? () {
                        final np = _audioPosition + const Duration(seconds: 10);
                        _audioPlayer.seek(
                          np > _audioDuration ? _audioDuration : np,
                        );
                      }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ NUEVO WIDGET: muestra los correos a los que se notificó
  Widget _correosNotificadosWidget() {
    if (correosNotificados.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1B2A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.mark_email_read, color: Colors.greenAccent, size: 16),
              SizedBox(width: 8),
              Text(
                "Notificación enviada a:",
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...correosNotificados.map(
            (correo) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    color: Colors.white38,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      correo,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Si hay un error, el botón se habilita para cerrar.
    // Si está cargando, el botón es null (deshabilitado).
    // Si terminó, el botón se habilita.
    final VoidCallback? onSaveAction = (cargando)
        ? null
        : () => Navigator.pop(context);

    return PopScope(
      canPop:
          !cargando, // Evita cerrar el modal con el botón atrás mientras carga
      child: ModalBase(
        title: alertaEnviada
            ? "Alerta Enviada"
            : (errorAlerta != null ? "Error" : "SOS en Proceso"),
        // El botón en ModalBase se deshabilitará automáticamente si onSave es null
        onSave: onSaveAction ?? () {},
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (cargando)
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: Colors.red),
                      const SizedBox(height: 20),
                      Text(
                        mensajeCarga,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Por favor, no cierres la aplicación",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else if (errorAlerta != null)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 10),
                      Text(errorAlerta!, textAlign: TextAlign.center),
                      const SizedBox(height: 10),
                      const Text("Pulsa cerrar para intentar de nuevo."),
                    ],
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _mapa(),
                        const SizedBox(height: 12),
                        AspectRatio(
                          aspectRatio: 2 / 1,
                          child: Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(
                                        File(multimedia["frontal"]["foto"]),
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        bottom: 6,
                                        left: 6,
                                        child: _photoLabel("Frontal"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(
                                        File(multimedia["trasera"]["foto"]),
                                        fit: BoxFit.cover,
                                      ),
                                      Positioned(
                                        bottom: 6,
                                        left: 6,
                                        child: _photoLabel("Trasera"),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_videoBack != null &&
                            _videoBack!.value.isInitialized)
                          _VideoPlayerWidget(controller: _videoBack!)
                        else
                          const CircularProgressIndicator(),
                        const SizedBox(height: 12),
                        _audioPlayerWidget(),
                        const SizedBox(height: 12),

                        // ✅ NUEVO: bloque de correos notificados
                        _correosNotificadosWidget(),

                        const SizedBox(height: 16),
                        const Text(
                          "Los contactos de emergencia han sido notificados.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

// --- WIDGET DE VIDEO REUTILIZABLE ---
class _VideoPlayerWidget extends StatefulWidget {
  final VideoPlayerController controller;
  const _VideoPlayerWidget({required this.controller});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    widget.controller.removeListener(_update);
    super.dispose();
  }

  void _update() => setState(() {});

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;
    final pos = ctrl.value.position;
    final dur = ctrl.value.duration;
    final double progress = dur.inMilliseconds > 0
        ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        onTap: () {
          setState(() => _showControls = !_showControls);
          if (_showControls) _startHideTimer();
        },
        child: AspectRatio(
          aspectRatio: ctrl.value.aspectRatio,
          child: Stack(
            children: [
              VideoPlayer(ctrl),
              AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Stack(
                  children: [
                    Container(color: Colors.black38),
                    Center(
                      child: IconButton(
                        iconSize: 48,
                        icon: Icon(
                          ctrl.value.isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          ctrl.value.isPlaying ? ctrl.pause() : ctrl.play();
                          _startHideTimer();
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: Colors.black45,
                        child: Row(
                          children: [
                            Text(
                              _fmt(pos),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 2,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 4,
                                  ),
                                ),
                                child: Slider(
                                  value: progress,
                                  onChanged: (v) => ctrl.seekTo(
                                    Duration(
                                      milliseconds: (v * dur.inMilliseconds)
                                          .toInt(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              _fmt(dur),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
