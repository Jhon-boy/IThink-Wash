import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/core/entities/orden_entity.dart';
import 'package:ithinkwash/core/entities/orden_detalle_entity.dart';
import 'package:ithinkwash/core/entities/orden_detalle_adicional_entity.dart';
import 'package:ithinkwash/core/entities/pago_entity.dart';
import 'package:ithinkwash/core/errors/exception.dart';
import 'package:ithinkwash/core/network/http_client.dart';
import 'package:ithinkwash/core/services/supabase_service.dart';
import 'package:ithinkwash/core/utils/app_util.dart';
import 'package:ithinkwash/shared/enums/entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdenRemoteDataSource {
  final HttpClient? client;
  final WidgetRef? ref;

  OrdenRemoteDataSource({HttpClient? client, WidgetRef? ref})
      : client = client ?? (ref != null ? HttpClient(ref) : null),
        ref = ref;

  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<TordOrdenEntity>> getOrdenes() async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TORDORDEN.tableName,
        orderBy: 'fecharecepcion',
        ascending: false,
      );
      return result.map((json) => TordOrdenEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getOrdenes');
    }
  }

  Future<List<TordOrdenEntity>> getOrdenesBySucursal(int idSucursal) async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TORDORDEN.tableName,
        filters: {'idsucursal': idSucursal},
        orderBy: 'fecharecepcion',
        ascending: false,
      );
      return result.map((json) => TordOrdenEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getOrdenesBySucursal');
    }
  }

  Future<TordOrdenEntity?> getOrdenById(int idOrden) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TORDORDEN.tableName,
        filters: {'idorden': idOrden},
      );
      if (result == null) return null;
      return TordOrdenEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getOrdenById');
    }
  }

  Future<TordOrdenEntity> createOrden(TordOrdenEntity orden) async {
    try {
      final data = orden.toJson();
      data.remove('idorden');
      final result = await SupabaseService.insert(
        table: Entities.TORDORDEN.tableName,
        data: data,
      );
      return TordOrdenEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'createOrden');
    }
  }

  Future<TordOrdenEntity> updateOrden(TordOrdenEntity orden) async {
    try {
      final data = orden.toJson();
      data.remove('idorden');
      data['fmodificacion'] = AppUtils.getFechaActual().toIso8601String();
      final result = await SupabaseService.update(
        table: Entities.TORDORDEN.tableName,
        data: data,
        filters: {'idorden': orden.idOrden},
      );
      return TordOrdenEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'updateOrden');
    }
  }

  Future<bool> deleteOrden(int idOrden, String user) async {
    try {
      await SupabaseService.update(
        table: Entities.TORDORDEN.tableName,
        data: {
          'estado': 'CANCELADO',
          'fmodificacion': AppUtils.getFechaActual().toIso8601String(),
          'usuariomodificacion': user,
        },
        filters: {'idorden': idOrden},
      );
      return true;
    } catch (e) {
      _handleError(e, 'deleteOrden');
    }
  }

  Future<List<TordOrdenDetalleEntity>> getDetallesByOrden(int idOrden) async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TORDORDENDETALLE.tableName,
        filters: {'idorden': idOrden},
      );
      return result.map((json) => TordOrdenDetalleEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getDetallesByOrden');
    }
  }

  Future<TordOrdenDetalleEntity> createDetalle(TordOrdenDetalleEntity detalle) async {
    try {
      final data = detalle.toJson();
      data.remove('idordendetalle');
      final result = await SupabaseService.insert(
        table: Entities.TORDORDENDETALLE.tableName,
        data: data,
      );
      return TordOrdenDetalleEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'createDetalle');
    }
  }

  Future<bool> deleteDetalle(int idDetalle) async {
    try {
      await SupabaseService.delete(
        table: Entities.TORDORDENDETALLE.tableName,
        filters: {'idordendetalle': idDetalle},
      );
      return true;
    } catch (e) {
      _handleError(e, 'deleteDetalle');
    }
  }

  Future<List<TordOrdenDetalleAdicionalEntity>> getAdicionalesByDetalle(int idDetalle) async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TORDORDENDETALLEADICIONAL.tableName,
        filters: {'idordendetalle': idDetalle},
      );
      return result.map((json) => TordOrdenDetalleAdicionalEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getAdicionalesByDetalle');
    }
  }

  Future<TordOrdenDetalleAdicionalEntity> createAdicional(TordOrdenDetalleAdicionalEntity adicional) async {
    try {
      final data = adicional.toJson();
      data.remove('idordendetalleadicional');
      final result = await SupabaseService.insert(
        table: Entities.TORDORDENDETALLEADICIONAL.tableName,
        data: data,
      );
      return TordOrdenDetalleAdicionalEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'createAdicional');
    }
  }

  Future<List<TordPagoEntity>> getPagosByOrden(int idOrden) async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TORDPAGO.tableName,
        filters: {'idorden': idOrden},
      );
      return result.map((json) => TordPagoEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getPagosByOrden');
    }
  }

  Future<TordPagoEntity> createPago(TordPagoEntity pago) async {
    try {
      final data = pago.toJson();
      data.remove('idpago');
      data['fcreacion'] = AppUtils.getFechaActual().toIso8601String();
      final result = await SupabaseService.insert(
        table: Entities.TORDPAGO.tableName,
        data: data,
      );
      return TordPagoEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'createPago');
    }
  }

  Future<bool> deletePago(int idPago) async {
    try {
      await SupabaseService.delete(
        table: Entities.TORDPAGO.tableName,
        filters: {'idpago': idPago},
      );
      return true;
    } catch (e) {
      _handleError(e, 'deletePago');
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
