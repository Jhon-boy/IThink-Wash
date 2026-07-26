import 'package:dartz/dartz.dart';
import 'package:ithinkwash/core/entities/orden_entity.dart';
import 'package:ithinkwash/core/entities/orden_detalle_entity.dart';
import 'package:ithinkwash/core/entities/orden_detalle_adicional_entity.dart';
import 'package:ithinkwash/core/entities/pago_entity.dart';
import 'package:ithinkwash/core/utils/either.dart';

abstract class OrdenRepository {
  Future<Either<Failure, List<TordOrdenEntity>>> getOrdenesEntity();
  Future<Either<Failure, List<TordOrdenEntity>>> getOrdenesBySucursalEntity(int idSucursal);
  Future<Either<Failure, List<TordOrdenEntity>>> getOrdenesByFechaRangeEntity(int idSucursal, DateTime desde, DateTime hasta);
  Future<Either<Failure, TordOrdenEntity>> getOrdenByIdEntity(int idOrden);
  Future<Either<Failure, TordOrdenEntity>> registerOrdenEntity(TordOrdenEntity data);
  Future<Either<Failure, TordOrdenEntity>> updateOrdenEntity(TordOrdenEntity data);
  Future<Either<Failure, bool>> deleteOrdenEntity(int idOrden, String user);

  Future<Either<Failure, List<TordOrdenDetalleEntity>>> getDetallesByOrdenEntity(int idOrden);
  Future<Either<Failure, TordOrdenDetalleEntity>> registerDetalleEntity(TordOrdenDetalleEntity data);
  Future<Either<Failure, bool>> deleteDetalleEntity(int idDetalle);

  Future<Either<Failure, List<TordOrdenDetalleAdicionalEntity>>> getAdicionalesByDetalleEntity(int idDetalle);
  Future<Either<Failure, TordOrdenDetalleAdicionalEntity>> registerAdicionalEntity(TordOrdenDetalleAdicionalEntity data);

  Future<Either<Failure, List<TordPagoEntity>>> getPagosByOrdenEntity(int idOrden);
  Future<Either<Failure, TordPagoEntity>> registerPagoEntity(TordPagoEntity data);
  Future<Either<Failure, bool>> deletePagoEntity(int idPago);
}
