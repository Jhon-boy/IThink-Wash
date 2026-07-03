import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/core/entities/usuario_entity.dart';
import 'package:ithinkwash/core/errors/exception.dart';
import 'package:ithinkwash/core/network/http_client.dart';
import 'package:ithinkwash/core/services/supabase_service.dart'; 
import 'package:ithinkwash/shared/enums/entities.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsuariosRemoteDataSource {
  final HttpClient client;
  final WidgetRef ref;

  UsuariosRemoteDataSource({HttpClient? client, required this.ref})
      : client = client ?? HttpClient(ref);

  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<TsegUsuarioEntity>> getUsuariosBySucursal(
    int idSucursal, {
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  }) async {
    try {
      final filters = <String, dynamic>{'IDSUCURSAL': idSucursal};
      if (fechaDesde != null) {
        filters['FCREACION_gte'] = fechaDesde.toIso8601String();
      }
      if (fechaHasta != null) {
        filters['FCREACION_lte'] = fechaHasta.toIso8601String();
      }

      final result = await SupabaseService.select(
        table: Entities.TSEGUSUARIO.tableName,
        filters: filters,
        orderBy: 'FCREACION',
        ascending: false,
      );
      return result.map((json) => TsegUsuarioEntity.fromJson(json)).toList();
    } catch (e) {
      _handleError(e, 'getUsuariosBySucursal');
    }
  }

  Future<TsegUsuarioEntity?> getUsuarioById(int idUsuario) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TSEGUSUARIO.tableName,
        filters: {'IDUSUARIO': idUsuario},
      );
      if (result == null) return null;
      return TsegUsuarioEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getUsuarioById');
    }
  }

  Future<TsegUsuarioEntity?> getUsuarioByIdentificacion(
      String identificacion) async {
    try {
      final result = await SupabaseService.selectSingle(
        table: Entities.TSEGUSUARIO.tableName,
        filters: {'IDENTIFICACION': identificacion},
      );
      if (result == null) return null;
      return TsegUsuarioEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'getUsuarioByIdentificacion');
    }
  }

  Future<TsegUsuarioEntity> createUsuario(TsegUsuarioEntity usuario) async {
    try {
      final data = usuario.toJson();
      if (data.containsKey('IDUSUARIO') && data['IDUSUARIO'] == 0) {
        data.remove('IDUSUARIO');
      }
      final result = await SupabaseService.insert(
        table: Entities.TSEGUSUARIO.tableName,
        data: data,
      );
      return TsegUsuarioEntity.fromJson(result);
    } catch (e) {
      _handleError(e, 'createUsuario');
    }
  }

  Future<TsegUsuarioEntity> updateUsuario(
      int idUsuario, Map<String, dynamic> data) async {
    try {
      final result = await SupabaseService.update(
        table: Entities.TSEGUSUARIO.tableName,
        data: data,
        filters: {'IDUSUARIO': idUsuario},
        returnData: true,
      );
      return TsegUsuarioEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'updateUsuario');
    }
  }

  Future<bool> changePassword(
      int idUsuario, String oldPassword, String newPassword) async {
    try {
      // Aquí podrías validar oldPassword si tu lógica lo requiere
      final result = await SupabaseService.update(
        table: Entities.TSEGUSUARIO.tableName,
        data: {'PASSWORD': newPassword},
        filters: {'IDUSUARIO': idUsuario},
      );
      return result.isNotEmpty;
    } catch (e) {
      _handleError(e, 'changePassword');
    }
  }

  Future<bool> resetPassword(int idUsuario, String newPassword) async {
    try {
      final result = await SupabaseService.update(
        table: Entities.TSEGUSUARIO.tableName,
        data: {'PASSWORD': newPassword},
        filters: {'IDUSUARIO': idUsuario},
      );
      return result.isNotEmpty;
    } catch (e) {
      _handleError(e, 'resetPassword');
    }
  }

  Future<TsegUsuarioEntity> toggleEstadoUsuario(int idUsuario,
      {bool activo = true}) async {
    try {
      final result = await SupabaseService.update(
        table: Entities.TSEGUSUARIO.tableName,
        data: {'ESTADO': activo ? 'ACTIVO' : 'INACTIVO'},
        filters: {'IDUSUARIO': idUsuario},
        returnData: true,
      );
      return TsegUsuarioEntity.fromJson(result.first);
    } catch (e) {
      _handleError(e, 'toggleEstadoUsuario');
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
