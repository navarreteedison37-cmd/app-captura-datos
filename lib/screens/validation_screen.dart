import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/document_data.dart';
import '../services/modo_service.dart';
import '../services/template_service.dart';

/// Muestra los campos extraidos por el OCR en un formulario editable.
/// El usuario corrige lo que el OCR leyo mal, y al confirmar se genera
/// automaticamente el Word (buscando la plantilla segun el modo elegido).
class ValidationScreen extends StatefulWidget {
  final DocumentData datosIniciales;
  final String? rutaImagenOriginal;

  /// Si es true (se usa desde la Carga Masiva), el boton solo GUARDA los
  /// cambios y regresa a la lista; no genera el Word todavia (eso se
  /// hace despues, todos juntos, con el boton "Generar" de la lista).
  final bool soloEditarYDevolver;

  const ValidationScreen({
    super.key,
    required this.datosIniciales,
    this.rutaImagenOriginal,
    this.soloEditarYDevolver = false,
  });

  @override
  State<ValidationScreen> createState() => _ValidationScreenState();
}

class _ValidationScreenState extends State<ValidationScreen> {
  late Map<String, TextEditingController> _controladores;
  bool _generando = false;

  final List<MapEntry<String, String>> _campos = const [
    MapEntry('ruc', 'RUC'),
    MapEntry('nombreRazonSocial', 'Nombre o Razón Social'),
    MapEntry('numeroActa', 'N° de Acta'),
    MapEntry('numeroCarta', 'N° de Carta'),
    MapEntry('recepcionadoPor', 'Recepcionado por'),
    MapEntry('vinculo', 'Vínculo'),
    MapEntry('dni', 'DNI'),
    MapEntry('fechaInicio', 'Fecha de Inicio'),
    MapEntry('fechaHora', 'Fecha y Hora'),
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.datosIniciales;
    _controladores = {
      'ruc': TextEditingController(text: d.ruc),
      'nombreRazonSocial': TextEditingController(text: d.nombreRazonSocial),
      'numeroActa': TextEditingController(text: d.numeroActa),
      'numeroCarta': TextEditingController(text: d.numeroCarta),
      'recepcionadoPor': TextEditingController(text: d.recepcionadoPor),
      'vinculo': TextEditingController(text: d.vinculo),
      'dni': TextEditingController(text: d.dni),
      'fechaInicio': TextEditingController(text: d.fechaInicio),
      'fechaHora': TextEditingController(text: d.fechaHora),
    };
  }

  DocumentData _datosDesdeFormulario() {
    return DocumentData(
      ruc: _controladores['ruc']!.text,
      nombreRazonSocial: _controladores['nombreRazonSocial']!.text,
      numeroActa: _controladores['numeroActa']!.text,
      numeroCarta: _controladores['numeroCarta']!.text,
      recepcionadoPor: _controladores['recepcionadoPor']!.text,
      vinculo: _controladores['vinculo']!.text,
      dni: _controladores['dni']!.text,
      fechaInicio: _controladores['fechaInicio']!.text,
      fechaHora: _controladores['fechaHora']!.text,
    );
  }

  Future<void> _confirmarYGenerar() async {
    if (widget.soloEditarYDevolver) {
      Navigator.of(context).pop(_datosDesdeFormulario());
      return;
    }

    setState(() => _generando = true);
    try {
      final modo = await ModoService().obtenerModoGuardado();
      if (modo == null) {
        throw Exception('No se ha elegido un modo (Inspección Laboral / Control de Ingresos).');
      }

      final ruta = await TemplateService().generarDocumento(
        modo: modo,
        datos: _datosDesdeFormulario(),
      );

      if (!mounted) return;

      // Ofrecer compartir/guardar el Word ya generado
      await Share.shareXFiles([XFile(ruta)], text: 'Documento generado: ${modo.etiqueta}');

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar el documento: $e')),
      );
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  @override
  void dispose() {
    for (final c in _controladores.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validar datos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Revisa y corrige los datos leídos antes de generar el documento.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          for (final campo in _campos) ...[
            TextField(
              controller: _controladores[campo.key],
              decoration: InputDecoration(
                labelText: campo.value,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: _generando
                ? const SizedBox(
                    width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.description),
            label: Text(_generando
                ? 'Generando...'
                : (widget.soloEditarYDevolver ? 'Guardar cambios' : 'Confirmar y generar Word')),
            onPressed: _generando ? null : _confirmarYGenerar,
          ),
        ],
      ),
    );
  }
}
