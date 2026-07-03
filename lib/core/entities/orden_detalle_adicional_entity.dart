class TordOrdenDetalleAdicionalEntity {
  final int? idOrdenDetalleAdicional;
  final int? idOrdenDetalle;
  final int? idServicioAdicional;
  final double? precioAplicado;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioCreacion;
  final String? usuarioModificacion;

  TordOrdenDetalleAdicionalEntity({
    this.idOrdenDetalleAdicional,
    this.idOrdenDetalle,
    this.idServicioAdicional,
    this.precioAplicado,
    this.fCreacion,
    this.fModificacion,
    this.usuarioCreacion,
    this.usuarioModificacion,
  });

  factory TordOrdenDetalleAdicionalEntity.fromJson(Map<String, dynamic> json) {
    return TordOrdenDetalleAdicionalEntity(
      idOrdenDetalleAdicional: json['IDORDENDETALLEADICIONAL'],
      idOrdenDetalle: json['IDORDENDETALLE'],
      idServicioAdicional: json['IDSERVICIOADICIONAL'],
      precioAplicado: (json['PRECIOAPLICADO'] as num?)?.toDouble(),
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
      'IDORDENDETALLEADICIONAL': idOrdenDetalleAdicional,
      'IDORDENDETALLE': idOrdenDetalle,
      'IDSERVICIOADICIONAL': idServicioAdicional,
      'PRECIOAPLICADO': precioAplicado,
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOCREACION': usuarioCreacion,
      'USUARIOMODIFICACION': usuarioModificacion,
    };
  }
}
