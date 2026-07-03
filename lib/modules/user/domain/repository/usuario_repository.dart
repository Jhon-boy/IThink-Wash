import 'package:dartz/dartz.dart';
import 'package:ithinkwash/core/entities/usuario_entity.dart';
import 'package:ithinkwash/core/utils/either.dart'; 

abstract class UsuariosRepository {
  /// Obtener todos los usuarios de una sucursal
  Future<Either<Failure, List<TsegUsuarioEntity>>> getUsuariosBySucursal(
    int idSucursal, {
    DateTime? fechaDesde,
    DateTime? fechaHasta,
  });

  /// Obtener usuario por ID
  Future<Either<Failure, TsegUsuarioEntity>> getUsuarioById(int idUsuario);

  /// Obtener usuario por identificación de persona
  Future<Either<Failure, TsegUsuarioEntity>> getUsuarioByIdentificacion(
      String identificacion);

  /// Crear un nuevo usuario
  Future<Either<Failure, TsegUsuarioEntity>> createUsuario(
    TsegUsuarioEntity usuario,
  );

  /// Actualizar usuario (sin tocar identificación ni password)
  Future<Either<Failure, TsegUsuarioEntity>> updateUsuario(
    int idUsuario,
    Map<String, dynamic> data,
  );

  /// Cambiar contraseña de usuario
  Future<Either<Failure, bool>> changePassword(
    int idUsuario,
    String oldPassword,
    String newPassword,
  );

  /// Resetear contraseña (admin)
  Future<Either<Failure, bool>> resetPassword(
    int idUsuario,
    String newPassword,
  );

  /// Activar/Desactivar usuario
  Future<Either<Failure, TsegUsuarioEntity>> toggleEstadoUsuario(
    int idUsuario, {
    bool activo = true,
  });
}
