import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/core/entities/persona_entity.dart';
import 'package:ithinkwash/core/errors/exception.dart';
import 'package:ithinkwash/core/models/user_model.dart';
import 'package:ithinkwash/core/network/http_client.dart';
import 'package:ithinkwash/core/services/supabase_service.dart';
import 'package:ithinkwash/core/utils/app_util.dart';
import 'package:ithinkwash/shared/enums/entities.dart';
import 'package:ithinkwash/shared/enums/estados_general.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PersonasRemoteDataSource {
  final HttpClient client;
  final WidgetRef ref;

  PersonasRemoteDataSource({HttpClient? client, required this.ref})
      : client = client ?? HttpClient(ref);

  final SupabaseClient supabase = Supabase.instance.client;

  /// Obtener todas las personas
  /// [includeDeletes] Si es true, incluye personas inactivas. Por defecto solo trae activas (ACT)
  Future<List<PersonaEntity>> getPersonas({
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    bool includeDeletes = false,
  }) async {
    try {
      final filters = <String, dynamic>{};

      // Solo filtrar por estado activo si includeDeletes es false
      if (!includeDeletes) {
        filters['estado'] = EstadosGeneral.ACTIVO.state;
      }

      if (fechaDesde != null) {
        filters['fcreacion_gte'] = fechaDesde.toIso8601String();
      }
      if (fechaHasta != null) {
        filters['fcreacion_lte'] = fechaHasta.toIso8601String();
      }

      final result = await SupabaseService.select(
        table: Entities.TPERPERSONA.tableName,
        filters: filters.isNotEmpty ? filters : null,
        orderBy: 'fcreacion',
        ascending: false,
      );
      return result.map((json) => PersonaEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getPersonas');
    }
  }

  /// Obtener persona por ID (solo trae personas activas - estado ACT)
  Future<PersonaEntity?> getPersonaById(String idPersona) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TPERPERSONA.tableName,
        filters: {
          'idpersona': idPersona,
          // 'ESTADO': EstadosGeneral.ACTIVO.state,
        },
      );
      if (result == null) return null;
      return PersonaEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getPersonaById');
    }
  }

  /// Obtener persona por ID (solo trae personas activas - estado ACT)
  Future<PersonaEntity?> getPersonaByIdentificacion(
      String idetificacion) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TPERPERSONA.tableName,
        filters: {
          'identificacion': idetificacion,
          //'estado': EstadosGeneral.ACTIVO.state,
        },
      );
      if (result == null) return null;
      return PersonaEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getPersonaById');
    }
  }

  /// Crear nueva persona
  Future<PersonaEntity> createPersona(
      PersonaEntity persona, UserModel? user) async {
    try {
      final data = persona.toJson();
      data.remove('idpersona');
      if (user != null) data['usuariocreacion'] = user.idUsuario.toString();

      final result = await SupabaseService.insert(
        table: Entities.TPERPERSONA.tableName,
        data: data,
      );
      return PersonaEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'createPersona');
    }
  }

  /// Actualizar persona por IDENTIFICACION
  Future<PersonaEntity> updatePersonaById(
      String idPersona, Map<String, dynamic>? data) async {
    try {
      final result = await SupabaseService.update(
        table: Entities.TPERPERSONA.tableName,
        data: data ?? {},
        filters: {'identificacion': idPersona},
        returnData: true,
      );
      return PersonaEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'updatePersonaById');
    }
  }

  /// Eliminar persona (eliminación lógica - cambia estado a INACTIVO)
  Future<bool> deletePersona(String idPersona, UserModel? user) async {
    try {
      final data = {
        'ESTADO': EstadosGeneral.INACTIVO.state,
        'fmodificacion': AppUtils.getFechaActual().toIso8601String(),
      };

      if (user != null) {
        data['usuariomodificacion'] = user.idUsuario.toString();
      }

      await SupabaseService.update(
        table: Entities.TPERPERSONA.tableName,
        data: data,
        filters: {'identificacion': idPersona},
        returnData: false,
      );
      return true;
    } catch (e) {
      _handleError(e, 'deletePersona');
    }
  }

  /// Buscar personas por filtros opcionales
  Future<List<PersonaEntity>> searchPersonas({
    String? nombres,
    String? apellidos,
    String? correo,
    String? telefono,
    bool? activo,
  }) async {
    try {
      final allPersonas = await SupabaseService.select(
        table: Entities.TPERPERSONA.tableName,
      );

      var filtered = allPersonas;
      if (nombres != null && nombres.isNotEmpty) {
        filtered = filtered
            .where((p) => (p['nombres'] as String)
                .toLowerCase()
                .contains(nombres.toLowerCase()))
            .toList();
      }
      if (apellidos != null && apellidos.isNotEmpty) {
        filtered = filtered
            .where((p) => (p['apellidos'] as String)
                .toLowerCase()
                .contains(apellidos.toLowerCase()))
            .toList();
      }
      if (correo != null && correo.isNotEmpty) {
        filtered = filtered
            .where((p) => (p['correo'] as String)
                .toLowerCase()
                .contains(correo.toLowerCase()))
            .toList();
      }
      if (telefono != null && telefono.isNotEmpty) {
        filtered = filtered
            .where((p) => (p['telefono'] as String)
                .toLowerCase()
                .contains(telefono.toLowerCase()))
            .toList();
      }
      if (activo != null) {
        filtered = filtered.where((p) => p['activo'] == activo).toList();
      }

      return filtered.map((json) => PersonaEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'searchPersonas');
    }
  }

  /// Cambiar estado de persona
  Future<PersonaEntity> toggleEstadoPersona(
      String idPersona, bool? activo) async {
    try {
      final result = await SupabaseService.update(
        table: Entities.TPERPERSONA.tableName,
        data: {
          'estado': activo == true
              ? EstadosGeneral.ACTIVO.state
              : EstadosGeneral.INACTIVO.state
        },
        filters: {'identificacion': idPersona},
      );
      return PersonaEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'toggleEstadoPersona');
    }
  }

  Never _handleError(dynamic error, String method) {
    debugPrint('Error $error');
    if (error is SessionException) {
      throw SessionException('Error de sesión en $method: ${error.message}');
    }
    if (error is DatabaseException) {
      throw DatabaseException('Error de BD en $method: ${error.message}');
    }
    throw DatabaseException('Error inesperado en $method: $error');
  }
}
