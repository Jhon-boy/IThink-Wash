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
      idMovimiento: json['idmovimiento'],
      idSucursal: json['idsucursal'] ?? 0,
      tipo: json['tipo'],
      categoria: json['categoria'],
      descripcion: json['descripcion'],
      monto: (json['monto'] as num?)?.toDouble(),
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : null,
      referencia: json['referencia'],
      estado: json['estado'],
      comentario: json['comentario'],
      fCreacion: json['fcreacion'] != null ? DateTime.parse(json['fcreacion']) : null,
      fModificacion: json['fmodificacion'] != null ? DateTime.parse(json['fmodificacion']) : null,
      usuarioCreacion: json['usuariocreacion'],
      usuarioModificacion: json['usuariomodificacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idmovimiento': idMovimiento,
      'idsucursal': idSucursal,
      'tipo': tipo,
      'categoria': categoria,
      'descripcion': descripcion,
      'monto': monto,
      'fecha': fecha?.toIso8601String(),
      'referencia': referencia,
      'estado': estado,
      'comentario': comentario,
      'fcreacion': fCreacion?.toIso8601String(),
      'fmodificacion': fModificacion?.toIso8601String(),
      'usuariocreacion': usuarioCreacion,
      'usuariomodificacion': usuarioModificacion,
    };
  }
}
