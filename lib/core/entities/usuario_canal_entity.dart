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
      idUsuarioCanal: json['idusuariocanal'],
      idUsuario: json['idusuario'] ?? 0,
      idCanal: json['idcanal'] ?? 0,
      estado: json['estado'] ?? 'ACTIVO',
      fCreacion: json['fcreacion'] != null ? DateTime.parse(json['fcreacion']) : null,
      fModificacion: json['fmodificacion'] != null ? DateTime.parse(json['fmodificacion']) : null,
      usuarioCreacion: json['usuariocreacion'],
      usuarioModificacion: json['usuariomodificacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idusuariocanal': idUsuarioCanal,
      'idusuario': idUsuario,
      'idcanal': idCanal,
      'estado': estado,
      'fcreacion': fCreacion?.toIso8601String(),
      'fmodificacion': fModificacion?.toIso8601String(),
      'usuariocreacion': usuarioCreacion,
      'usuariomodificacion': usuarioModificacion,
    };
  }
}
