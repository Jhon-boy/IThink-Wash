import 'package:ithinkwash/core/entities/sesion_entity.dart';
import 'package:ithinkwash/core/models/user_model.dart';
import 'package:ithinkwash/core/utils/app_util.dart'; 
import 'package:uuid/uuid.dart';

class AuthMapper {
  static SesionEntity toSesionEntity(UserModel user) {
    const Uuid uuid =  Uuid();
    final token = uuid.v4();
    return SesionEntity(
      idUsuario: user.idUsuario!,
      token: token,
      fechaInicio: AppUtils.getFechaActual(),
      fechaExpiracion: AppUtils.getFechaActual().add(const Duration(hours: 1)),
      activo: true,
    );
  }
}
