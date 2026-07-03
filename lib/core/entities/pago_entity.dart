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
      idPago: json['IDPAGO'],
      idOrden: json['IDORDEN'],
      tipoPago: json['TIPOPAGO'],
      metodoPago: json['METODOPAGO'],
      monto: (json['MONTO'] as num?)?.toDouble(),
      fechaPago: json['FECHAPAGO'] != null
          ? DateTime.parse(json['FECHAPAGO'])
          : null,
      referencia: json['REFERENCIA'],
      estado: json['ESTADO'],
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
      'IDPAGO': idPago,
      'IDORDEN': idOrden,
      'TIPOPAGO': tipoPago,
      'METODOPAGO': metodoPago,
      'MONTO': monto,
      'FECHAPAGO': fechaPago?.toIso8601String(),
      'REFERENCIA': referencia,
      'ESTADO': estado,
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOCREACION': usuarioCreacion,
      'USUARIOMODIFICACION': usuarioModificacion,
    };
  }
}
