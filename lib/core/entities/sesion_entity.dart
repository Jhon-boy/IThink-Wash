class SesionEntity {
  final String? idSesion;
  final int idUsuario;
  final int? idCanal;
  final int? idDispositivo;
  final String? token;
  final DateTime? fechaInicio;
  final DateTime? fechaExpiracion;
  final bool? activo;

  SesionEntity({
    this.idSesion,
    required this.idUsuario,
    this.idCanal,
    this.idDispositivo,
    this.token,
    this.fechaInicio,
    this.fechaExpiracion,
    this.activo,
  });

  factory SesionEntity.fromJson(Map<String, dynamic> json) {
    return SesionEntity(
      idSesion: json['IDSESION'],
      idUsuario: json['IDUSUARIO'] ?? json['idusuario'] ?? 0,
      idCanal: json['IDCANAL'] ?? json['idcanal'],
      idDispositivo: json['IDDISPOSITIVO'] ?? json['iddispositivo'],
      token: json['TOKEN'] ?? json['token'],
      fechaInicio: json['FECHAINICIO'] != null
          ? DateTime.parse(json['FECHAINICIO'])
          : json['fechainicio'] != null
              ? DateTime.parse(json['fechainicio'])
              : null,
      fechaExpiracion: json['FECHAEXPIRACION'] != null
          ? DateTime.parse(json['FECHAEXPIRACION'])
          : json['fechaexpiracion'] != null
              ? DateTime.parse(json['fechaexpiracion'])
              : null,
      activo: json['ACTIVO'] ?? json['activo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idSesion != null) 'IDSESION': idSesion,
      'IDUSUARIO': idUsuario,
      'IDCANAL': idCanal,
      'IDDISPOSITIVO': idDispositivo,
      'TOKEN': token,
      'FECHAINICIO': fechaInicio?.toIso8601String(),
      'FECHAEXPIRACION': fechaExpiracion?.toIso8601String(),
      'ACTIVO': activo,
    };
  }

  /// Convierte la entidad a JSON para la UI (nombres en camelCase)
  Map<String, dynamic> toJsonForUI() {
    return {
      'idSesion': idSesion,
      'idUsuario': idUsuario,
      'idCanal': idCanal,
      'idDispositivo': idDispositivo,
      'token': token,
      'fechaInicio': fechaInicio?.toIso8601String(),
      'fechaExpiracion': fechaExpiracion?.toIso8601String(),
      'activo': activo,
    };
  }

  /// Crea una copia de la entidad con algunos campos modificados
  SesionEntity copyWith({
    String? idSesion,
    int? idUsuario,
    int? idCanal,
    int? idDispositivo,
    String? token,
    DateTime? fechaInicio,
    DateTime? fechaExpiracion,
    bool? activo,
  }) {
    return SesionEntity(
      idSesion: idSesion ?? this.idSesion,
      idUsuario: idUsuario ?? this.idUsuario,
      idCanal: idCanal ?? this.idCanal,
      idDispositivo: idDispositivo ?? this.idDispositivo,
      token: token ?? this.token,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaExpiracion: fechaExpiracion ?? this.fechaExpiracion,
      activo: activo ?? this.activo,
    );
  }

  /// Verifica si la sesión está activa
  bool get isActiva => activo == true;

  /// Verifica si la sesión está expirada
  bool get isExpirada {
    if (fechaExpiracion == null) return true;
    return DateTime.now().isAfter(fechaExpiracion!);
  }

  /// Verifica si la sesión es válida (activa y no expirada)
  bool get esValida => isActiva && !isExpirada;

  /// Verifica si tiene token
  bool get tieneToken => token != null && token!.isNotEmpty;

  /// Obtiene el tiempo restante hasta la expiración
  Duration? get tiempoRestante {
    if (fechaExpiracion == null) return null;
    final ahora = DateTime.now();
    if (ahora.isAfter(fechaExpiracion!)) return Duration.zero;
    return fechaExpiracion!.difference(ahora);
  }

  /// Obtiene el tiempo restante formateado
  String get tiempoRestanteFormateado {
    final tiempo = tiempoRestante;
    if (tiempo == null) return 'Sin expiración';
    if (tiempo == Duration.zero) return 'Expirada';

    if (tiempo.inHours > 0) {
      return '${tiempo.inHours}h ${tiempo.inMinutes % 60}m';
    } else if (tiempo.inMinutes > 0) {
      return '${tiempo.inMinutes}m';
    } else {
      return '${tiempo.inSeconds}s';
    }
  }

  /// Obtiene la fecha de inicio formateada
  String get fechaInicioFormateada {
    if (fechaInicio == null) return 'Sin fecha';
    return '${fechaInicio!.day.toString().padLeft(2, '0')}/${fechaInicio!.month.toString().padLeft(2, '0')}/${fechaInicio!.year}';
  }

  /// Obtiene la fecha de expiración formateada
  String get fechaExpiracionFormateada {
    if (fechaExpiracion == null) return 'Sin expiración';
    return '${fechaExpiracion!.day.toString().padLeft(2, '0')}/${fechaExpiracion!.month.toString().padLeft(2, '0')}/${fechaExpiracion!.year}';
  }

  /// Obtiene el estado de la sesión
  String get estadoSesion {
    if (!isActiva) return 'INACTIVA';
    if (isExpirada) return 'EXPIRADA';
    return 'ACTIVA';
  }

  /// Obtiene el color del estado para la UI
  String get colorEstado {
    switch (estadoSesion) {
      case 'ACTIVA':
        return 'verde';
      case 'EXPIRADA':
        return 'rojo';
      case 'INACTIVA':
        return 'gris';
      default:
        return 'gris';
    }
  }

  /// Obtiene el icono del estado para la UI
  String get iconoEstado {
    switch (estadoSesion) {
      case 'ACTIVA':
        return 'check_circle';
      case 'EXPIRADA':
        return 'schedule';
      case 'INACTIVA':
        return 'pause_circle';
      default:
        return 'help';
    }
  }

  /// Obtiene el token truncado para mostrar
  String get tokenTruncado {
    if (token == null || token!.isEmpty) return 'Sin token';
    if (token!.length <= 8) return token!;
    return '${token!.substring(0, 8)}...';
  }

  /// Verifica si la sesión está próxima a expirar (menos de 30 minutos)
  bool get proximaAExpirar {
    final tiempo = tiempoRestante;
    if (tiempo == null) return false;
    return tiempo.inMinutes < 30 && tiempo.inMinutes > 0;
  }

  /// Obtiene el tiempo desde el inicio
  Duration? get tiempoDesdeInicio {
    if (fechaInicio == null) return null;
    return DateTime.now().difference(fechaInicio!);
  }

  /// Obtiene el tiempo desde el inicio formateado
  String get tiempoDesdeInicioFormateado {
    final tiempo = tiempoDesdeInicio;
    if (tiempo == null) return 'Sin fecha';

    if (tiempo.inDays > 0) {
      return '${tiempo.inDays} días';
    } else if (tiempo.inHours > 0) {
      return '${tiempo.inHours} horas';
    } else if (tiempo.inMinutes > 0) {
      return '${tiempo.inMinutes} minutos';
    } else {
      return 'Recién creada';
    }
  }

  @override
  String toString() {
    return 'SesionEntity(idSesion: $idSesion, idUsuario: $idUsuario, estado: $estadoSesion)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SesionEntity &&
        other.idSesion == idSesion &&
        other.idUsuario == idUsuario &&
        other.token == token;
  }

  @override
  int get hashCode {
    return Object.hash(
      idSesion,
      idUsuario,
      token,
    );
  }
}
