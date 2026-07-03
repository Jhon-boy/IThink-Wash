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
      idConcepto: json['IDCONCEPTO'],
      nombre: json['NOMBRE'] ?? '',
      descripcion: json['DESCRIPCION'],
      tipoCobro: json['TIPOCOBRO'] ?? '',
      unidadMedida: json['UNIDADMEDIDA'],
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
      'IDCONCEPTO': idConcepto,
      'NOMBRE': nombre,
      'DESCRIPCION': descripcion,
      'TIPOCOBRO': tipoCobro,
      'UNIDADMEDIDA': unidadMedida,
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
