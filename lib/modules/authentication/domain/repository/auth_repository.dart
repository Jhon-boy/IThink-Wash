import 'package:dartz/dartz.dart';
import 'package:ithinkwash/core/entities/dispositivo_entity.dart';
import 'package:ithinkwash/core/entities/rol_entity.dart';
import 'package:ithinkwash/core/models/deviceInfo_model.dart';
import 'package:ithinkwash/core/models/user_model.dart';
import 'package:ithinkwash/core/utils/either.dart'; 

abstract class AuthRepository {
  Future<Either<Failure, UserModel>> login(String email, String password);
  Future<Either<Failure, UserModel>> isTrustedDevice(
      DeviceInfoModel deviceInfo);
  Future<Either<Failure, DispositivoEntity>> getDeviceByIdDispositivo(
      String idDispositivo);
  Future<Either<Failure, bool>> registerTrustedDevice(
      UserModel entity, DeviceInfoModel deviceInfo);
  Future<Either<Failure, bool>> removeTrustedDevice(String imei);
  Future<Either<Failure, List<RolEntity>>> getRolesByUser(int idUsuario);
}
