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
      idServicioAdicional: json['idservicioadicional'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      precioBase: (json['preciobase'] as num?)?.toDouble() ?? 0.0,
      estado: json['estado'] ?? 'ACTIVO',
      imagen: json['imagen'],
      fCreacion: json['fcreacion'] != null ? DateTime.parse(json['fcreacion']) : null,
      fModificacion: json['fmodificacion'] != null ? DateTime.parse(json['fmodificacion']) : null,
      usuarioCreacion: json['usuariocreacion'],
      usuarioModificacion: json['usuariomodificacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idservicioadicional': idServicioAdicional,
      'nombre': nombre,
      'descripcion': descripcion,
      'preciobase': precioBase,
      'estado': estado,
      'imagen': imagen,
      'fcreacion': fCreacion?.toIso8601String(),
      'fmodificacion': fModificacion?.toIso8601String(),
      'usuariocreacion': usuarioCreacion,
      'usuariomodificacion': usuarioModificacion,
    };
  }
}
