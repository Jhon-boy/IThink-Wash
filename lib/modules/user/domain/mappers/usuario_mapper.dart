import 'package:ithinkwash/core/entities/sucursal_entity.dart';
import 'package:ithinkwash/core/entities/usuario_entity.dart';
import 'package:ithinkwash/core/singleton/singleton_app.dart';
import 'package:ithinkwash/core/utils/app_util.dart'; 
class UsuarioMapper {
  static TsegUsuarioEntity fromFormData({
    required int idPersona,
    required String user,
    required String password,
    required bool isTemporal,
    int? idSucursal,
  }) {
    final usuario = SingletonApp.getUser();
    return TsegUsuarioEntity(
      idUsuario: 0,
      idSucursal: idSucursal ?? usuario?.idSucursal ?? 0,
      idPersona: idPersona,
      usuario: user,
      password: AppUtils.generateSha256(password.trim()),
      temporal: isTemporal,
      estado: 'ACTIVO',
      fCreacion: AppUtils.getFechaActual(),
      usuarioCreacion: usuario?.idUsuario?.toString(),
    );
  }

  static Map<String, dynamic> updateSucursalUsuario(SucursalEntity sucursal) {
    final usuario = SingletonApp.getUser();
    return {
      'IDSUCURSAL': sucursal.idSucursal,
      'FMODIFICACION': AppUtils.getFechaActual().toIso8601String(),
      'USERMODIFICACION': usuario!.idUsuario?.toString() ?? '1',
    };
  }
}
