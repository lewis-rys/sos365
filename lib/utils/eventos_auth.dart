import 'package:flutter/material.dart';
import '../config/design_auth.dart';


void navigateTo(BuildContext context, Widget screen) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
}

void navigateToReplacement(BuildContext context, Widget screen) {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screen));
}


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
          Text(
            title,
            style: PanicTextStyles.title,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          child,

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
