import 'document_data.dart';

/// Un registro guardado en el historial: los datos de un documento,
/// mas el modo con el que se genero y la fecha/hora en que se guardo.
class HistorialItem {
  final DocumentData datos;
  final String modo; // "Inspección Laboral" o "Control de Ingresos"
  final DateTime fechaRegistro;

  HistorialItem({
    required this.datos,
    required this.modo,
    required this.fechaRegistro,
  });

  Map<String, dynamic> toJson() {
    return {
      'modo': modo,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      ...datos.toTemplateMap(),
    };
  }

  factory HistorialItem.fromJson(Map<String, dynamic> json) {
    return HistorialItem(
      modo: json['modo'] ?? '',
      fechaRegistro: DateTime.tryParse(json['fechaRegistro'] ?? '') ?? DateTime.now(),
      datos: DocumentData(
        ruc: json['ruc'] ?? '',
        nombreRazonSocial: json['nombre'] ?? '',
        numeroActa: json['numero_acta'] ?? '',
        numeroCarta: json['numero_carta'] ?? '',
        recepcionadoPor: json['recepcionado_por'] ?? '',
        vinculo: json['vinculo'] ?? '',
        dni: json['dni'] ?? '',
        fechaInicio: json['fecha_inicio'] ?? '',
        fechaHora: json['fecha_hora'] ?? '',
      ),
    );
  }
}
