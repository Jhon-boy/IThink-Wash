import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/core/entities/dispositivo_entity.dart';
import 'package:ithinkwash/core/entities/persona_entity.dart';
import 'package:ithinkwash/core/entities/rol_entity.dart';
import 'package:ithinkwash/core/errors/exception.dart';
import 'package:ithinkwash/core/models/deviceInfo_model.dart';
import 'package:ithinkwash/core/models/user_model.dart';
import 'package:ithinkwash/core/network/http_client.dart';
import 'package:ithinkwash/core/services/enhanced_auth_service.dart';
import 'package:ithinkwash/core/services/supabase_service.dart';
import 'package:ithinkwash/core/utils/app_util.dart';
import 'package:ithinkwash/shared/enums/entities.dart';
import 'package:ithinkwash/shared/enums/estados_persona.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AuthRemoteDataSourceImpl {
  final HttpClient client;
  final WidgetRef ref;

  AuthRemoteDataSourceImpl({HttpClient? client, required this.ref})
      : client = client ?? HttpClient(ref);
  final SupabaseClient supabase = Supabase.instance.client;

  /// LOGIN con usuario y contraseña
  Future<UserModel> login(String usuario, String password) async {
    try {
      return await EnhancedAuthService.login(usuario, password);
    } catch (e) {
      debugPrint("Error en login: ${e.toString()}");
      if (e is ServerException) rethrow;
      throw ServerException(message: "Error en login: ${e.toString()}");
    }
  }

  /// MÉTODO REUTILIZABLE PARA OBTENER DATOS DE PERSONA
  Future<PersonaEntity> getPersonaByIdentificacion(
      String identificacion) async {
    try {
      final response = await supabase
          .from(Entities.TPERPERSONA.tableName)
          .select("*")
          .eq("identificacion", identificacion)
          .maybeSingle();

      if (response == null) {
        throw ServerException(
          message: "No se encontraron datos de persona para $identificacion",
        );
      }

      return PersonaEntity.fromJson(response);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
          message: "Error obteniendo datos de persona: ${e.toString()}");
    }
  }


  /// Verifica si un dispositivo es de confianza
  Future<UserModel?> isTrustedDevice(DeviceInfoModel deviceInfo) async {
    try {
      debugPrint('isTrustedDevice: ${deviceInfo.toJson()}');
      final deviceRecord = await SupabaseService.selectSingleFree(
        table: Entities.TSEGDISPOSITIVO.tableName,
        filters: {
          'imei': deviceInfo.idUnico,
        },
      );

      if (deviceRecord == null) return null;
      if (!_verifyDeviceData(deviceInfo, deviceRecord)) return null;
      final userId = deviceRecord['idusuario'] as int;
      final user = await _buildUserModel(userId);
      await EnhancedAuthService.saveDeviceTrustSession(
        user: user,
        sessionToken: AppUtils.generateToken(),
        expiry: AppUtils.generateTimeExpiration(),
      );
      return user;
    } catch (e) {
      debugPrint("Error verificando dispositivo: ${e.toString()}");
      return null;
    }
  }

  /// Verifica si un dispositivo es de confianza
  Future<DispositivoEntity?> getDeviceByIdDispositivo(String imei) async {
    try {
      final deviceRecord = await SupabaseService.selectSingleFree(
        table: Entities.TSEGDISPOSITIVO.tableName,
        filters: {
          'imei': imei,
        },
      );

      if (deviceRecord == null) return null;
      return DispositivoEntity.fromJson(deviceRecord);
    } catch (e) {
      debugPrint("Error verificando dispositivo: ${e.toString()}");
      return null;
    }
  }

