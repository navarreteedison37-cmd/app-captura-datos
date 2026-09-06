import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// Toma la ruta de una imagen y devuelve todo el texto plano que
/// Google ML Kit logra leer de ella (funciona sin internet).
class OcrService {
  final TextRecognizer _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> extraerTexto(String rutaImagen) async {
    final inputImage = InputImage.fromFile(File(rutaImagen));
    final RecognizedText resultado = await _recognizer.processImage(inputImage);
    return resultado.text;
  }

  void dispose() {
    _recognizer.close();
  }
}
