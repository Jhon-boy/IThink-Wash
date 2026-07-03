class TsegUsuarioCanalEntity {
  final int? idUsuarioCanal;
  final int idUsuario;
  final int idCanal;
  final String estado;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioCreacion;
  final String? usuarioModificacion;

  TsegUsuarioCanalEntity({
    this.idUsuarioCanal,
    required this.idUsuario,
    required this.idCanal,
    this.estado = 'ACTIVO',
    this.fCreacion,
    this.fModificacion,
    this.usuarioCreacion,
    this.usuarioModificacion,
  });

  factory TsegUsuarioCanalEntity.fromJson(Map<String, dynamic> json) {
    return TsegUsuarioCanalEntity(
      idUsuarioCanal: json['IDUSUARIOCANAL'],
      idUsuario: json['IDUSUARIO'] ?? 0,
      idCanal: json['IDCANAL'] ?? 0,
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
      'IDUSUARIOCANAL': idUsuarioCanal,
      'IDUSUARIO': idUsuario,
      'IDCANAL': idCanal,
      'ESTADO': estado,
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOCREACION': usuarioCreacion,
      'USUARIOMODIFICACION': usuarioModificacion,
    };
  }
}
