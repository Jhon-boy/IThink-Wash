import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/core/entities/concepto_entity.dart';
import 'package:ithinkwash/core/errors/exception.dart';
import 'package:ithinkwash/core/network/http_client.dart';
import 'package:ithinkwash/core/services/supabase_service.dart';
import 'package:ithinkwash/core/utils/app_util.dart';
import 'package:ithinkwash/shared/enums/entities.dart';
import 'package:ithinkwash/shared/enums/estados_general.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConceptoRemoteDataSource {
  final HttpClient? client;
  final WidgetRef? ref;

  ConceptoRemoteDataSource({HttpClient? client, WidgetRef? ref})
      : client = client ?? (ref != null ? HttpClient(ref) : null),
        ref = ref;

  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<TserConceptoEntity>> getConceptos() async {
    try {
      final result = await SupabaseService.select(
        table: Entities.TSERCONCEPTO.tableName,
        orderBy: 'nombre',
        ascending: true,
      );
      return result.map((json) => TserConceptoEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getConceptos');
    }
  }

  Future<TserConceptoEntity?> getConceptoById(int idConcepto) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TSERCONCEPTO.tableName,
        filters: {'idconcepto': idConcepto},
      );
      if (result == null) return null;
      return TserConceptoEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getConceptoById');
    }
  }

  Future<TserConceptoEntity> createConcepto(TserConceptoEntity concepto) async {
    try {
      final data = concepto.toJson();
      data.remove('idconcepto');
      data['fcreacion'] = AppUtils.getFechaActual().toIso8601String();

      final result = await SupabaseService.insert(
        table: Entities.TSERCONCEPTO.tableName,
        data: data,
      );
      return TserConceptoEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'createConcepto');
    }
  }

  Future<TserConceptoEntity> updateConcepto(TserConceptoEntity concepto) async {
    try {
      final data = concepto.toJson();
      data.remove('idconcepto');
      data['fmodificacion'] = AppUtils.getFechaActual().toIso8601String();

      final result = await SupabaseService.update(
        table: Entities.TSERCONCEPTO.tableName,
        data: data,
        filters: {'idconcepto': concepto.idConcepto},
      );
      return TserConceptoEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'updateConcepto');
    }
  }

  Future<bool> deleteConcepto(int idConcepto, String userModificacion) async {
    try {
      await SupabaseService.update(
        table: Entities.TSERCONCEPTO.tableName,
        data: {
          'estado': EstadosGeneral.INACTIVO.state,
          'fmodificacion': AppUtils.getFechaActual().toIso8601String(),
          'usuariomodificacion': userModificacion,
        },
        filters: {'idconcepto': idConcepto},
      );
      return true;
    } catch (e) {
      _handleError(e, 'deleteConcepto');
    }
  }

  Future<TserConceptoEntity> toggleEstadoConcepto(int idConcepto, bool activo, String user) async {
    try {
      final estado = activo ? EstadosGeneral.ACTIVO.state : EstadosGeneral.INACTIVO.state;
      final result = await SupabaseService.update(
        table: Entities.TSERCONCEPTO.tableName,
        data: {
          'estado': estado,
          'fmodificacion': AppUtils.getFechaActual().toIso8601String(),
          'usuariomodificacion': user,
        },
        filters: {'idconcepto': idConcepto},
      );
      return TserConceptoEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'toggleEstadoConcepto');
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
