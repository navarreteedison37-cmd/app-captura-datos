import '../models/document_data.dart';

/// Convierte el texto plano que devuelve el OCR en un DocumentData
/// estructurado, buscando patrones tipo "Etiqueta: valor".
///
/// IMPORTANTE: estas expresiones regulares son un punto de partida.
/// Estan escritas para ser flexibles (aceptan mayus/minus, con o sin
/// tilde, con ":" o sin ":"), pero el OCR real de tus fichas puede
/// necesitar ajustes. Si un campo no se detecta bien, dime como
/// aparece exactamente escrito en tu ficha (ej. "N° ACTA:" vs
/// "Numero de Acta") y ajusto el patron exacto.
class ParserService {
  DocumentData parsear(String textoOcr) {
    final texto = textoOcr;

    return DocumentData(
      ruc: _buscar(texto, [
        r'RUC\s*[:\-]?\s*(\d{11})',
      ]),
      nombreRazonSocial: _buscar(texto, [
        r'(?:RAZ[OÓ]N\s*SOCIAL|NOMBRE\s*O\s*RAZ[OÓ]N\s*SOCIAL|NOMBRE)\s*[:\-]?\s*([A-ZÁÉÍÓÚÑ0-9 .,&-]{3,80})',
      ]),
      numeroActa: _buscar(texto, [
        r'(?:N[°ºo]?\s*DE\s*ACTA|N[°ºo]?\s*ACTA|ACTA\s*N[°ºo]?)\s*[:\-]?\s*([A-Z0-9\-\/]{2,30})',
      ]),
      numeroCarta: _buscar(texto, [
        r'(?:N[°ºo]?\s*DE\s*CARTA|N[°ºo]?\s*CARTA|CARTA\s*N[°ºo]?)\s*[:\-]?\s*([A-Z0-9\-\/]{2,30})',
      ]),
      recepcionadoPor: _buscar(texto, [
        r'RECEPCIONAD[OA]\s*POR\s*[:\-]?\s*([A-ZÁÉÍÓÚÑ .]{3,60})',
      ]),
      vinculo: _buscar(texto, [
        r'V[IÍ]NCULO\s*[:\-]?\s*([A-ZÁÉÍÓÚÑ .]{3,40})',
      ]),
      dni: _buscar(texto, [
        r'DNI\s*[:\-]?\s*(\d{8})',
      ]),
      fechaInicio: _buscar(texto, [
        r'FECHA\s*DE\s*INICIO\s*[:\-]?\s*(\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4})',
      ]),
      fechaHora: _buscar(texto, [
        r'FECHA\s*Y?\s*HORA\s*[:\-]?\s*(\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4}\s*[,\-]?\s*\d{1,2}:\d{2})',
      ]),
    );
  }

  /// Prueba una lista de patrones (por si hay variantes de la etiqueta)
  /// contra el texto (ignorando mayus/minus) y devuelve el primer grupo
  /// capturado que encuentre, ya sin espacios sobrantes.
  String _buscar(String texto, List<String> patrones) {
    for (final patron in patrones) {
      final regExp = RegExp(patron, caseSensitive: false);
      final match = regExp.firstMatch(texto);
      if (match != null && match.groupCount >= 1) {
        return match.group(1)!.trim();
      }
    }
    return '';
  }
}
