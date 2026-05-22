import 'package:flutter/material.dart';
import '../config/design_auth.dart';

/// ===== FUNCIONES DE NAVEGACIÓN =====

/// Navega a otra pantalla
void navigateTo(BuildContext context, Widget screen) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}

/// Navega reemplazando la pantalla actual
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

/// ===== MODAL BASE =====

Widget modalBase({
  required String title,
  required Widget child,
  VoidCallback? onSave,
}) {
  return PanicDecorations.fadeIn(
    Container(
      padding: const EdgeInsets.all(22),
      decoration: PanicDecorations.card,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// TITULO
          Text(
            title,
            style: PanicTextStyles.title,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          /// CONTENIDO
          child,

          /// BOTÓN OPCIONAL
          if (onSave != null) ...[
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSave,
                style: PanicDecorations.primaryButton,
                child: const Text(
                  "Aceptar",
                  style: PanicTextStyles.buttonTitle,
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
