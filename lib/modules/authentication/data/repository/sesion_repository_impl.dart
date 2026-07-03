import 'package:dartz/dartz.dart';
import 'package:ithinkwash/core/entities/sesion_entity.dart';
import 'package:ithinkwash/core/models/user_model.dart';
import 'package:ithinkwash/core/services/conection_service.dart';
import 'package:ithinkwash/core/utils/either.dart';
import 'package:ithinkwash/modules/authentication/data/datasource/sesion_remote_data_source.dart';
import 'package:ithinkwash/modules/authentication/domain/repository/sesion_repository.dart';

class SessionRepositoryImpl implements SesionRepository {
  final ConnectivityService _connectivity = ConnectivityService();
  final SessionRemoteDataSource remote;

  SessionRepositoryImpl(this.remote) {
    _connectivity.initialize();
  }

  @override
  Future<Either<Failure, SesionEntity>> createSesion(
      SesionEntity sesion, UserModel user) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final result = await remote.createSesion(sesion);
      if (!result) {
        return const Left(
            ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
      }
      return Right(sesion);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<SesionEntity>>> getAllSesiones(
      DateTime? fechaDesde, DateTime? fechaHasta) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    fechaDesde ??= DateTime.now().subtract(const Duration(days: 7));
    fechaHasta ??= DateTime.now();
    try {
      final sesions = await remote.getAllSesions(fechaDesde, fechaHasta);
      return Right(sesions);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, SesionEntity>> getSesionById(String idSesion) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final sesion = await remote.getSesionById(idSesion);
      if (sesion == null) {
        return const Left(ServerFailure('Sesión no encontrada'));
      }
      return Right(sesion);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<SesionEntity>>> getSesionesByUsuario(
      int idUsuario,
      {DateTime? fechaDesde,
      DateTime? fechaHasta}) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    fechaDesde ??= DateTime.now().subtract(const Duration(days: 7));
    fechaHasta ??= DateTime.now();
    try {
      final sesiones =
          await remote.getSesionesByUsuario(idUsuario, fechaDesde, fechaHasta);
      return Right(sesiones);
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }
}
