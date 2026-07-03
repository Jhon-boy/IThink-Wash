class SucursalEntity {
  final int? idSucursal;
  final String nombre;
  final String? direccion;
  final bool? estado;
  final double? latitud;
  final double? longitud;
  final String? contacto;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioCreacion;
  final String? usuarioModificacion;

  SucursalEntity({
    this.idSucursal,
    required this.nombre,
    this.direccion,
    this.estado,
    this.latitud,
    this.longitud,
    this.contacto,
    this.fCreacion,
    this.fModificacion,
    this.usuarioCreacion,
    this.usuarioModificacion,
  });

  /// Factory constructor desde JSON de la base de datos
  factory SucursalEntity.fromJson(Map<String, dynamic> json) {
    // Manejar estado como booleano o string (para compatibilidad)
    bool? estado;
    if (json['ESTADO'] != null) {
      if (json['ESTADO'] is bool) {
        estado = json['ESTADO'] as bool;
      } else if (json['ESTADO'] is String) {
        estado = json['ESTADO'].toString().toUpperCase() == 'ACTIVO' ||
            json['ESTADO'].toString().toUpperCase() == 'TRUE';
      }
    }

    return SucursalEntity(
      idSucursal: json['IDSUCURSAL'],
      nombre: json['NOMBRE'] ?? '',
      direccion: json['DIRECCION'],
      estado: estado,
      latitud: json['LATITUD']?.toDouble(),
      longitud: json['LONGITUD']?.toDouble(),
      contacto: json['CONTACTO'],
      fCreacion:
          json['FCREACION'] != null ? DateTime.parse(json['FCREACION']) : null,
      fModificacion: json['FMODIFICACION'] != null
          ? DateTime.parse(json['FMODIFICACION'])
          : null,
      usuarioCreacion: json['USUARIOCREACION'],
      usuarioModificacion: json['USUARIOMODIFICACION'],
    );
  }

  /// Convierte la entidad a JSON para la base de datos
  Map<String, dynamic> toJson() {
    return {
      'IDSUCURSAL': idSucursal,
      'NOMBRE': nombre,
      'DIRECCION': direccion,
      'ESTADO': estado,
      'LATITUD': latitud,
      'LONGITUD': longitud,
      'CONTACTO': contacto,
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOCREACION': usuarioCreacion,
      'USUARIOMODIFICACION': usuarioModificacion,
    };
  }

  /// Convierte la entidad a JSON para la UI (nombres en camelCase)
  Map<String, dynamic> toJsonForUI() {
    return {
      'idSucursal': idSucursal,
      'nombre': nombre,
      'direccion': direccion,
      'estado': estado,
      'latitud': latitud,
      'longitud': longitud,
      'contacto': contacto,
      'fCreacion': fCreacion?.toIso8601String(),
      'fModificacion': fModificacion?.toIso8601String(),
      'usuarioCreacion': usuarioCreacion,
      'usuarioModificacion': usuarioModificacion,
    };
  }

  /// Crea una copia de la entidad con algunos campos modificados
  SucursalEntity copyWith({
    int? idSucursal,
    String? nombre,
    String? direccion,
    String? telefono,
    String? email,
    bool? estado,
    double? latitud,
    double? longitud,
    String? contacto,
    DateTime? fCreacion,
    DateTime? fModificacion,
    String? usuarioCreacion,
    String? usuarioModificacion,
  }) {
    return SucursalEntity(
      idSucursal: idSucursal ?? this.idSucursal,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      estado: estado ?? this.estado,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      contacto: contacto ?? this.contacto,
      fCreacion: fCreacion ?? this.fCreacion,
      fModificacion: fModificacion ?? this.fModificacion,
      usuarioCreacion: usuarioCreacion ?? this.usuarioCreacion,
      usuarioModificacion: usuarioModificacion ?? this.usuarioModificacion,
    );
  }

  /// Verifica si la sucursal está activa
  bool get isActiva => estado == true;

  @override
  String toString() {
    return 'SucursalEntity(idSucursal: $idSucursal, nombre: $nombre, direccion: $direccion)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SucursalEntity &&
        other.idSucursal == idSucursal &&
        other.nombre == nombre &&
        other.direccion == direccion &&
        other.estado == estado;
  }

  @override
  int get hashCode {
    return Object.hash(
      idSucursal,
      nombre,
      direccion,
      estado,
      latitud,
      longitud,
      contacto,
    );
  }
}
