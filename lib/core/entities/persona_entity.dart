class PersonaEntity {
  final int? idPersona;
  final String identificacion;
  final String nombres;
  final String apellidos;
  final DateTime? fechaNacimiento;
  final String? genero;
  final String? correo;
  final String? telefono;
  final String? direccion;
  final String? tipoIdentificacion;
  final String? estado;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioCreacion;
  final String? usuarioModificacion;

  PersonaEntity({
    this.idPersona,
    required this.identificacion,
    required this.nombres,
    required this.apellidos,
    this.fechaNacimiento,
    this.genero,
    this.correo,
    this.telefono,
    this.direccion,
    this.tipoIdentificacion,
    this.estado,
    this.fCreacion,
    this.fModificacion,
    this.usuarioCreacion,
    this.usuarioModificacion,
  });

  factory PersonaEntity.fromJson(Map<String, dynamic> json) {
    return PersonaEntity(
      idPersona: json['idpersona'],
      identificacion: json['identificacion'] ?? '',
      nombres: json['nombres'] ?? '',
      apellidos: json['apellidos'] ?? '',
      fechaNacimiento: json['fnacimiento'] != null ? DateTime.parse(json['fnacimiento']) : null,
      genero: json['genero'],
      correo: json['correo'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      tipoIdentificacion: json['tipoidentificacion'],
      estado: json['estado'],
      fCreacion: json['fcreacion'] != null ? DateTime.parse(json['fcreacion']) : null,
      fModificacion: json['fmodificacion'] != null ? DateTime.parse(json['fmodificacion']) : null,
      usuarioCreacion: json['usuariocreacion'],
      usuarioModificacion: json['usuariomodificacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idpersona': idPersona,
      'identificacion': identificacion,
      'nombres': nombres,
      'apellidos': apellidos,
      'fnacimiento': fechaNacimiento?.toIso8601String(),
      'genero': genero,
      'correo': correo,
      'telefono': telefono,
      'direccion': direccion,
      'tipoidentificacion': tipoIdentificacion,
      'estado': estado,
      'fcreacion': fCreacion?.toIso8601String(),
      'fmodificacion': fModificacion?.toIso8601String(),
      'usuariocreacion': usuarioCreacion,
      'usuariomodificacion': usuarioModificacion,
    };
  }
}
