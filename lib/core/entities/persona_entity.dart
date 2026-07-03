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
      idPersona: json['IDPERSONA'],
      identificacion: json['IDENTIFICACION'] ?? '',
      nombres: json['NOMBRES'] ?? '',
      apellidos: json['APELLIDOS'] ?? '',
      fechaNacimiento: json['FNACIMIENTO'] != null
          ? DateTime.parse(json['FNACIMIENTO'])
          : null,
      genero: json['GENERO'],
      correo: json['CORREO'],
      telefono: json['TELEFONO'],
      direccion: json['DIRECCION'],
      tipoIdentificacion: json['TIPOIDENTIFICACION'],
      estado: json['ESTADO'],
      fCreacion: json['FCREACION'] != null
          ? DateTime.parse(json['FCREACION'])
          : null,
      fModificacion: json['FMODIFICACION'] != null
          ? DateTime.parse(json['FMODIFICACION'])
          : null,
      usuarioCreacion: json['USUARIOCREACION'],
      usuarioModificacion: json['USUARIOMODIFICACION'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IDPERSONA': idPersona,
      'IDENTIFICACION': identificacion,
      'NOMBRES': nombres,
      'APELLIDOS': apellidos,
      'FNACIMIENTO': fechaNacimiento?.toIso8601String(),
      'GENERO': genero,
      'CORREO': correo,
      'TELEFONO': telefono,
      'DIRECCION': direccion,
      'TIPOIDENTIFICACION': tipoIdentificacion,
      'ESTADO': estado,
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOCREACION': usuarioCreacion,
      'USUARIOMODIFICACION': usuarioModificacion,
    };
  }
}
