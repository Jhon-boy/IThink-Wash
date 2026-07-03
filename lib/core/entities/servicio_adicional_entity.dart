class TserServicioAdicionalEntity {
  final int? idServicioAdicional;
  final String nombre;
  final String? descripcion;
  final double precioBase;
  final String estado;
  final String? imagen;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioCreacion;
  final String? usuarioModificacion;

  TserServicioAdicionalEntity({
    this.idServicioAdicional,
    required this.nombre,
    this.descripcion,
    required this.precioBase,
    this.estado = 'ACTIVO',
    this.imagen,
    this.fCreacion,
    this.fModificacion,
    this.usuarioCreacion,
    this.usuarioModificacion,
  });

  factory TserServicioAdicionalEntity.fromJson(Map<String, dynamic> json) {
    return TserServicioAdicionalEntity(
      idServicioAdicional: json['IDSERVICIOADICIONAL'],
      nombre: json['NOMBRE'] ?? '',
      descripcion: json['DESCRIPCION'],
      precioBase: (json['PRECIOBASE'] as num?)?.toDouble() ?? 0.0,
      estado: json['ESTADO'] ?? 'ACTIVO',
      imagen: json['IMAGEN'],
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
      'IDSERVICIOADICIONAL': idServicioAdicional,
      'NOMBRE': nombre,
      'DESCRIPCION': descripcion,
      'PRECIOBASE': precioBase,
      'ESTADO': estado,
      'IMAGEN': imagen,
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOCREACION': usuarioCreacion,
      'USUARIOMODIFICACION': usuarioModificacion,
    };
  }
}
