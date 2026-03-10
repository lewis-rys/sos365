import 'package:flutter/material.dart';
import '../config/design_auth.dart';

/// ===== FUNCIONES DE NAVEGACIÓN =====

/// Navega a otra pantalla (push normal)
void navigateTo(BuildContext context, Widget screen) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}

/// Navega a otra pantalla reemplazando la actual
void navigateToReplacement(BuildContext context, Widget screen) {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screen));
}

/// ===== FUNCIONES DE MODALES =====

/// Abre un modal centrado
void openModal(BuildContext context, Widget content) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: content,
    ),
  );
}

/// Modal base genérico
Widget modalBase({
  required String title,
  required Widget child,
  VoidCallback? onSave,
}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        child,
        if (onSave != null) ...[
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: PanicColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              minimumSize: const Size(double.infinity, 45),
            ),
            child: const Text(
              "Aceptar",
              style: PanicTextStyles.modalButtonText,
            ),
          ),
        ],
      ],
    ),
  );
}
