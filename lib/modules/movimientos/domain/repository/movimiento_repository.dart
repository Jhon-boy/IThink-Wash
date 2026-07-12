import 'package:dartz/dartz.dart';
import 'package:ithinkwash/core/entities/movimiento_entity.dart';
import 'package:ithinkwash/core/utils/either.dart';

abstract class MovimientoRepository {
  Future<Either<Failure, List<TfinMovimientoEntity>>> getMovimientosEntity();
  Future<Either<Failure, TfinMovimientoEntity>> getMovimientoByIdEntity(int idMovimiento);
  Future<Either<Failure, TfinMovimientoEntity>> registerMovimientoEntity(TfinMovimientoEntity data);
  Future<Either<Failure, TfinMovimientoEntity>> updateMovimientoEntity(TfinMovimientoEntity data);
  Future<Either<Failure, bool>> deleteMovimientoEntity(int idMovimiento, String user);
}
