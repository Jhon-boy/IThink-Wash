import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/core/entities/sucursal_entity.dart';
import 'package:ithinkwash/core/errors/exception.dart';
import 'package:ithinkwash/core/network/http_client.dart';
import 'package:ithinkwash/core/services/supabase_service.dart';
import 'package:ithinkwash/core/utils/app_util.dart'; 
import 'package:ithinkwash/shared/enums/entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SucursalRemoteDataSource {
  final HttpClient? client;
  final WidgetRef? ref;

  SucursalRemoteDataSource({HttpClient? client, WidgetRef? ref})
      : client = client ?? (ref != null ? HttpClient(ref) : null),
        ref = ref;

  final SupabaseClient supabase = Supabase.instance.client;

  /// OBTENER TODAS LAS SUCURSALES
  Future<List<SucursalEntity>> getSucursales() async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TORGSUCURSAL.tableName,
        filters: {'estado': true},
        orderBy: 'fcreacion',
        ascending: false,
      );

      return result.map((json) => SucursalEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getSucursales');
    }
  }

  Future<List<SucursalEntity>> getSucursalesFree() async {
    try {
      final result = await SupabaseService.selectListFree(
        table: Entities.TORGSUCURSAL.tableName,
        filters: {'estado': true},
      );
      return result.map((json) => SucursalEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getSucursales');
    }
  }

  /// OBTENER SUCURSAL POR ID
  Future<SucursalEntity?> getSucursalById(int idSucursal) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TORGSUCURSAL.tableName,
        filters: {'idsucursal': idSucursal},
      );

      if (result == null) return null;
      return SucursalEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getSucursalById');
    }
  }

  /// OBTENER SUCURSALES ACTIVAS
  Future<List<SucursalEntity>> getSucursalesActivas() async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TORGSUCURSAL.tableName,
        filters: {'estado': true},
        orderBy: 'nombre',
        ascending: true,
      );

      return result.map((json) => SucursalEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getSucursalesActivas');
    }
  }

  /// REGISTRAR NUEVA SUCURSAL
  Future<SucursalEntity> createSucursal(SucursalEntity sucursal) async {
    try {
      final data = {
        'nombre': sucursal.nombre,
        'direccion': sucursal.direccion,
        'estado': sucursal.estado ?? true,
        'latitud': sucursal.latitud,
        'longitud': sucursal.longitud,
        'contacto': sucursal.contacto,
        'fcreacion': AppUtils.getFechaActual().toIso8601String(),
        'usuariocreacion': sucursal.usuarioCreacion,
      };

      final result = await SupabaseService.insert(
        table: Entities.TORGSUCURSAL.tableName,
        data: data,
      );

      return SucursalEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'createSucursal');
    }
  }

  /// ACTUALIZAR SUCURSAL
  Future<SucursalEntity> updateSucursal(SucursalEntity sucursal) async {
    try {
      final data = {
        'nombre': sucursal.nombre,
        'direccion': sucursal.direccion,
        'estado': sucursal.estado,
        'latitud': sucursal.latitud,
        'longitud': sucursal.longitud,
        'contacto': sucursal.contacto,
        'fmodificacion': AppUtils.getFechaActual().toIso8601String(),
        'usuariomodificacion': sucursal.usuarioModificacion,
      };

      final result = await SupabaseService.update(
        table: Entities.TORGSUCURSAL.tableName,
        data: data,
        filters: {'idsucursal': sucursal.idSucursal},
      );

      return SucursalEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'updateSucursal');
    }
  }

  /// ELIMINAR SUCURSAL (SOFT DELETE - CAMBIAR ESTADO A FALSE)
  Future<bool> deleteSucursal(int idSucursal, String userModificacion) async {
    try {
      await SupabaseService.update(
        table: Entities.TORGSUCURSAL.tableName,
        data: {
          'estado': false,
          'fmodificacion': AppUtils.getFechaActual().toIso8601String(),
          'usuariomodificacion': userModificacion,
        },
        filters: {'idsucursal': idSucursal},
      );

      return true;
    } catch (e) {
      _handleError(e, 'deleteSucursal');
    }
  }

  /// ELIMINAR SUCURSAL PERMANENTEMENTE (HARD DELETE)
  Future<bool> deleteSucursalPermanently(int idSucursal) async {
    try {
      await SupabaseService.delete(
        table: Entities.TORGSUCURSAL.tableName,
        filters: {'idsucursal': idSucursal},
      );

      return true;
    } catch (e) {
      _handleError(e, 'deleteSucursalPermanently');
    }
  }

  /// BUSCAR SUCURSALES POR NOMBRE
  Future<List<SucursalEntity>> searchSucursalesByName(String nombre) async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TORGSUCURSAL.tableName,
        filters: {
          'nombre': {'ilike': '%$nombre%'}
        },
        orderBy: 'nombre',
        ascending: true,
      );

      return result.map((json) => SucursalEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'searchSucursalesByName');
    }
  }

  /// ACTIVAR/DESACTIVAR SUCURSAL
  Future<bool> toggleSucursalEstado(
      int idSucursal, bool estado, String userModificacion) async {
    try {
      await SupabaseService.update(
        table: Entities.TORGSUCURSAL.tableName,
        data: {
          'estado': estado,
          'fmodificacion': AppUtils.getFechaActual().toIso8601String(),
          'usuariomodificacion': userModificacion,
        },
        filters: {'idsucursal': idSucursal},
      );

      return true;
    } catch (e) {
      _handleError(e, 'toggleSucursalEstado');
    }
  }

  /// OBTENER ESTADÍSTICAS DE SUCURSALES
  Future<Map<String, dynamic>> getSucursalesEstadisticas() async {
    try {
      final allSucursales = await getSucursales();
      final activas = allSucursales.where((s) => s.estado == true).length;
      final inactivas = allSucursales.where((s) => s.estado == false).length;

      return {
        'total': allSucursales.length,
        'activas': activas,
        'inactivas': inactivas,
        'ultimaActualizacion': AppUtils.getFechaActual().toIso8601String(),
      };
    } catch (e) {
      _handleError(e, 'getSucursalesEstadisticas');
    }
  }

  Never _handleError(dynamic error, String method) {
    if (error is SessionException) {
      throw SessionException('Error de sesión en $method: ${error.message}');
    }
    if (error is DatabaseException) {
      throw DatabaseException('Error de BD en $method: ${error.message}');
    }
    throw DatabaseException('Error inesperado en $method: $error');
  }
}
