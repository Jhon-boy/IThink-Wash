import 'package:ithinkwash/core/entities/persona_entity.dart';
import 'package:ithinkwash/core/models/user_model.dart';
import 'package:ithinkwash/core/singleton/singleton_app.dart';
import 'package:ithinkwash/core/utils/app_util.dart';
import 'package:ithinkwash/shared/enums/estados_general.dart';

class PersonaMapper {
  static PersonaEntity fromFormData({
    required String identificacion,
    required String nombres,
    required String apellidos,
    DateTime? fechaNacimiento,
    String? genero,
    String? correo,
    String? telefono,
    String? direccion,
    String? tipoIdentificacion,
    String? estado,
  }) {
    return PersonaEntity(
      identificacion: identificacion.trim(),
      nombres: nombres.trim(),
      apellidos: apellidos.trim(),
      fechaNacimiento: fechaNacimiento,
      genero: AppUtils.getGenero(genero!),
      correo: correo?.trim().isNotEmpty == true ? correo!.trim() : null,
      telefono: telefono?.trim().isNotEmpty == true ? telefono!.trim() : null,
      direccion:
          direccion?.trim().isNotEmpty == true ? direccion!.trim() : null,
      tipoIdentificacion: tipoIdentificacion,
      estado: estado,
      fCreacion: AppUtils.getFechaActual(),
    );
  }

  /// Convierte los datos del formulario a un Map para actualización en BD
  /// Incluye campos de auditoría (FMODIFICACION, USERMODIFICACION)
  static Map<String, dynamic> toUpdateMap({
    required String nombres,
    required String apellidos,
    DateTime? fechaNacimiento,
    String? genero,
    String? correo,
    String? telefono,
    String? direccion,
    String? tipoIdentificacion,
    String? estado,
    required int userModificacion,
  }) {
    return {
      'NOMBRES': nombres.trim(),
      'APELLIDOS': apellidos.trim(),
      'FNACIMIENTO': fechaNacimiento?.toIso8601String(),
      'GENERO': AppUtils.getGenero(genero ?? 'No especificado'),
      'CORREO': correo?.trim().isNotEmpty == true ? correo!.trim() : null,
      'TELEFONO': telefono?.trim().isNotEmpty == true ? telefono!.trim() : null,
      'DIRECCION':
          direccion?.trim().isNotEmpty == true ? direccion!.trim() : null,
      'TIPOIDENTIFICACION': tipoIdentificacion,
      'ESTADO': estado ?? EstadosGeneral.ACTIVO.state,
      'FMODIFICACION': AppUtils.getFechaActual().toIso8601String(),
      'USERMODIFICACION': userModificacion.toString(),
    };
  }

  static Map<String, dynamic> deletePersona(UserModel user) {
    final usuario = SingletonApp.getUser();
    return {
      'ESTADO': EstadosGeneral.INACTIVO.state,
      'FMODIFICACION': AppUtils.getFechaActual().toIso8601String(),
      'USERMODIFICACION': usuario!.idUsuario?.toString(),
    };
  }
}
