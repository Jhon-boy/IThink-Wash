class RolUsuarioEntity {
  final int? idRolUsuario;
  final int idUsuario;
  final int? idRol;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioCreacion;
  final String? usuarioModificacion;
  final String? estado;

  RolUsuarioEntity({
    this.idRolUsuario,
    required this.idUsuario,
    this.idRol,
    this.fCreacion,
    this.fModificacion,
    this.usuarioCreacion,
    this.usuarioModificacion,
    this.estado,
  });

  factory RolUsuarioEntity.fromJson(Map<String, dynamic> json) {
    return RolUsuarioEntity(
      idRolUsuario: json['idrolusuario'],
      idUsuario: json['idusuario'] ?? 0,
      idRol: json['idrol'],
      fCreacion: json['fcreacion'] != null ? DateTime.parse(json['fcreacion']) : null,
      fModificacion: json['fmodificacion'] != null ? DateTime.parse(json['fmodificacion']) : null,
      usuarioCreacion: json['usuariocreacion'],
      usuarioModificacion: json['usuariomodificacion'],
      estado: json['estado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idrolusuario': idRolUsuario,
      'idusuario': idUsuario,
      'idrol': idRol,
      'fcreacion': fCreacion?.toIso8601String(),
      'fmodificacion': fModificacion?.toIso8601String(),
      'usuariocreacion': usuarioCreacion,
      'usuariomodificacion': usuarioModificacion,
      'estado': estado,
    };
  }

  Map<String, dynamic> toJsonForUI() {
    return {
      'idRolUsuario': idRolUsuario,
      'idUsuario': idUsuario,
      'idRol': idRol,
      'fCreacion': fCreacion?.toIso8601String(),
      'fModificacion': fModificacion?.toIso8601String(),
      'usuarioCreacion': usuarioCreacion,
      'usuarioModificacion': usuarioModificacion,
      'estado': estado,
    };
  }

  RolUsuarioEntity copyWith({
    int? idRolUsuario,
    int? idUsuario,
    int? idRol,
    DateTime? fCreacion,
    DateTime? fModificacion,
    String? usuarioCreacion,
    String? usuarioModificacion,
    String? estado,
  }) {
    return RolUsuarioEntity(
      idRolUsuario: idRolUsuario ?? this.idRolUsuario,
      idUsuario: idUsuario ?? this.idUsuario,
      idRol: idRol ?? this.idRol,
      fCreacion: fCreacion ?? this.fCreacion,
      fModificacion: fModificacion ?? this.fModificacion,
      usuarioCreacion: usuarioCreacion ?? this.usuarioCreacion,
      usuarioModificacion: usuarioModificacion ?? this.usuarioModificacion,
      estado: estado ?? this.estado,
    );
  }

  bool get isActivo => estado?.toUpperCase() == 'ACTIVO' || estado == null;
  bool get isInactivo => estado?.toUpperCase() == 'INACTIVO';
  bool get isSuspendido => estado?.toUpperCase() == 'SUSPENDIDO';
  bool get tieneRol => idRol != null;

  String get estadoFormateado {
    if (estado == null) return 'ACTIVO';
    return estado!.toUpperCase();
  }

  String get colorEstado {
    switch (estado?.toUpperCase()) {
      case 'ACTIVO': return 'verde';
      case 'INACTIVO': return 'gris';
      case 'SUSPENDIDO': return 'rojo';
      default: return 'verde';
    }
  }

  String get iconoEstado {
    switch (estado?.toUpperCase()) {
      case 'ACTIVO': return 'check_circle';
      case 'INACTIVO': return 'pause_circle';
      case 'SUSPENDIDO': return 'block';
      default: return 'check_circle';
    }
  }

  String get fechaCreacionFormateada {
    if (fCreacion == null) return 'Sin fecha';
    return '${fCreacion!.day.toString().padLeft(2, '0')}/${fCreacion!.month.toString().padLeft(2, '0')}/${fCreacion!.year}';
  }

  String get fechaModificacionFormateada {
    if (fModificacion == null) return 'Sin modificar';
    return '${fModificacion!.day.toString().padLeft(2, '0')}/${fModificacion!.month.toString().padLeft(2, '0')}/${fModificacion!.year}';
  }

  bool get fueModificado => fModificacion != null;

  Duration? get tiempoDesdeCreacion {
    if (fCreacion == null) return null;
    return DateTime.now().difference(fCreacion!);
  }

  String get tiempoDesdeCreacionFormateado {
    final tiempo = tiempoDesdeCreacion;
    if (tiempo == null) return 'Sin fecha';
    if (tiempo.inDays > 0) return '${tiempo.inDays} días';
    if (tiempo.inHours > 0) return '${tiempo.inHours} horas';
    if (tiempo.inMinutes > 0) return '${tiempo.inMinutes} minutos';
    return 'Recién creado';
  }

  @override
  String toString() {
    return 'RolUsuarioEntity(idRolUsuario: $idRolUsuario, idUsuario: $idUsuario, idRol: $idRol)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RolUsuarioEntity &&
        other.idRolUsuario == idRolUsuario &&
        other.idUsuario == idUsuario &&
        other.idRol == idRol;
  }

  @override
  int get hashCode {
    return Object.hash(idRolUsuario, idUsuario, idRol);
  }
}
