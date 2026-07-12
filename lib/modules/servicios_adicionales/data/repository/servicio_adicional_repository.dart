import 'package:dartz/dartz.dart';
import 'package:ithinkwash/core/entities/servicio_adicional_entity.dart';
import 'package:ithinkwash/core/services/conection_service.dart';
import 'package:ithinkwash/core/utils/either.dart';
import 'package:ithinkwash/modules/servicios_adicionales/data/datasource/servicio_adicional_remote_datasource.dart';
import 'package:ithinkwash/modules/servicios_adicionales/domain/repository/servicio_adicional_repository.dart';

class ServicioAdicionalRemoteRepository implements ServicioAdicionalRepository {
  final ServicioAdicionalRemoteDataSource remote;
  final ConnectivityService _connectivity = ConnectivityService();

  ServicioAdicionalRemoteRepository(this.remote) {
    _connectivity.initialize();
  }

  @override
  Future<Either<Failure, List<TserServicioAdicionalEntity>>> getServiciosAdicionalesEntity() async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) return const Left(NetworkFailure('No hay conexión a internet'));
    try {
      final result = await remote.getServiciosAdicionales();
      return Right(result);
    } catch (_) {
      return const Left(ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, TserServicioAdicionalEntity>> getServicioAdicionalByIdEntity(int id) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) return const Left(NetworkFailure('No hay conexión a internet'));
    try {
      final result = await remote.getServicioAdicionalById(id);
      if (result != null) return Right(result);
      return Left(NotFoundFailure('No se encontró el servicio con ID: $id'));
    } catch (_) {
      return const Left(ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, TserServicioAdicionalEntity>> registerServicioAdicionalEntity(TserServicioAdicionalEntity data) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) return const Left(NetworkFailure('No hay conexión a internet'));
    try {
      final result = await remote.createServicioAdicional(data);
      return Right(result);
    } catch (_) {
      return const Left(ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, TserServicioAdicionalEntity>> updateServicioAdicionalEntity(TserServicioAdicionalEntity data) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) return const Left(NetworkFailure('No hay conexión a internet'));
    try {
      final result = await remote.updateServicioAdicional(data);
      return Right(result);
    } catch (_) {
      return const Left(ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteServicioAdicionalEntity(int id, String user) async {
    final isConnected = await _connectivity.checkConnection();
    if (!isConnected) return const Left(NetworkFailure('No hay conexión a internet'));
    try {
      final result = await remote.deleteServicioAdicional(id, user);
      return Right(result);
    } catch (_) {
      return const Left(ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }
}
