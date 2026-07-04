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

  factory SucursalEntity.fromJson(Map<String, dynamic> json) {
    bool? estado;
    if (json['estado'] != null) {
      if (json['estado'] is bool) {
        estado = json['estado'] as bool;
      } else if (json['estado'] is String) {
        estado = json['estado'].toString().toUpperCase() == 'ACTIVO' ||
            json['estado'].toString().toUpperCase() == 'TRUE';
      }
    }
    return SucursalEntity(
      idSucursal: json['idsucursal'],
      nombre: json['nombre'] ?? '',
      direccion: json['direccion'],
      estado: estado,
      latitud: json['latitud']?.toDouble(),
      longitud: json['longitud']?.toDouble(),
      contacto: json['contacto'],
      fCreacion: json['fcreacion'] != null ? DateTime.parse(json['fcreacion']) : null,
      fModificacion: json['fmodificacion'] != null ? DateTime.parse(json['fmodificacion']) : null,
      usuarioCreacion: json['usuariocreacion'],
      usuarioModificacion: json['usuariomodificacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idsucursal': idSucursal,
      'nombre': nombre,
      'direccion': direccion,
      'estado': estado,
      'latitud': latitud,
      'longitud': longitud,
      'contacto': contacto,
      'fcreacion': fCreacion?.toIso8601String(),
      'fmodificacion': fModificacion?.toIso8601String(),
      'usuariocreacion': usuarioCreacion,
      'usuariomodificacion': usuarioModificacion,
    };
  }

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
    return Object.hash(idSucursal, nombre, direccion, estado, latitud, longitud, contacto);
  }
}
