import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/core/entities/sesion_entity.dart';
import 'package:ithinkwash/core/errors/exception.dart';
import 'package:ithinkwash/core/services/supabase_service.dart';
import 'package:ithinkwash/core/utils/app_util.dart';
import 'package:ithinkwash/shared/enums/entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionRemoteDataSource {
  final WidgetRef ref;
  SessionRemoteDataSource({required this.ref});
  final SupabaseClient supabase = Supabase.instance.client;

  Future<bool> createSesion(SesionEntity sesion) async {
    try {
      final data = sesion.toJson();
      if (data['fechainicio'] == null) {
        data['fechainicio'] = AppUtils.getFechaActual().toIso8601String();
      }
      await SupabaseService.insert(
        table: Entities.TSEGSESION.tableName,
        data: data,
      );
      return true;
    } catch (e) {
      _handleError(e, 'createSesion');
    }
  }

  Future<List<SesionEntity>> getAllSesions(
      DateTime fechaDesde, DateTime fechaHasta) async {
    try {
      final result = await SupabaseService.select(
          table: Entities.TSEGSESION.tableName,
          ascending: true,
          filters: {
            'fechainicio_gte': fechaDesde.toIso8601String(),
            'fechainicio_lte': fechaHasta.toIso8601String(),
          });
      return result.map((json) => SesionEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getMovimientos');
    }
  }

  Future<SesionEntity?> getSesionById(String idSesion) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TSEGSESION.tableName,
        filters: {'idsesion': idSesion},
      );
      if (result == null) return null;
      return SesionEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getSesionById');
    }
  }

  Future<List<SesionEntity>> getSesionesByUsuario(
      int idUsuario, DateTime fechaDesde, DateTime fechaHasta) async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TSEGSESION.tableName,
        filters: {
          'idusuario': idUsuario,
          'fechainicio_gte': fechaDesde.toIso8601String(),
          'fechainicio_lte': fechaHasta.toIso8601String(),
        },
      );
      return result.map((json) => SesionEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getSesionesByUsuario');
    }
  }

  Never _handleError(dynamic error, String method) {
    debugPrint('Error: $error');
    throw DatabaseException('Error en $method: $error');
  }
}
