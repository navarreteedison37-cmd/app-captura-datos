import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/document_data.dart';
import '../services/ocr_service.dart';
import '../services/parser_service.dart';
import 'validation_screen.dart';

/// Toma o selecciona UNA foto, le aplica OCR, extrae los campos, y
/// pasa a la pantalla de validacion para que el usuario confirme/corrija.
class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  bool _procesando = false;

  Future<void> _tomarFoto(ImageSource origen) async {
    final picker = ImagePicker();
    final imagen = await picker.pickImage(source: origen, imageQuality: 90);
    if (imagen == null) return;

    setState(() => _procesando = true);

    final ocrService = OcrService();
    try {
      final texto = await ocrService.extraerTexto(imagen.path);
      final datos = ParserService().parsear(texto);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ValidationScreen(
            datosIniciales: datos,
            rutaImagenOriginal: imagen.path,
          ),
        ),
      );
    } finally {
      ocrService.dispose();
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capturar documento')),
      body: Center(
        child: _procesando
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Leyendo el documento...'),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Usar la cámara'),
                      onPressed: () => _tomarFoto(ImageSource.camera),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Elegir de la galería'),
                      onPressed: () => _tomarFoto(ImageSource.gallery),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
