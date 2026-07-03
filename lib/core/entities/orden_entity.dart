class TordOrdenEntity {
  final int? idOrden;
  final int idSucursal;
  final int idPersona;
  final int idEmpleado;
  final String? numeroOrden;
  final DateTime fechaRecepcion;
  final DateTime? fechaEntregaEstimada;
  final DateTime? fechaEntregaReal;
  final double? subtotal;
  final double? total;
  final double? totalAbonado;
  final double? saldoPendiente;
  final String estado;
  final String? comentario;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioCreacion;
  final String? usuarioModificacion;

  TordOrdenEntity({
    this.idOrden,
    required this.idSucursal,
    required this.idPersona,
    required this.idEmpleado,
    this.numeroOrden,
    required this.fechaRecepcion,
    this.fechaEntregaEstimada,
    this.fechaEntregaReal,
    this.subtotal,
    this.total,
    this.totalAbonado,
    this.saldoPendiente,
    this.estado = 'EN_PROCESO',
    this.comentario,
    this.fCreacion,
    this.fModificacion,
    this.usuarioCreacion,
    this.usuarioModificacion,
  });

  factory TordOrdenEntity.fromJson(Map<String, dynamic> json) {
    return TordOrdenEntity(
      idOrden: json['IDORDEN'],
      idSucursal: json['IDSUCURSAL'] ?? 0,
      idPersona: json['IDPERSONA'] ?? 0,
      idEmpleado: json['IDEMPLEADO'] ?? 0,
      numeroOrden: json['NUMEROORDEN'],
      fechaRecepcion: json['FECHARECEPCION'] != null
          ? DateTime.parse(json['FECHARECEPCION'])
          : DateTime.now(),
      fechaEntregaEstimada: json['FECHAENTREGAESTIMADA'] != null
          ? DateTime.parse(json['FECHAENTREGAESTIMADA'])
          : null,
      fechaEntregaReal: json['FECHAENTREGAREAL'] != null
          ? DateTime.parse(json['FECHAENTREGAREAL'])
          : null,
      subtotal: (json['SUBTOTAL'] as num?)?.toDouble(),
      total: (json['TOTAL'] as num?)?.toDouble(),
      totalAbonado: (json['TOTALABONADO'] as num?)?.toDouble(),
      saldoPendiente: (json['SALDOPENDIENTE'] as num?)?.toDouble(),
      estado: json['ESTADO'] ?? 'EN_PROCESO',
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
      'IDORDEN': idOrden,
      'IDSUCURSAL': idSucursal,
      'IDPERSONA': idPersona,
      'IDEMPLEADO': idEmpleado,
      'NUMEROORDEN': numeroOrden,
      'FECHARECEPCION': fechaRecepcion.toIso8601String(),
      'FECHAENTREGAESTIMADA': fechaEntregaEstimada?.toIso8601String(),
      'FECHAENTREGAREAL': fechaEntregaReal?.toIso8601String(),
      'SUBTOTAL': subtotal,
      'TOTAL': total,
      'TOTALABONADO': totalAbonado,
      'SALDOPENDIENTE': saldoPendiente,
      'ESTADO': estado,
      'COMENTARIO': comentario,
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOCREACION': usuarioCreacion,
      'USUARIOMODIFICACION': usuarioModificacion,
    };
  }
}
