import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/historial_item.dart';

/// Guarda TODOS los documentos que se han generado (sin importar si fue
/// uno por uno o en carga masiva) en un archivo local (historial.json)
/// dentro del propio celular, para poder exportarlos despues a una
/// pagina HTML tipo tabla.
class HistorialService {
  Future<File> _archivoHistorial() async {
    final directorio = await getApplicationDocumentsDirectory();
    return File('${directorio.path}/historial.json');
  }

  Future<List<HistorialItem>> obtenerTodos() async {
    final archivo = await _archivoHistorial();
    if (!await archivo.exists()) return [];

    final contenido = await archivo.readAsString();
    if (contenido.trim().isEmpty) return [];

    final lista = jsonDecode(contenido) as List<dynamic>;
    return lista
        .map((item) => HistorialItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> agregarRegistro(HistorialItem nuevo) async {
    final actuales = await obtenerTodos();
    actuales.add(nuevo);

    final archivo = await _archivoHistorial();
    final jsonTexto = jsonEncode(actuales.map((e) => e.toJson()).toList());
    await archivo.writeAsString(jsonTexto);
  }

  /// Por si en algun momento se quiere empezar de cero.
  Future<void> borrarHistorial() async {
    final archivo = await _archivoHistorial();
    if (await archivo.exists()) {
      await archivo.delete();
    }
  }
}
