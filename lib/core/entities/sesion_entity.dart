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
      idSesion: json['idsesion'],
      idUsuario: json['idusuario'] ?? 0,
      idCanal: json['idcanal'],
      idDispositivo: json['iddispositivo'],
      token: json['token'],
      fechaInicio: json['fechainicio'] != null ? DateTime.parse(json['fechainicio']) : null,
      fechaExpiracion: json['fechaexpiracion'] != null ? DateTime.parse(json['fechaexpiracion']) : null,
      activo: json['activo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idSesion != null) 'idsesion': idSesion,
      'idusuario': idUsuario,
      'idcanal': idCanal,
      'iddispositivo': idDispositivo,
      'token': token,
      'fechainicio': fechaInicio?.toIso8601String(),
      'fechaexpiracion': fechaExpiracion?.toIso8601String(),
      'activo': activo,
    };
  }

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

  bool get isActiva => activo == true;
  bool get isExpirada {
    if (fechaExpiracion == null) return true;
    return DateTime.now().isAfter(fechaExpiracion!);
  }
  bool get esValida => isActiva && !isExpirada;
  bool get tieneToken => token != null && token!.isNotEmpty;

  Duration? get tiempoRestante {
    if (fechaExpiracion == null) return null;
    final ahora = DateTime.now();
    if (ahora.isAfter(fechaExpiracion!)) return Duration.zero;
    return fechaExpiracion!.difference(ahora);
  }

  String get tiempoRestanteFormateado {
    final tiempo = tiempoRestante;
    if (tiempo == null) return 'Sin expiración';
    if (tiempo == Duration.zero) return 'Expirada';
    if (tiempo.inHours > 0) return '${tiempo.inHours}h ${tiempo.inMinutes % 60}m';
    if (tiempo.inMinutes > 0) return '${tiempo.inMinutes}m';
    return '${tiempo.inSeconds}s';
  }

  String get fechaInicioFormateada {
    if (fechaInicio == null) return 'Sin fecha';
    return '${fechaInicio!.day.toString().padLeft(2, '0')}/${fechaInicio!.month.toString().padLeft(2, '0')}/${fechaInicio!.year}';
  }

  String get fechaExpiracionFormateada {
    if (fechaExpiracion == null) return 'Sin expiración';
    return '${fechaExpiracion!.day.toString().padLeft(2, '0')}/${fechaExpiracion!.month.toString().padLeft(2, '0')}/${fechaExpiracion!.year}';
  }

  String get estadoSesion {
    if (!isActiva) return 'INACTIVA';
    if (isExpirada) return 'EXPIRADA';
    return 'ACTIVA';
  }

  String get colorEstado {
    switch (estadoSesion) {
      case 'ACTIVA': return 'verde';
      case 'EXPIRADA': return 'rojo';
      case 'INACTIVA': return 'gris';
      default: return 'gris';
    }
  }

  String get iconoEstado {
    switch (estadoSesion) {
      case 'ACTIVA': return 'check_circle';
      case 'EXPIRADA': return 'schedule';
      case 'INACTIVA': return 'pause_circle';
      default: return 'help';
    }
  }

  String get tokenTruncado {
    if (token == null || token!.isEmpty) return 'Sin token';
    if (token!.length <= 8) return token!;
    return '${token!.substring(0, 8)}...';
  }

  bool get proximaAExpirar {
    final tiempo = tiempoRestante;
    if (tiempo == null) return false;
    return tiempo.inMinutes < 30 && tiempo.inMinutes > 0;
  }

  Duration? get tiempoDesdeInicio {
    if (fechaInicio == null) return null;
    return DateTime.now().difference(fechaInicio!);
  }

  String get tiempoDesdeInicioFormateado {
    final tiempo = tiempoDesdeInicio;
    if (tiempo == null) return 'Sin fecha';
    if (tiempo.inDays > 0) return '${tiempo.inDays} días';
    if (tiempo.inHours > 0) return '${tiempo.inHours} horas';
    if (tiempo.inMinutes > 0) return '${tiempo.inMinutes} minutos';
    return 'Recién creada';
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
    return Object.hash(idSesion, idUsuario, token);
  }
}
