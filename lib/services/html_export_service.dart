import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/historial_item.dart';

/// Convierte la lista de registros del historial en una pagina HTML
/// con una tabla, lista para abrir en cualquier navegador (se ve y se
/// comporta como una hoja de Excel, pero es un archivo .html).
class HtmlExportService {
  Future<String> exportar(List<HistorialItem> registros) async {
    final directorio = await getApplicationDocumentsDirectory();
    final marcaTiempo = DateTime.now().millisecondsSinceEpoch;
    final ruta = '${directorio.path}/historial_$marcaTiempo.html';

    final html = _construirHtml(registros);
    final archivo = File(ruta);
    await archivo.writeAsString(html);
    return ruta;
  }

  String _construirHtml(List<HistorialItem> registros) {
    final filas = registros.map((r) {
      final d = r.datos;
      return '''
        <tr>
          <td>${_e(r.fechaRegistro.toString().substring(0, 16))}</td>
          <td>${_e(r.modo)}</td>
          <td>${_e(d.ruc)}</td>
          <td>${_e(d.nombreRazonSocial)}</td>
          <td>${_e(d.numeroActa)}</td>
          <td>${_e(d.numeroCarta)}</td>
          <td>${_e(d.recepcionadoPor)}</td>
          <td>${_e(d.vinculo)}</td>
          <td>${_e(d.dni)}</td>
          <td>${_e(d.fechaInicio)}</td>
          <td>${_e(d.fechaHora)}</td>
        </tr>
      ''';
    }).join();

    return '''
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Historial de documentos</title>
<style>
  body { font-family: Arial, sans-serif; margin: 20px; }
  h1 { font-size: 20px; }
  table { border-collapse: collapse; width: 100%; font-size: 13px; }
  th, td { border: 1px solid #ccc; padding: 6px 8px; text-align: left; }
  th { background-color: #2c3e50; color: white; position: sticky; top: 0; }
  tr:nth-child(even) { background-color: #f5f5f5; }
</style>
</head>
<body>
  <h1>Historial de documentos capturados (${registros.length} registros)</h1>
  <table>
    <thead>
      <tr>
        <th>Fecha de registro</th>
        <th>Modo</th>
        <th>RUC</th>
        <th>Nombre / Razón Social</th>
        <th>N° Acta</th>
        <th>N° Carta</th>
        <th>Recepcionado por</th>
        <th>Vínculo</th>
        <th>DNI</th>
        <th>Fecha de Inicio</th>
        <th>Fecha y Hora</th>
      </tr>
    </thead>
    <tbody>
      $filas
    </tbody>
  </table>
</body>
</html>
''';
  }

  /// Escapa caracteres especiales para que no rompan el HTML.
  String _e(String texto) {
    return texto
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }
}
