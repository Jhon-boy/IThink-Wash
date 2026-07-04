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
      idCanal: json['idcanal'] as int,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      estado: json['estado'] ?? 'ACTIVO',
      fCreacion: json['fcreacion'] != null ? DateTime.parse(json['fcreacion']) : null,
      fModificacion: json['fmodificacion'] != null ? DateTime.parse(json['fmodificacion']) : null,
      usuarioCreacion: json['usuariocreacion'],
      usuarioModificacion: json['usuariomodificacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idcanal': idCanal,
      'nombre': nombre,
      'descripcion': descripcion,
      'estado': estado,
      'fcreacion': fCreacion?.toIso8601String(),
      'fmodificacion': fModificacion?.toIso8601String(),
      'usuariocreacion': usuarioCreacion,
      'usuariomodificacion': usuarioModificacion,
    };
  }
}
