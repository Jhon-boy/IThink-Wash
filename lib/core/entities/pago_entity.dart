class TordPagoEntity {
  final int? idPago;
  final int? idOrden;
  final String? tipoPago;
  final String? metodoPago;
  final double? monto;
  final DateTime? fechaPago;
  final String? referencia;
  final String? estado;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioCreacion;
  final String? usuarioModificacion;

  TordPagoEntity({
    this.idPago,
    this.idOrden,
    this.tipoPago,
    this.metodoPago,
    this.monto,
    this.fechaPago,
    this.referencia,
    this.estado,
    this.fCreacion,
    this.fModificacion,
    this.usuarioCreacion,
    this.usuarioModificacion,
  });

  factory TordPagoEntity.fromJson(Map<String, dynamic> json) {
    return TordPagoEntity(
      idPago: json['idpago'],
      idOrden: json['idorden'],
      tipoPago: json['tipopago'],
      metodoPago: json['metodopago'],
      monto: (json['monto'] as num?)?.toDouble(),
      fechaPago: json['fechapago'] != null ? DateTime.parse(json['fechapago']) : null,
      referencia: json['referencia'],
      estado: json['estado'],
      fCreacion: json['fcreacion'] != null ? DateTime.parse(json['fcreacion']) : null,
      fModificacion: json['fmodificacion'] != null ? DateTime.parse(json['fmodificacion']) : null,
      usuarioCreacion: json['usuariocreacion'],
      usuarioModificacion: json['usuariomodificacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idpago': idPago,
      'idorden': idOrden,
      'tipopago': tipoPago,
      'metodopago': metodoPago,
      'monto': monto,
      'fechapago': fechaPago?.toIso8601String(),
      'referencia': referencia,
      'estado': estado,
      'fcreacion': fCreacion?.toIso8601String(),
      'fmodificacion': fModificacion?.toIso8601String(),
      'usuariocreacion': usuarioCreacion,
      'usuariomodificacion': usuarioModificacion,
    };
  }
}
