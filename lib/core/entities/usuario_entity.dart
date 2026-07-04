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
      idUsuario: json['idusuario'] as int,
      idSucursal: json['idsucursal'] as int,
      idPersona: json['idpersona'] as int,
      usuario: json['usuario'],
      password: json['password'],
      temporal: json['temporal'],
      estado: json['estado'] ?? 'ACTIVO',
      fCreacion: json['fcreacion'] != null ? DateTime.parse(json['fcreacion']) : null,
      fModificacion: json['fmodificacion'] != null ? DateTime.parse(json['fmodificacion']) : null,
      usuarioCreacion: json['usuariocreacion'],
      usuarioModificacion: json['usuariomodificacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idusuario': idUsuario,
      'idsucursal': idSucursal,
      'idpersona': idPersona,
      'usuario': usuario,
      'password': password,
      'temporal': temporal,
      'estado': estado,
      'fcreacion': fCreacion?.toIso8601String(),
      'fmodificacion': fModificacion?.toIso8601String(),
      'usuariocreacion': usuarioCreacion,
      'usuariomodificacion': usuarioModificacion,
    };
  }
}
