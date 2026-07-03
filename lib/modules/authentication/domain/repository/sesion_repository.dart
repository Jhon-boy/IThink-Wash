import 'package:dartz/dartz.dart';
import 'package:ithinkwash/core/entities/sesion_entity.dart';
import 'package:ithinkwash/core/models/user_model.dart';
import 'package:ithinkwash/core/utils/either.dart'; 

abstract class SesionRepository {
  Future<Either<Failure, List<SesionEntity>>> getAllSesiones(
      DateTime? fechaDesde, DateTime? fechaHasta);
  Future<Either<Failure, SesionEntity>> getSesionById(String idSesion);
  Future<Either<Failure, List<SesionEntity>>> getSesionesByUsuario(
      int idUsuario,
      {DateTime? fechaDesde,
      DateTime? fechaHasta});
  Future<Either<Failure, SesionEntity>> createSesion(
      SesionEntity sesion, UserModel user); 
}
