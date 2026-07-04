class TserConceptoEntity {
  final int? idConcepto;
  final String nombre;
  final String? descripcion;
  final String tipoCobro;
  final String? unidadMedida;
  final double precioBase;
  final String estado;
  final String? imagen;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioCreacion;
  final String? usuarioModificacion;

  TserConceptoEntity({
    this.idConcepto,
    required this.nombre,
    this.descripcion,
    required this.tipoCobro,
    this.unidadMedida,
    required this.precioBase,
    this.estado = 'ACTIVO',
    this.imagen,
    this.fCreacion,
    this.fModificacion,
    this.usuarioCreacion,
    this.usuarioModificacion,
  });

  factory TserConceptoEntity.fromJson(Map<String, dynamic> json) {
    return TserConceptoEntity(
      idConcepto: json['idconcepto'],
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      tipoCobro: json['tipocobro'] ?? '',
      unidadMedida: json['unidadmedida'],
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
      'idconcepto': idConcepto,
      'nombre': nombre,
      'descripcion': descripcion,
      'tipocobro': tipoCobro,
      'unidadmedida': unidadMedida,
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
