/// Representa los datos extraidos de UNA foto/documento.
/// Estos son exactamente los 9 campos pedidos.
class DocumentData {
  String ruc;
  String nombreRazonSocial;
  String numeroActa;
  String numeroCarta;
  String recepcionadoPor;
  String vinculo;
  String dni;
  String fechaInicio;
  String fechaHora;

  DocumentData({
    this.ruc = '',
    this.nombreRazonSocial = '',
    this.numeroActa = '',
    this.numeroCarta = '',
    this.recepcionadoPor = '',
    this.vinculo = '',
    this.dni = '',
    this.fechaInicio = '',
    this.fechaHora = '',
  });

  /// Convierte los datos a un Map<String,String> con las mismas llaves
  /// que se usan como etiquetas {{...}} dentro de las plantillas Word.
  Map<String, String> toTemplateMap() {
    return {
      'ruc': ruc,
      'nombre': nombreRazonSocial,
      'numero_acta': numeroActa,
      'numero_carta': numeroCarta,
      'recepcionado_por': recepcionadoPor,
      'vinculo': vinculo,
      'dni': dni,
      'fecha_inicio': fechaInicio,
      'fecha_hora': fechaHora,
    };
  }

  DocumentData copyWith({
    String? ruc,
    String? nombreRazonSocial,
    String? numeroActa,
    String? numeroCarta,
    String? recepcionadoPor,
    String? vinculo,
    String? dni,
    String? fechaInicio,
    String? fechaHora,
  }) {
    return DocumentData(
      ruc: ruc ?? this.ruc,
      nombreRazonSocial: nombreRazonSocial ?? this.nombreRazonSocial,
      numeroActa: numeroActa ?? this.numeroActa,
      numeroCarta: numeroCarta ?? this.numeroCarta,
      recepcionadoPor: recepcionadoPor ?? this.recepcionadoPor,
      vinculo: vinculo ?? this.vinculo,
      dni: dni ?? this.dni,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaHora: fechaHora ?? this.fechaHora,
    );
  }
}
