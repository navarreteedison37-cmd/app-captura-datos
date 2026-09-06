import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/modo_service.dart';
import '../services/template_service.dart';
import '../services/historial_service.dart';
import '../services/html_export_service.dart';
import 'capture_screen.dart';
import 'bulk_upload_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _exportarHistorial(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generando historial...')),
    );
    try {
      final registros = await HistorialService().obtenerTodos();
      if (registros.isEmpty) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todavía no hay documentos generados.')),
        );
        return;
      }
      final ruta = await HtmlExportService().exportar(registros);
      await Share.shareXFiles([XFile(ruta)], text: 'Historial de documentos (${registros.length})');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al exportar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Captura de Datos')),
      body: FutureBuilder<ModoTrabajo?>(
        future: ModoService().obtenerModoGuardado(),
        builder: (context, snapshot) {
          final modo = snapshot.data;
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (modo != null)
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('Modo actual: ${modo.etiqueta}'),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt),
                  label: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Tomar foto (1 documento)'),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CaptureScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Carga masiva (varias fotos)'),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BulkUploadScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.table_chart_outlined),
                  label: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Exportar historial (HTML)'),
                  ),
                  onPressed: () => _exportarHistorial(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
