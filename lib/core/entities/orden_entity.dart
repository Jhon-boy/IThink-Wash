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
      idOrden: json['idorden'],
      idSucursal: json['idsucursal'] ?? 0,
      idPersona: json['idpersona'] ?? 0,
      idEmpleado: json['idempleado'] ?? 0,
      numeroOrden: json['numeroorden'],
      fechaRecepcion: json['fecharecepcion'] != null ? DateTime.parse(json['fecharecepcion']) : DateTime.now(),
      fechaEntregaEstimada: json['fechaentregaestimada'] != null ? DateTime.parse(json['fechaentregaestimada']) : null,
      fechaEntregaReal: json['fechaentregareal'] != null ? DateTime.parse(json['fechaentregareal']) : null,
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      total: (json['total'] as num?)?.toDouble(),
      totalAbonado: (json['totalabonado'] as num?)?.toDouble(),
      saldoPendiente: (json['saldopendiente'] as num?)?.toDouble(),
      estado: json['estado'] ?? 'EN_PROCESO',
      comentario: json['comentario'],
      fCreacion: json['fcreacion'] != null ? DateTime.parse(json['fcreacion']) : null,
      fModificacion: json['fmodificacion'] != null ? DateTime.parse(json['fmodificacion']) : null,
      usuarioCreacion: json['usuariocreacion'],
      usuarioModificacion: json['usuariomodificacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idorden': idOrden,
      'idsucursal': idSucursal,
      'idpersona': idPersona,
      'idempleado': idEmpleado,
      'numeroorden': numeroOrden,
      'fecharecepcion': fechaRecepcion.toIso8601String(),
      'fechaentregaestimada': fechaEntregaEstimada?.toIso8601String(),
      'fechaentregareal': fechaEntregaReal?.toIso8601String(),
      'subtotal': subtotal,
      'total': total,
      'totalabonado': totalAbonado,
      'saldopendiente': saldoPendiente,
      'estado': estado,
      'comentario': comentario,
      'fcreacion': fCreacion?.toIso8601String(),
      'fmodificacion': fModificacion?.toIso8601String(),
      'usuariocreacion': usuarioCreacion,
      'usuariomodificacion': usuarioModificacion,
    };
  }
}
