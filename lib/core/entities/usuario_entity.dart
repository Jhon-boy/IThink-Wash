class TsegUsuarioEntity {
  final int idUsuario;
  final int idSucursal;
  final int idPersona;
  final String? usuario;
  final String? password;
  final bool? temporal;
  final String estado;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioCreacion;
  final String? usuarioModificacion;

  TsegUsuarioEntity({
    required this.idUsuario,
    required this.idSucursal,
    required this.idPersona,
    this.usuario,
    this.password,
    this.temporal,
    this.estado = 'ACTIVO',
    this.fCreacion,
    this.fModificacion,
    this.usuarioCreacion,
    this.usuarioModificacion,
  });

  factory TsegUsuarioEntity.fromJson(Map<String, dynamic> json) {
    return TsegUsuarioEntity(
      idUsuario: json['IDUSUARIO'] as int,
      idSucursal: json['IDSUCURSAL'] as int,
      idPersona: json['IDPERSONA'] as int,
      usuario: json['USUARIO'],
      password: json['PASSWORD'],
      temporal: json['TEMPORAL'],
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
      'IDUSUARIO': idUsuario,
      'IDSUCURSAL': idSucursal,
      'IDPERSONA': idPersona,
      'USUARIO': usuario,
      'PASSWORD': password,
      'TEMPORAL': temporal,
      'ESTADO': estado,
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOCREACION': usuarioCreacion,
      'USUARIOMODIFICACION': usuarioModificacion,
    };
  }
}
