import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import '../models/document_data.dart';
import '../models/historial_item.dart';
import 'historial_service.dart';

/// Modo unico que el usuario elige una sola vez.
enum ModoTrabajo { inspeccionLaboral, controlIngresos }

extension ModoTrabajoArchivo on ModoTrabajo {
  /// Nombre del archivo de plantilla dentro de assets/templates/
  String get nombreArchivoPlantilla {
    switch (this) {
      case ModoTrabajo.inspeccionLaboral:
        return 'assets/templates/inspeccion_laboral.docx';
      case ModoTrabajo.controlIngresos:
        return 'assets/templates/control_ingresos.docx';
    }
  }

  String get etiqueta {
    switch (this) {
      case ModoTrabajo.inspeccionLaboral:
        return 'Inspección Laboral';
      case ModoTrabajo.controlIngresos:
        return 'Control de Ingresos';
    }
  }
}

/// Busca automaticamente la plantilla correcta segun el modo, la rellena
/// con los datos extraidos de la foto, y guarda el .docx final en el
/// almacenamiento del dispositivo.
class TemplateService {
  /// Genera el documento Word final y devuelve la ruta del archivo creado.
  Future<String> generarDocumento({
    required ModoTrabajo modo,
    required DocumentData datos,
    String? nombreArchivoSalida,
  }) async {
    // 1. Cargar la plantilla correcta desde los assets (automatico segun el modo)
    final byteData = await rootBundle.load(modo.nombreArchivoPlantilla);
    final bytesPlantilla = byteData.buffer.asUint8List();

    // 2. Un .docx es un .zip: lo abrimos
    final archivo = ZipDecoder().decodeBytes(bytesPlantilla);

    // 3. Dentro del zip, el texto visible vive en word/document.xml
    final archivoModificado = Archive();
    for (final file in archivo) {
      if (file.isFile) {
        if (file.name == 'word/document.xml') {
          final contenidoOriginal = utf8.decode(file.content as List<int>);
          final contenidoRellenado = _reemplazarEtiquetas(contenidoOriginal, datos);
          final nuevosBytes = utf8.encode(contenidoRellenado);
          archivoModificado.addFile(
            ArchiveFile(file.name, nuevosBytes.length, nuevosBytes),
          );
        } else {
          archivoModificado.addFile(
            ArchiveFile(file.name, file.size, file.content),
          );
        }
      }
    }

    // 4. Volver a comprimir como .docx
    final bytesFinal = ZipEncoder().encode(archivoModificado);

    // 5. Guardar en el almacenamiento del dispositivo
    final directorio = await getApplicationDocumentsDirectory();
    final marcaTiempo = DateTime.now().millisecondsSinceEpoch;
    final nombreFinal = nombreArchivoSalida ?? '${modo.name}_$marcaTiempo.docx';
    final rutaSalida = '${directorio.path}/$nombreFinal';

    final archivoSalida = File(rutaSalida);
    await archivoSalida.writeAsBytes(bytesFinal!);

    // Guardar este documento en el historial (para poder exportarlo despues a HTML)
    await HistorialService().agregarRegistro(
      HistorialItem(datos: datos, modo: modo.etiqueta, fechaRegistro: DateTime.now()),
    );

    return rutaSalida;
  }

  /// Reemplaza cada etiqueta {{clave}} por su valor real.
  /// Tambien escapa caracteres especiales de XML (&, <, >) para que
  /// el documento Word no quede corrupto si el dato tiene esos simbolos.
  String _reemplazarEtiquetas(String xml, DocumentData datos) {
    String resultado = xml;
    datos.toTemplateMap().forEach((clave, valor) {
      final valorEscapado = _escaparXml(valor.isEmpty ? '-' : valor);
      resultado = resultado.replaceAll('{{$clave}}', valorEscapado);
    });
    return resultado;
  }

  String _escaparXml(String texto) {
    return texto
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }
}
