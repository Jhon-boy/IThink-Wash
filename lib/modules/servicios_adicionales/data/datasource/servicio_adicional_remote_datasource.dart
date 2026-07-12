import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/core/entities/servicio_adicional_entity.dart';
import 'package:ithinkwash/core/errors/exception.dart';
import 'package:ithinkwash/core/network/http_client.dart';
import 'package:ithinkwash/core/services/supabase_service.dart';
import 'package:ithinkwash/core/utils/app_util.dart';
import 'package:ithinkwash/shared/enums/entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ServicioAdicionalRemoteDataSource {
  final HttpClient? client;
  final WidgetRef? ref;

  ServicioAdicionalRemoteDataSource({HttpClient? client, WidgetRef? ref})
      : client = client ?? (ref != null ? HttpClient(ref) : null),
        ref = ref;

  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<TserServicioAdicionalEntity>> getServiciosAdicionales() async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TSERSERVICIOADICIONAL.tableName,
        orderBy: 'nombre',
        ascending: true,
      );
      return result.map((json) => TserServicioAdicionalEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getServiciosAdicionales');
    }
  }

  Future<TserServicioAdicionalEntity?> getServicioAdicionalById(int id) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TSERSERVICIOADICIONAL.tableName,
        filters: {'idservicioadicional': id},
      );
      if (result == null) return null;
      return TserServicioAdicionalEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getServicioAdicionalById');
    }
  }

  Future<TserServicioAdicionalEntity> createServicioAdicional(TserServicioAdicionalEntity entity) async {
    try {
      final data = entity.toJson();
      data.remove('idservicioadicional');
      data['fcreacion'] = AppUtils.getFechaActual().toIso8601String();

      final result = await SupabaseService.insert(
        table: Entities.TSERSERVICIOADICIONAL.tableName,
        data: data,
      );
      return TserServicioAdicionalEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'createServicioAdicional');
    }
  }

  Future<TserServicioAdicionalEntity> updateServicioAdicional(TserServicioAdicionalEntity entity) async {
    try {
      final data = entity.toJson();
      data['fmodificacion'] = AppUtils.getFechaActual().toIso8601String();

      final result = await SupabaseService.update(
        table: Entities.TSERSERVICIOADICIONAL.tableName,
        data: data,
        filters: {'idservicioadicional': entity.idServicioAdicional},
      );
      return TserServicioAdicionalEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'updateServicioAdicional');
    }
  }

  Future<bool> deleteServicioAdicional(int id, String user) async {
    try {
      await SupabaseService.update(
        table: Entities.TSERSERVICIOADICIONAL.tableName,
        data: {
          'estado': 'INACTIVO',
          'fmodificacion': AppUtils.getFechaActual().toIso8601String(),
          'usuariomodificacion': user,
        },
        filters: {'idservicioadicional': id},
      );
      return true;
    } catch (e) {
      _handleError(e, 'deleteServicioAdicional');
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
