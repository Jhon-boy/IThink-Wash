class RolEntity {
  final int idRol;
  final String codigo;
  final String nombre;
  final DateTime fCreacion;
  final DateTime? fModificacion;
  final String? observacion;
  final String estado;
  final String? usuarioCreacion;
  final String? usuarioModificacion;

  RolEntity({
    required this.idRol,
    required this.codigo,
    required this.nombre,
    required this.fCreacion,
    this.fModificacion,
    this.observacion,
    required this.estado,
    this.usuarioCreacion,
    this.usuarioModificacion,
  });

  factory RolEntity.fromJson(Map<String, dynamic> json) {
    return RolEntity(
      idRol: json['idrol'],
      codigo: json['codigo'] ?? '',
      nombre: json['nombre'] ?? '',
      fCreacion: DateTime.parse(json['fcreacion']),
      fModificacion: json['fmodificacion'] != null ? DateTime.parse(json['fmodificacion']) : null,
      observacion: json['observacion'],
      estado: json['estado'] ?? '',
      usuarioCreacion: json['usuariocreacion'],
      usuarioModificacion: json['usuariomodificacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idrol': idRol,
      'codigo': codigo,
      'nombre': nombre,
      'fcreacion': fCreacion.toIso8601String(),
      'fmodificacion': fModificacion?.toIso8601String(),
      'observacion': observacion,
      'estado': estado,
      'usuariocreacion': usuarioCreacion,
      'usuariomodificacion': usuarioModificacion,
    };
  }
}
