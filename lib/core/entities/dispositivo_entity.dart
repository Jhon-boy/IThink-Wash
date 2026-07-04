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
      idDispositivo: json['iddispositivo'],
      idUsuario: json['idusuario'] ?? 0,
      imei: json['imei'],
      marca: json['marca'],
      modelo: json['modelo'],
      sistemaOperativo: json['sistemaoperativo'],
      versionSo: json['versionso'],
      nombreDispositivo: json['nombredispositivo'],
      ultimoAcceso: json['ultimoacceso'] != null ? DateTime.parse(json['ultimoacceso']) : null,
      activo: json['activo'] ?? true,
      fCreacion: json['fcreacion'] != null ? DateTime.parse(json['fcreacion']) : null,
      fModificacion: json['fmodificacion'] != null ? DateTime.parse(json['fmodificacion']) : null,
      usuarioCreacion: json['usuariocreacion'],
      usuarioModificacion: json['usuariomodificacion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iddispositivo': idDispositivo,
      'idusuario': idUsuario,
      'imei': imei,
      'marca': marca,
      'modelo': modelo,
      'sistemaoperativo': sistemaOperativo,
      'versionso': versionSo,
      'nombredispositivo': nombreDispositivo,
      'ultimoacceso': ultimoAcceso?.toIso8601String(),
      'activo': activo,
      'fcreacion': fCreacion?.toIso8601String(),
      'fmodificacion': fModificacion?.toIso8601String(),
      'usuariocreacion': usuarioCreacion,
      'usuariomodificacion': usuarioModificacion,
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

  bool get tieneImei => imei != null && imei!.isNotEmpty;
  bool get tieneInfoCompleta => marca != null && modelo != null && sistemaOperativo != null;

  String get nombreFormateado {
    if (nombreDispositivo != null && nombreDispositivo!.isNotEmpty) return nombreDispositivo!;
    if (marca != null && modelo != null) return '$marca $modelo';
    if (marca != null) return marca!;
    if (modelo != null) return modelo!;
    return 'Dispositivo desconocido';
  }

  String get ultimoAccesoFormateado {
    if (ultimoAcceso == null) return 'Nunca';
    return '${ultimoAcceso!.day.toString().padLeft(2, '0')}/${ultimoAcceso!.month.toString().padLeft(2, '0')}/${ultimoAcceso!.year}';
  }

  bool get isActivo => activo == true;

  Duration? get tiempoDesdeUltimoAcceso {
    if (ultimoAcceso == null) return null;
    return DateTime.now().difference(ultimoAcceso!);
  }

  String get tiempoDesdeUltimoAccesoFormateado {
    final tiempo = tiempoDesdeUltimoAcceso;
    if (tiempo == null) return 'Nunca';
    if (tiempo.inDays > 0) return '${tiempo.inDays} días';
    if (tiempo.inHours > 0) return '${tiempo.inHours} horas';
    if (tiempo.inMinutes > 0) return '${tiempo.inMinutes} minutos';
    return 'Recién';
  }

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
    return Object.hash(idDispositivo, idUsuario, imei);
  }
}
