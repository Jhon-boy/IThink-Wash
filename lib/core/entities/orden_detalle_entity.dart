class TordOrdenDetalleEntity {
  final int? idOrdenDetalle;
  final int idOrden;
  final int idConcepto;
  final String? descripcionPrenda;
  final double? cantidad;
  final double? precioUnitario;
  final double? subtotal;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioCreacion;
  final String? usuarioModificacion;

  TordOrdenDetalleEntity({
    this.idOrdenDetalle,
    required this.idOrden,
    required this.idConcepto,
    this.descripcionPrenda,
    this.cantidad,
    this.precioUnitario,
    this.subtotal,
    this.fCreacion,
    this.fModificacion,
    this.usuarioCreacion,
    this.usuarioModificacion,
  });

  factory TordOrdenDetalleEntity.fromJson(Map<String, dynamic> json) {
    return TordOrdenDetalleEntity(
      idOrdenDetalle: json['IDORDENDETALLE'],
      idOrden: json['IDORDEN'] ?? 0,
      idConcepto: json['IDCONCEPTO'] ?? 0,
      descripcionPrenda: json['DESCRIPCIONPRENDA'],
      cantidad: (json['CANTIDAD'] as num?)?.toDouble(),
      precioUnitario: (json['PRECIOUNITARIO'] as num?)?.toDouble(),
      subtotal: (json['SUBTOTAL'] as num?)?.toDouble(),
      fCreacion:
          json['FCREACION'] != null ? DateTime.parse(json['FCREACION']) : null,
      fModificacion: json['FMODIFICACION'] != null
          ? DateTime.parse(json['FMODIFICACION'])
          : null,
      usuarioCreacion: json['USUARIOCREACION'],
      usuarioModificacion: json['USUARIOMODIFICACION'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IDORDENDETALLE': idOrdenDetalle,
      'IDORDEN': idOrden,
      'IDCONCEPTO': idConcepto,
      'DESCRIPCIONPRENDA': descripcionPrenda,
      'CANTIDAD': cantidad,
      'PRECIOUNITARIO': precioUnitario,
      'SUBTOTAL': subtotal,
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOCREACION': usuarioCreacion,
      'USUARIOMODIFICACION': usuarioModificacion,
    };
  }
}
