import 'package:flutter/material.dart';
import 'package:sos365/config/design_home.dart';
import 'package:pdfx/pdfx.dart';

class InfoModal extends StatefulWidget {
  const InfoModal({super.key});

  @override
  State<InfoModal> createState() => _InfoModalState();
}

class _InfoModalState extends State<InfoModal> {
  late PdfController _pdfController;

  @override
  void initState() {
    super.initState();

    _pdfController = PdfController(
      document: PdfDocument.openAsset("lib/assets/pdf/infografia.pdf"),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModalBase(
      title: "Información",
      child: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            const SizedBox(height: 10),

            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PdfView(
                  controller: _pdfController,
                  scrollDirection: Axis.vertical,
                ),
              ),
            ),
          ],
        ),
      ),
      onSave: () => Navigator.pop(context),
    );
  }
}
