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
      idOrdenDetalle: json['idordendetalle'],
      idOrden: json['idorden'] ?? 0,
      idConcepto: json['idconcepto'] ?? 0,
      descripcionPrenda: json['descripcionprenda'],
      cantidad: (json['cantidad'] as num?)?.toDouble(),
      precioUnitario: (json['preciounitario'] as num?)?.toDouble(),
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      fCreacion: json['fcreacion'] != null ? DateTime.parse(json['fcreacion']) : null,
      fModificacion: json['fmodificacion'] != null ? DateTime.parse(json['fmodificacion']) : null,
      usuarioCreacion: json['usuariocreacion'],
      usuarioModificacion: json['usuariomodificacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idordendetalle': idOrdenDetalle,
      'idorden': idOrden,
      'idconcepto': idConcepto,
      'descripcionprenda': descripcionPrenda,
      'cantidad': cantidad,
      'preciounitario': precioUnitario,
      'subtotal': subtotal,
      'fcreacion': fCreacion?.toIso8601String(),
      'fmodificacion': fModificacion?.toIso8601String(),
      'usuariocreacion': usuarioCreacion,
      'usuariomodificacion': usuarioModificacion,
    };
  }
}
