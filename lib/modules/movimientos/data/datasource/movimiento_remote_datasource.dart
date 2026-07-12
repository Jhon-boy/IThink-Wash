import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/core/entities/movimiento_entity.dart';
import 'package:ithinkwash/core/errors/exception.dart';
import 'package:ithinkwash/core/network/http_client.dart';
import 'package:ithinkwash/core/services/supabase_service.dart';
import 'package:ithinkwash/core/utils/app_util.dart';
import 'package:ithinkwash/shared/enums/entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MovimientoRemoteDataSource {
  final HttpClient? client;
  final WidgetRef? ref;

  MovimientoRemoteDataSource({HttpClient? client, WidgetRef? ref})
      : client = client ?? (ref != null ? HttpClient(ref) : null),
        ref = ref;

  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<TfinMovimientoEntity>> getMovimientos() async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TFINMOVIMIENTO.tableName,
        orderBy: 'fecha',
        ascending: false,
      );
      return result.map((json) => TfinMovimientoEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getMovimientos');
    }
  }

  Future<TfinMovimientoEntity?> getMovimientoById(int idMovimiento) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TFINMOVIMIENTO.tableName,
        filters: {'idmovimiento': idMovimiento},
      );
      if (result == null) return null;
      return TfinMovimientoEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getMovimientoById');
    }
  }

  Future<TfinMovimientoEntity> createMovimiento(TfinMovimientoEntity movimiento) async {
    try {
      final data = movimiento.toJson();
      data.remove('idmovimiento');
      data['fcreacion'] = AppUtils.getFechaActual().toIso8601String();
      final result = await SupabaseService.insert(
        table: Entities.TFINMOVIMIENTO.tableName,
        data: data,
      );
      return TfinMovimientoEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'createMovimiento');
    }
  }

  Future<TfinMovimientoEntity> updateMovimiento(TfinMovimientoEntity movimiento) async {
    try {
      final data = movimiento.toJson();
      data['fmodificacion'] = AppUtils.getFechaActual().toIso8601String();
      final result = await SupabaseService.update(
        table: Entities.TFINMOVIMIENTO.tableName,
        data: data,
        filters: {'idmovimiento': movimiento.idMovimiento},
      );
      return TfinMovimientoEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'updateMovimiento');
    }
  }

  Future<bool> deleteMovimiento(int idMovimiento, String user) async {
    try {
      await SupabaseService.update(
        table: Entities.TFINMOVIMIENTO.tableName,
        data: {
          'estado': 'INACTIVO',
          'fmodificacion': AppUtils.getFechaActual().toIso8601String(),
          'usuariomodificacion': user,
        },
        filters: {'idmovimiento': idMovimiento},
      );
      return true;
    } catch (e) {
      _handleError(e, 'deleteMovimiento');
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
