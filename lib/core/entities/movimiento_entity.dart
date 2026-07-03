class TfinMovimientoEntity {
  final int? idMovimiento;
  final int idSucursal;
  final String? tipo;
  final String? categoria;
  final String? descripcion;
  final double? monto;
  final DateTime? fecha;
  final String? referencia;
  final String? estado;
  final String? comentario;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioCreacion;
  final String? usuarioModificacion;

  TfinMovimientoEntity({
    this.idMovimiento,
    required this.idSucursal,
    this.tipo,
    this.categoria,
    this.descripcion,
    this.monto,
    this.fecha,
    this.referencia,
    this.estado,
    this.comentario,
    this.fCreacion,
    this.fModificacion,
    this.usuarioCreacion,
    this.usuarioModificacion,
  });

  factory TfinMovimientoEntity.fromJson(Map<String, dynamic> json) {
    return TfinMovimientoEntity(
      idMovimiento: json['IDMOVIMIENTO'],
      idSucursal: json['IDSUCURSAL'] ?? 0,
      tipo: json['TIPO'],
      categoria: json['CATEGORIA'],
      descripcion: json['DESCRIPCION'],
      monto: (json['MONTO'] as num?)?.toDouble(),
      fecha: json['FECHA'] != null ? DateTime.parse(json['FECHA']) : null,
      referencia: json['REFERENCIA'],
      estado: json['ESTADO'],
      comentario: json['COMENTARIO'],
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
      'IDMOVIMIENTO': idMovimiento,
      'IDSUCURSAL': idSucursal,
      'TIPO': tipo,
      'CATEGORIA': categoria,
      'DESCRIPCION': descripcion,
      'MONTO': monto,
      'FECHA': fecha?.toIso8601String(),
      'REFERENCIA': referencia,
      'ESTADO': estado,
      'COMENTARIO': comentario,
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOCREACION': usuarioCreacion,
      'USUARIOMODIFICACION': usuarioModificacion,
    };
  }
}
