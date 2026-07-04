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
      idOrdenDetalleAdicional: json['idordendetalleadicional'],
      idOrdenDetalle: json['idordendetalle'],
      idServicioAdicional: json['idservicioadicional'],
      precioAplicado: (json['precioaplicado'] as num?)?.toDouble(),
      fCreacion: json['fcreacion'] != null ? DateTime.parse(json['fcreacion']) : null,
      fModificacion: json['fmodificacion'] != null ? DateTime.parse(json['fmodificacion']) : null,
      usuarioCreacion: json['usuariocreacion'],
      usuarioModificacion: json['usuariomodificacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idordendetalleadicional': idOrdenDetalleAdicional,
      'idordendetalle': idOrdenDetalle,
      'idservicioadicional': idServicioAdicional,
      'precioaplicado': precioAplicado,
      'fcreacion': fCreacion?.toIso8601String(),
      'fmodificacion': fModificacion?.toIso8601String(),
      'usuariocreacion': usuarioCreacion,
      'usuariomodificacion': usuarioModificacion,
    };
  }
}
