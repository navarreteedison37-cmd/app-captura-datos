import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../models/document_data.dart';
import '../services/ocr_service.dart';
import '../services/parser_service.dart';
import '../services/modo_service.dart';
import '../services/template_service.dart';
import 'validation_screen.dart';

/// Permite elegir VARIAS fotos a la vez desde la galeria, les aplica OCR
/// a todas, y muestra una lista donde se puede revisar/editar cada una
/// antes de generar los documentos Word finales.
class BulkUploadScreen extends StatefulWidget {
  const BulkUploadScreen({super.key});

  @override
  State<BulkUploadScreen> createState() => _BulkUploadScreenState();
}

class _BulkUploadScreenState extends State<BulkUploadScreen> {
  final List<_ItemProcesado> _items = [];
  bool _procesando = false;

  Future<void> _seleccionarFotos() async {
    final picker = ImagePicker();
    final imagenes = await picker.pickMultiImage(imageQuality: 90);
    if (imagenes.isEmpty) return;

    setState(() => _procesando = true);
    final ocrService = OcrService();
    final parser = ParserService();

    try {
      for (final imagen in imagenes) {
        final texto = await ocrService.extraerTexto(imagen.path);
        final datos = parser.parsear(texto);
        _items.add(_ItemProcesado(rutaImagen: imagen.path, datos: datos));
      }
    } finally {
      ocrService.dispose();
      if (mounted) setState(() => _procesando = false);
    }
  }

  Future<void> _generarTodos() async {
    final modo = await ModoService().obtenerModoGuardado();
    if (modo == null) return;

    setState(() => _procesando = true);
    final rutasGeneradas = <String>[];
    try {
      for (final item in _items) {
        if (!item.validado) continue;
        final ruta = await TemplateService().generarDocumento(
          modo: modo,
          datos: item.datos,
        );
        rutasGeneradas.add(ruta);
      }

      if (rutasGeneradas.isNotEmpty) {
        await Share.shareXFiles(
          rutasGeneradas.map((r) => XFile(r)).toList(),
          text: 'Documentos generados (${rutasGeneradas.length})',
        );
      }
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carga masiva')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _procesando ? null : _seleccionarFotos,
        icon: const Icon(Icons.add_photo_alternate),
        label: const Text('Agregar fotos'),
      ),
      body: _procesando
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(child: Text('Aún no has agregado fotos.'))
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: Icon(
                          item.validado ? Icons.check_circle : Icons.warning_amber,
                          color: item.validado ? Colors.green : Colors.orange,
                        ),
                        title: Text(item.datos.nombreRazonSocial.isEmpty
                            ? 'Documento ${index + 1} (revisar)'
                            : item.datos.nombreRazonSocial),
                        subtitle: Text('DNI: ${item.datos.dni.isEmpty ? "-" : item.datos.dni}'
                            '  |  RUC: ${item.datos.ruc.isEmpty ? "-" : item.datos.ruc}'),
                        trailing: const Icon(Icons.edit),
                        onTap: () async {
                          final resultado = await Navigator.of(context).push<DocumentData>(
                            MaterialPageRoute(
                              builder: (_) => ValidationScreen(
                                datosIniciales: item.datos,
                                rutaImagenOriginal: item.rutaImagen,
                                soloEditarYDevolver: true,
                              ),
                            ),
                          );
                          setState(() {
                            item.validado = true;
                            if (resultado != null) item.datos = resultado;
                          });
                        },
                      ),
                    );
                  },
                ),
      bottomNavigationBar: _items.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                onPressed: _procesando ? null : _generarTodos,
                child: Text('Generar ${_items.where((e) => e.validado).length} documento(s)'),
              ),
            ),
    );
  }
}

class _ItemProcesado {
  final String rutaImagen;
  DocumentData datos;
  bool validado;

  _ItemProcesado({
    required this.rutaImagen,
    required this.datos,
    this.validado = false,
  });
}
