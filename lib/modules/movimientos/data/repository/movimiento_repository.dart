import 'package:dartz/dartz.dart';
import 'package:ithinkwash/core/entities/movimiento_entity.dart';
import 'package:ithinkwash/core/services/conection_service.dart';
import 'package:ithinkwash/core/utils/either.dart';
import 'package:ithinkwash/modules/movimientos/data/datasource/movimiento_remote_datasource.dart';
import 'package:ithinkwash/modules/movimientos/domain/repository/movimiento_repository.dart';

class MovimientoRemoteRepository implements MovimientoRepository {
  final MovimientoRemoteDataSource remote;
  final ConnectivityService _connectivity = ConnectivityService();

  MovimientoRemoteRepository(this.remote) {
    _connectivity.initialize();
  }

  @override
  Future<Either<Failure, List<TfinMovimientoEntity>>> getMovimientosEntity() async {
    if (!await _connectivity.checkConnection()) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      return Right(await remote.getMovimientos());
    } catch (_) {
      return const Left(ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, TfinMovimientoEntity>> getMovimientoByIdEntity(int idMovimiento) async {
    if (!await _connectivity.checkConnection()) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final result = await remote.getMovimientoById(idMovimiento);
      if (result != null) return Right(result);
      return Left(NotFoundFailure('No se encontró el movimiento con ID: $idMovimiento'));
    } catch (_) {
      return const Left(ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, TfinMovimientoEntity>> registerMovimientoEntity(TfinMovimientoEntity data) async {
    if (!await _connectivity.checkConnection()) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      return Right(await remote.createMovimiento(data));
    } catch (_) {
      return const Left(ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, TfinMovimientoEntity>> updateMovimientoEntity(TfinMovimientoEntity data) async {
    if (!await _connectivity.checkConnection()) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      return Right(await remote.updateMovimiento(data));
    } catch (_) {
      return const Left(ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteMovimientoEntity(int idMovimiento, String user) async {
    if (!await _connectivity.checkConnection()) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      return Right(await remote.deleteMovimiento(idMovimiento, user));
    } catch (_) {
      return const Left(ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }
}
