import 'package:ithinkwash/core/entities/persona_entity.dart';
import 'package:ithinkwash/core/entities/usuario_entity.dart';

class EmpleadoModel {
  final TsegUsuarioEntity? usuario;
  final PersonaEntity persona;
  final List<int> roles;

  EmpleadoModel({
    this.usuario,
    required this.persona,
    required this.roles,
  });
}
