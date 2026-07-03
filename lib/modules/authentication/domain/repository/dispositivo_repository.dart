import 'package:dartz/dartz.dart';
import 'package:ithinkwash/core/entities/dispositivo_entity.dart';
import 'package:ithinkwash/core/models/user_model.dart';
import 'package:ithinkwash/core/utils/either.dart';
abstract class DispositivoRepository {
  Future<Either<Failure, List<DispositivoEntity>>> getAllDispositivos(
      {DateTime? fechaDesde, DateTime? fechaHasta});
  Future<Either<Failure, DispositivoEntity>> getDispositivoById(
      int idDispositivo);
  Future<Either<Failure, List<DispositivoEntity>>> getDispositivosByUsuario(
      int idUsuario,
      {DateTime? fechaDesde,
      DateTime? fechaHasta});
  Future<Either<Failure, DispositivoEntity>> createDispositivo(
      DispositivoEntity dispositivo, UserModel user);
  Future<Either<Failure, DispositivoEntity>> updateDispositivo(
      int idDispositivo, Map<String, dynamic> data);
  Future<Either<Failure, bool>> deleteDispositivo(int idDispositivo);
}
