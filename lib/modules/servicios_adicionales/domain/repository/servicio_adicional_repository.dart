import 'package:dartz/dartz.dart';
import 'package:ithinkwash/core/entities/servicio_adicional_entity.dart';
import 'package:ithinkwash/core/utils/either.dart';

abstract class ServicioAdicionalRepository {
  Future<Either<Failure, List<TserServicioAdicionalEntity>>> getServiciosAdicionalesEntity();
  Future<Either<Failure, TserServicioAdicionalEntity>> getServicioAdicionalByIdEntity(int id);
  Future<Either<Failure, TserServicioAdicionalEntity>> registerServicioAdicionalEntity(TserServicioAdicionalEntity data);
  Future<Either<Failure, TserServicioAdicionalEntity>> updateServicioAdicionalEntity(TserServicioAdicionalEntity data);
  Future<Either<Failure, bool>> deleteServicioAdicionalEntity(int id, String user);
}
