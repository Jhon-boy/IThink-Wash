class DispositivoEntity {
  final int? idDispositivo;
  final int idUsuario;
  final String? imei;
  final String? marca;
  final String? modelo;
  final String? sistemaOperativo;
  final String? versionSo;
  final String? nombreDispositivo;
  final DateTime? ultimoAcceso;
  final bool? activo;
  final DateTime? fCreacion;
  final DateTime? fModificacion;
  final String? usuarioCreacion;
  final String? usuarioModificacion;

  DispositivoEntity({
    this.idDispositivo,
    required this.idUsuario,
    this.imei,
    this.marca,
    this.modelo,
    this.sistemaOperativo,
    this.versionSo,
    this.nombreDispositivo,
    this.ultimoAcceso,
    this.activo,
    this.fCreacion,
    this.fModificacion,
    this.usuarioCreacion,
    this.usuarioModificacion,
  });

  factory DispositivoEntity.fromJson(Map<String, dynamic> json) {
    return DispositivoEntity(
      idDispositivo: json['IDDISPOSITIVO'],
      idUsuario: json['IDUSUARIO'] ?? 0,
      imei: json['IMEI'],
      marca: json['MARCA'],
      modelo: json['MODELO'],
      sistemaOperativo: json['SISTEMAOPERATIVO'],
      versionSo: json['VERSIONSO'],
      nombreDispositivo: json['NOMBREDISPOSITIVO'],
      ultimoAcceso: json['ULTIMOACCESO'] != null
          ? DateTime.parse(json['ULTIMOACCESO'])
          : null,
      activo: json['ACTIVO'] ?? true,
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
      'IDDISPOSITIVO': idDispositivo,
      'IDUSUARIO': idUsuario,
      'IMEI': imei,
      'MARCA': marca,
      'MODELO': modelo,
      'SISTEMAOPERATIVO': sistemaOperativo,
      'VERSIONSO': versionSo,
      'NOMBREDISPOSITIVO': nombreDispositivo,
      'ULTIMOACCESO': ultimoAcceso?.toIso8601String(),
      'ACTIVO': activo,
      'FCREACION': fCreacion?.toIso8601String(),
      'FMODIFICACION': fModificacion?.toIso8601String(),
      'USUARIOCREACION': usuarioCreacion,
      'USUARIOMODIFICACION': usuarioModificacion,
    };
  }

  Map<String, dynamic> toJsonForUI() {
    return {
      'idDispositivo': idDispositivo,
      'idUsuario': idUsuario,
      'imei': imei,
      'marca': marca,
      'modelo': modelo,
      'sistemaOperativo': sistemaOperativo,
      'versionSo': versionSo,
      'nombreDispositivo': nombreDispositivo,
      'ultimoAcceso': ultimoAcceso?.toIso8601String(),
      'activo': activo,
      'fCreacion': fCreacion?.toIso8601String(),
      'fModificacion': fModificacion?.toIso8601String(),
      'usuarioCreacion': usuarioCreacion,
      'usuarioModificacion': usuarioModificacion,
    };
  }

  DispositivoEntity copyWith({
    int? idDispositivo,
    int? idUsuario,
    String? imei,
    String? marca,
    String? modelo,
    String? sistemaOperativo,
    String? versionSo,
    String? nombreDispositivo,
    DateTime? ultimoAcceso,
    bool? activo,
    DateTime? fCreacion,
    DateTime? fModificacion,
    String? usuarioCreacion,
    String? usuarioModificacion,
  }) {
    return DispositivoEntity(
      idDispositivo: idDispositivo ?? this.idDispositivo,
      idUsuario: idUsuario ?? this.idUsuario,
      imei: imei ?? this.imei,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      sistemaOperativo: sistemaOperativo ?? this.sistemaOperativo,
      versionSo: versionSo ?? this.versionSo,
      nombreDispositivo: nombreDispositivo ?? this.nombreDispositivo,
      ultimoAcceso: ultimoAcceso ?? this.ultimoAcceso,
      activo: activo ?? this.activo,
      fCreacion: fCreacion ?? this.fCreacion,
      fModificacion: fModificacion ?? this.fModificacion,
      usuarioCreacion: usuarioCreacion ?? this.usuarioCreacion,
      usuarioModificacion: usuarioModificacion ?? this.usuarioModificacion,
    );
  }

  /// Verifica si tiene IMEI
  bool get tieneImei => imei != null && imei!.isNotEmpty;

  /// Verifica si tiene información completa del dispositivo
  bool get tieneInfoCompleta =>
      marca != null && modelo != null && sistemaOperativo != null;

  String get nombreFormateado {
    if (nombreDispositivo != null && nombreDispositivo!.isNotEmpty) {
      return nombreDispositivo!;
    }
    if (marca != null && modelo != null) {
      return '$marca $modelo';
    } else if (marca != null) {
      return marca!;
    } else if (modelo != null) {
      return modelo!;
    }
    return 'Dispositivo desconocido';
  }

  /// Obtiene la fecha del último acceso formateada
  String get ultimoAccesoFormateado {
    if (ultimoAcceso == null) return 'Nunca';
    return '${ultimoAcceso!.day.toString().padLeft(2, '0')}/${ultimoAcceso!.month.toString().padLeft(2, '0')}/${ultimoAcceso!.year}';
  }

  bool get isActivo => activo == true;

  /// Obtiene el tiempo desde el último acceso
  Duration? get tiempoDesdeUltimoAcceso {
    if (ultimoAcceso == null) return null;
    return DateTime.now().difference(ultimoAcceso!);
  }

  /// Obtiene el tiempo desde el último acceso formateado
  String get tiempoDesdeUltimoAccesoFormateado {
    final tiempo = tiempoDesdeUltimoAcceso;
    if (tiempo == null) return 'Nunca';

    if (tiempo.inDays > 0) {
      return '${tiempo.inDays} días';
    } else if (tiempo.inHours > 0) {
      return '${tiempo.inHours} horas';
    } else if (tiempo.inMinutes > 0) {
      return '${tiempo.inMinutes} minutos';
    } else {
      return 'Recién';
    }
  }

  /// Obtiene el sistema operativo formateado
  String get sistemaOperativoFormateado {
    if (sistemaOperativo == null) return 'Desconocido';
    return sistemaOperativo!.toUpperCase();
  }

  @override
  String toString() {
    return 'DispositivoEntity(idDispositivo: $idDispositivo, imei: $imei, nombre: $nombreFormateado)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DispositivoEntity &&
        other.idDispositivo == idDispositivo &&
        other.idUsuario == idUsuario &&
        other.imei == imei;
  }

  @override
  int get hashCode {
    return Object.hash(
      idDispositivo,
      idUsuario,
      imei,
    );
  }
}
