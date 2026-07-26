import 'package:dartz/dartz.dart';
import 'package:ithinkwash/core/entities/orden_entity.dart';
import 'package:ithinkwash/core/entities/orden_detalle_entity.dart';
import 'package:ithinkwash/core/entities/orden_detalle_adicional_entity.dart';
import 'package:ithinkwash/core/entities/pago_entity.dart';
import 'package:ithinkwash/core/services/conection_service.dart';
import 'package:ithinkwash/core/utils/either.dart';
import 'package:ithinkwash/modules/ordenes/data/datasource/orden_remote_datasource.dart';
import 'package:ithinkwash/modules/ordenes/domain/repository/orden_repository.dart';

class OrdenRemoteRepository implements OrdenRepository {
  final OrdenRemoteDataSource remote;
  final ConnectivityService _connectivity = ConnectivityService();

  OrdenRemoteRepository(this.remote) {
    _connectivity.initialize();
  }

  @override
  Future<Either<Failure, List<TordOrdenEntity>>> getOrdenesEntity() async {
    if (!await _connectivity.checkConnection()) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      return Right(await remote.getOrdenes());
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<TordOrdenEntity>>> getOrdenesBySucursalEntity(int idSucursal) async {
    if (!await _connectivity.checkConnection()) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      return Right(await remote.getOrdenesBySucursal(idSucursal));
    } catch (_) {
      return const Left(ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<TordOrdenEntity>>> getOrdenesByFechaRangeEntity(int idSucursal, DateTime desde, DateTime hasta) async {
    if (!await _connectivity.checkConnection()) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      return Right(await remote.getOrdenesBySucursalAndFecha(idSucursal, desde, hasta));
    } catch (_) {
      return const Left(ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, TordOrdenEntity>> getOrdenByIdEntity(
      int idOrden) async {
    if (!await _connectivity.checkConnection()) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      final result = await remote.getOrdenById(idOrden);
      if (result != null) return Right(result);
      return Left(NotFoundFailure('No se encontró la orden con ID: $idOrden'));
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, TordOrdenEntity>> registerOrdenEntity(
      TordOrdenEntity data) async {
    if (!await _connectivity.checkConnection()) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      return Right(await remote.createOrden(data));
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, TordOrdenEntity>> updateOrdenEntity(
      TordOrdenEntity data) async {
    if (!await _connectivity.checkConnection()) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      return Right(await remote.updateOrden(data));
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteOrdenEntity(
      int idOrden, String user) async {
    if (!await _connectivity.checkConnection()) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      return Right(await remote.deleteOrden(idOrden, user));
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<TordOrdenDetalleEntity>>>
      getDetallesByOrdenEntity(int idOrden) async {
    if (!await _connectivity.checkConnection()) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      return Right(await remote.getDetallesByOrden(idOrden));
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, TordOrdenDetalleEntity>> registerDetalleEntity(
      TordOrdenDetalleEntity data) async {
    if (!await _connectivity.checkConnection()) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      return Right(await remote.createDetalle(data));
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteDetalleEntity(int idDetalle) async {
    if (!await _connectivity.checkConnection()) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      return Right(await remote.deleteDetalle(idDetalle));
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<TordOrdenDetalleAdicionalEntity>>>
      getAdicionalesByDetalleEntity(int idDetalle) async {
    if (!await _connectivity.checkConnection()) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      return Right(await remote.getAdicionalesByDetalle(idDetalle));
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, TordOrdenDetalleAdicionalEntity>>
      registerAdicionalEntity(TordOrdenDetalleAdicionalEntity data) async {
    if (!await _connectivity.checkConnection()) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      return Right(await remote.createAdicional(data));
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, List<TordPagoEntity>>> getPagosByOrdenEntity(
      int idOrden) async {
    if (!await _connectivity.checkConnection()) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      return Right(await remote.getPagosByOrden(idOrden));
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, TordPagoEntity>> registerPagoEntity(
      TordPagoEntity data) async {
    if (!await _connectivity.checkConnection()) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      return Right(await remote.createPago(data));
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }

  @override
  Future<Either<Failure, bool>> deletePagoEntity(int idPago) async {
    if (!await _connectivity.checkConnection()) {
      return const Left(NetworkFailure('No hay conexión a internet'));
    }
    try {
      return Right(await remote.deletePago(idPago));
    } catch (_) {
      return const Left(
          ServerFailure('Ha ocurrido un error, inténtalo más tarde'));
    }
  }
}
