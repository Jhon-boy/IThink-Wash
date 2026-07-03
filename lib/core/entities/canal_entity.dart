class TsegCanalEntity {
  final int idCanal;
  final String nombre;
  final String? descripcion;
  final String estado;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioCreacion;
  final String? usuarioModificacion;

  TsegCanalEntity({
    required this.idCanal,
    required this.nombre,
    this.descripcion,
    this.estado = 'ACTIVO',
    this.fCreacion,
    this.fModificacion,
    this.usuarioCreacion,
    this.usuarioModificacion,
  });

  factory TsegCanalEntity.fromJson(Map<String, dynamic> json) {
    return TsegCanalEntity(
      idCanal: json['IDCANAL'] as int,
      nombre: json['NOMBRE'] ?? '',
      descripcion: json['DESCRIPCION'],
      estado: json['ESTADO'] ?? 'ACTIVO',
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
      'IDCANAL': idCanal,
      'NOMBRE': nombre,
      'DESCRIPCION': descripcion,
      'ESTADO': estado,
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOCREACION': usuarioCreacion,
      'USUARIOMODIFICACION': usuarioModificacion,
    };
  }
}
