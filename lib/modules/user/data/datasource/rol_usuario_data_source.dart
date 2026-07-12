import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/core/entities/rol_entity.dart';
import 'package:ithinkwash/core/entities/rol_usuario_entity.dart';
import 'package:ithinkwash/core/entities/usuario_entity.dart';
import 'package:ithinkwash/core/errors/exception.dart';
import 'package:ithinkwash/core/network/http_client.dart';
import 'package:ithinkwash/core/services/supabase_service.dart';
import 'package:ithinkwash/core/utils/app_util.dart';
import 'package:ithinkwash/shared/enums/entities.dart';
import 'package:ithinkwash/shared/enums/estados_general.dart';
import 'package:ithinkwash/shared/enums/roles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RolUsuarioRemoteDataSource {
  final HttpClient client;
  final WidgetRef ref;

  RolUsuarioRemoteDataSource({HttpClient? client, required this.ref})
      : client = client ?? HttpClient(ref);

  final SupabaseClient supabase = Supabase.instance.client;

  Future<TsegUsuarioEntity?> getUsuarioById(int idUsuario) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TSEGUSUARIO.tableName,
        filters: {'idusuario': idUsuario},
      );
      if (result == null) return null;
      return TsegUsuarioEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getUsuarioById');
    }
  }

  /// Obtener IDROL por código desde TROL
  Future<int?> getIdRolByCodigo(String codigo) async {
    try {
      final rol = await SupabaseService.selectSingle(
        table: Entities.TSEGROL.tableName,
        filters: {'codigo': codigo, 'estado': EstadosGeneral.ACTIVO.state},
      );
      if (rol == null) return null;
      return rol['idrol'] as int?;
    } catch (e) {
      _handleError(e, 'getIdRolByCodigo');
    }
  }

  /// Obtener usuarios por rol usando código
  Future<List<TsegUsuarioEntity>> getUsuariosByRol(String codigo) async {
    try {
      // Primero obtener IDROL desde TROL usando el código
      final idRol = await getIdRolByCodigo(codigo);
      if (idRol == null) {
        return [];
      }

      // Luego obtenemos los IDUSUARIO que tienen ese rol
      final rolUsuarios = await SupabaseService.select(
          table: Entities.TSEGROLUSUARIO.tableName,
          columns: 'idusuario',
          filters: {'idrol': idRol});

      if (rolUsuarios.isEmpty) {
        return [];
      }

      // Extraemos los IDs únicos
      final idsUsuarios =
          rolUsuarios.map((e) => e['idusuario'] as int).toSet().toList();

      // Obtenemos los usuarios con esos IDs
      final usuarios = <TsegUsuarioEntity>[];
      for (final idUsuario in idsUsuarios) {
        final usuario = await getUsuarioById(idUsuario);
        if (usuario != null) {
          usuarios.add(usuario);
        }
      }

      return usuarios;
    } catch (e) {
      _handleError(e, 'getUsuariosByRol');
    }
  }

  /// Agregar rol a un usuario
  Future<bool> agregarRolUsuario(int idUsuario, int idRol) async {
    try {
      // Verificar si ya existe
      final existente = await SupabaseService.selectSingle(
        table: Entities.TSEGROLUSUARIO.tableName,
        filters: {'idusuario': idUsuario, 'idrol': idRol},
      );

      if (existente != null) {
        // Si existe pero está inactivo, reactivarlo
        await SupabaseService.update(
          table: Entities.TSEGROLUSUARIO.tableName,
          data: {
            'estado': EstadosGeneral.ACTIVO.state,
            'fmodificacion': AppUtils.getFechaActual().toIso8601String(),
          },
          filters: {
            'idusuario': idUsuario,
            'idrol': idRol,
          },
          returnData: false,
        );
        return true;
      }

      await SupabaseService.insert(
        table: Entities.TSEGROLUSUARIO.tableName,
        data: {
          'idusuario': idUsuario,
          'idrol': idRol,
          'estado': EstadosGeneral.ACTIVO.state,
          'fcreacion': AppUtils.getFechaActual().toIso8601String(),
          'usuariocreacion': '0',
        },
      );
      return true;
    } catch (e) {
      _handleError(e, 'agregarRolUsuario');
    }
  }

  /// Quitar rol de un usuario usando código
  Future<bool> quitarRolUsuario(int idUsuario, String codigo) async {
    try {
      // Primero obtener IDROL desde TROL usando el código
      final idRol = await getIdRolByCodigo(codigo);
      if (idRol == null) {
        throw DatabaseException('Rol con código $codigo no encontrado');
      }

      // Actualizar estado a INACTIVO en lugar de eliminar
      await SupabaseService.update(
        table: Entities.TSEGROLUSUARIO.tableName,
        data: {
          'estado': EstadosGeneral.INACTIVO.state,
          'fmodificacion': AppUtils.getFechaActual().toIso8601String(),
          'usuariomodificacion': '0',
        },
        filters: {
          'idusuario': idUsuario,
          'idrol': idRol,
        },
        returnData: false,
      );
      return true;
    } catch (e) {
      _handleError(e, 'quitarRolUsuario');
    }
  }

  Future<bool> quitarRolUsuarioByIdRol(int idUsuario, int idRol) async {
    try {
      await SupabaseService.update(
        table: Entities.TSEGROLUSUARIO.tableName,
        data: {
          'estado': EstadosGeneral.INACTIVO.state,
          'fmodificacion': AppUtils.getFechaActual().toIso8601String(),
          'usuariomodificacion': '0',
        },
        filters: {
          'idusuario': idUsuario,
          'idrol': idRol,
        },
        returnData: false,
      );
      return true;
    } catch (e) {
      _handleError(e, 'quitarRolUsuarioByIdRol');
    }
  }

  /// Obtener roles de un usuario
  Future<List<int>> getRolesUsuario(int idUsuario) async {
    try {
      final roles = await SupabaseService.select(
        table: Entities.TSEGROLUSUARIO.tableName,
        columns: 'idrol',
        filters: {
          'idusuario': idUsuario,
          'estado': EstadosGeneral.ACTIVO.state
        },
      );
      return roles.map((e) => e['idrol'] as int?).whereType<int>().toList();
    } catch (e) {
      _handleError(e, 'getRolesUsuario');
    }
  }

  /// Obtener todos los registros de RolUsuario por IDUsuario
  Future<List<RolUsuarioEntity>> getRolUsuarioByUsuario(int idUsuario) async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TSEGROLUSUARIO.tableName,
        filters: {'idusuario': idUsuario},
        orderBy: 'fcreacion',
        ascending: false,
      );
      return result.map((json) => RolUsuarioEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getRolUsuarioByUsuario');
    }
  }

  /// Obtener todos los roles activos de la aplicación
  Future<List<RolEntity>> getRoles() async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TSEGROL.tableName,
        filters: {'estado': EstadosGeneral.ACTIVO.state},
        orderBy: 'fcreacion',
        ascending: false,
      );
      return result.map((json) => RolEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getRoles');
    }
  }

  Future<List<TsegUsuarioEntity>> getUsuariosSinRolCliente() async {
    try {
      final idRolCliente = await getIdRolByCodigo(Rol.CLIENTE.code);

      final rolUsuarios = idRolCliente != null
          ? await SupabaseService.select(
              table: Entities.TSEGROLUSUARIO.tableName,
              columns: 'idusuario',
              filters: {
                'idrol_neq': idRolCliente,
              },
            )
          : await SupabaseService.select(
              table: Entities.TSEGROLUSUARIO.tableName,
              columns: 'idusuario',
              filters: {'estado': EstadosGeneral.ACTIVO.state},
            );

      if (rolUsuarios.isEmpty) {
        return [];
      }

      final idsUsuarios = rolUsuarios
          .map((e) => e['idusuario'] as int?)
          .whereType<int>()
          .toSet()
          .toList();

      final usuarios = <TsegUsuarioEntity>[];
      for (final idUsuario in idsUsuarios) {
        final usuario = await getUsuarioById(idUsuario);
        if (usuario != null) {
          usuarios.add(usuario);
        }
      }

      return usuarios;
    } catch (e) {
      _handleError(e, 'getUsuariosSinRolCliente');
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
