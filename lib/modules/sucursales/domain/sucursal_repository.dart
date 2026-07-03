import 'package:dartz/dartz.dart';
import 'package:ithinkwash/core/entities/sucursal_entity.dart';
import 'package:ithinkwash/core/utils/either.dart';

abstract class SucursalRepository {
  Future<Either<Failure, List<SucursalEntity>>> getSucursalesEntity();
    Future<Either<Failure, List<SucursalEntity>>> getSucursalesEntityFree();
    Future<Either<Failure, SucursalEntity>> getSucursalesbyIdEntity(int idSucursal);
  Future<Either<Failure, SucursalEntity>> registerSucursalEntity(
      SucursalEntity data);
  Future<Either<Failure, bool>> deleteSucursalEntity(int idSucursal, String user);
    Future<Either<Failure, SucursalEntity>> updateSucursalEntity(
      SucursalEntity data);
}