// Obtiene la informacion del usuario a travez del IDUSUARIO
  Future<UserModel> _buildUserModel(int userId) async {
    final userRecord = await SupabaseService.selectSingleFree(
      table: Entities.TSEGUSUARIO.tableName,
      filters: {'idusuario': userId},
    );

    if (userRecord == null) {
      throw ServerException(
        message: "No se encontraron datos de usuario para $userId",
      );
    }

    final personaRecord = await SupabaseService.selectSingleFree(
      table: Entities.TPERPERSONA.tableName,
      filters: {'idpersona': userRecord['idpersona']},
    );

    if (personaRecord == null) {
      throw ServerException(
        message:
            "No se encontraron datos de persona para idpersona ${userRecord['idpersona']}",
      );
    }
    if (personaRecord['estado'] == EstadosPersona.INACTIVO.state) {
      throw ServerException(
        message: "Inicio de sesión no permitido: Estado inactivo",
      );
    }
    if (personaRecord['estado'] == EstadosPersona.BLOQUEADO.state) {
      throw ServerException(
        message: "Inicio de sesión no permitido: Estado bloqueado",
      );
    }
    if (personaRecord['estado'] == EstadosPersona.SUSPENDIDO.state) {
      throw ServerException(
        message: "Inicio de sesión no permitido: Estado suspendido",
      );
    }
    if (personaRecord['estado'] == EstadosPersona.PENDIENTE.state) {
      throw ServerException(
        message: "Inicio de sesión no permitido: Estado pendiente",
      );
    }

    return UserModel.fromJson(
      usuarioJson: userRecord,
      personaJson: personaRecord,
    );
  }

  /// Verifica si el dispositivo actual es de confianza
  Future<bool> isCurrentDeviceTrusted() async {
    try {
      final deviceInfo = await AppUtils.getInfoDevice();
      final userModel = await isTrustedDevice(deviceInfo);

      return userModel != null;
    } catch (e) {
      debugPrint(
          "Error obteniendo información del dispositivo: ${e.toString()}");
      return false;
    }
  }

  /// Registra un dispositivo como de confianza
  /// Recibe el UserModel y el DeviceInfoModel para vincular correctamente el dispositivo con el usuario
  Future<bool> registerTrustedDevice(
      UserModel entity, DeviceInfoModel deviceInfo) async {
    try {
      debugPrint('registerTrustedDevice: ${deviceInfo.toJson()}');
      // Validar que el dispositivo tenga un IMEI válido
      if (deviceInfo.idUnico == null || deviceInfo.idUnico!.isEmpty) {
        debugPrint('ERROR: El dispositivo no tiene un IMEI válido');
        return false;
      }

      // Verificar si ya existe un dispositivo con este IMEI
      final existingDevice = await SupabaseService.selectSingle(
        table: Entities.TSEGDISPOSITIVO.tableName,
        filters: {
          'imei': deviceInfo.idUnico,
        },
      );

      if (existingDevice != null) {
        // Si el dispositivo ya existe y pertenece a otro usuario, no permitir el registro
        final existingUserId = existingDevice['idusuario'] as int;
        if (existingUserId != entity.idUsuario) {
          debugPrint(
              'ERROR: El dispositivo ya está registrado por otro usuario');
          return false;
        }

        await SupabaseService.update(
          table: Entities.TSEGDISPOSITIVO.tableName,
          data: {
            'ultimoacceso': AppUtils.getFechaActual().toIso8601String(),
            'fmodificacion': AppUtils.getFechaActual().toIso8601String(),
            'usuariomodificacion': entity.usuario ?? '',
          },
          filters: {
            'imei': deviceInfo.idUnico,
          },
        );
        debugPrint('Dispositivo actualizado exitosamente');
        return true;
      }

      await SupabaseService.insert(
        table: Entities.TSEGDISPOSITIVO.tableName,
        data: {
          'idusuario': entity.idUsuario,
          'imei': deviceInfo.idUnico,
          'marca': deviceInfo.fabricante ?? 'Desconocida',
          'modelo': deviceInfo.modelo ?? 'Desconocido',
          'sistemaoperativo': deviceInfo.sistemaOperativo ?? 'Desconocido',
          'versionso': deviceInfo.versionSO,
          'nombredispositivo': deviceInfo.modelo ?? 'Desconocido',
          'activo': true,
          'ultimoacceso': AppUtils.getFechaActual().toIso8601String(),
          'fcreacion': AppUtils.getFechaActual().toIso8601String(),
          'fmodificacion': AppUtils.getFechaActual().toIso8601String(),
          'usuariocreacion': entity.usuario ?? '',
          'usuariomodificacion': entity.usuario ?? '',
        },
      );

      debugPrint(
          'Dispositivo registrado exitosamente con IMEI: ${deviceInfo.idUnico}');
      return true;
    } catch (e) {
      debugPrint('ERROR EN LA BASE DE DATOS al registrar dispositivo: $e');
      return false;
    }
  }

  /// Elimina un dispositivo de confianza
  Future<bool> removeTrustedDevice(String imei) async {
    try {
      await SupabaseService.delete(
        table: Entities.TSEGDISPOSITIVO.tableName,
        filters: {
          'imei': imei,
        },
      );
      return true;
    } catch (e) {
      debugPrint("Error eliminando dispositivo: ${e.toString()}");
      return false;
    }
  }

  /// Verifica si los datos del dispositivo coinciden con los registrados
  bool _verifyDeviceData(
      DeviceInfoModel currentDevice, Map<String, dynamic> registeredDevice) {
    if (currentDevice.fabricante?.toLowerCase() !=
        (registeredDevice['marca'] ?? '').toString().toLowerCase()) {
      return false;
    }

    if (currentDevice.modelo?.toLowerCase() !=
        (registeredDevice['modelo'] ?? '').toString().toLowerCase()) {
      return false;
    }

    if (currentDevice.sistemaOperativo?.toLowerCase() !=
        (registeredDevice['sistemaoperativo'] ?? '').toString().toLowerCase()) {
      return false;
    }

    return true;
  }

  Future<List<RolEntity>> getRolesUsuario(int idUsuario) async {
    try {
      final List<Map<String, dynamic>> records = await SupabaseService.select(
        table: Entities.TSEGROLUSUARIO.tableName,
        columns:
            'tsegrol(idrol, codigo, nombre, fcreacion, fmodificacion, observacion, estado, usuariocreacion, usuariomodificacion)',
        filters: {'idusuario': idUsuario},
      );

      final roles = records.map((r) {
        final rolData = r[Entities.TSEGROL.tableName] as Map<String, dynamic>;
        return RolEntity.fromJson(rolData);
      }).toList();

      return roles;
    } catch (e) {
      debugPrint("Error obteniendo roles del usuario: ${e.toString()}");
      return [];
    }
  }
}
