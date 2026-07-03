import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/modules/authentication/domain/repository/user_context.dart';
import 'package:ithinkwash/modules/authentication/domain/providers/user_notifier.dart';
import 'package:ithinkwash/shared/enums/roles.dart';

// NOTIFICADOR PARA LA AUTENTICACION
// ESTADO DE LA AUTENTICACION
// Provider principal
final userProvider = StateNotifierProvider<UserNotifier, UserContext>((ref) {
  return UserNotifier();
});

// Provider para verificar si es admin
final isAdminProvider = Provider<bool>((ref) {
  final userContext = ref.watch(userProvider);
  return userContext.tieneRol(Rol.ADMIN.code);
});

// Provider para verificar si es empleado
final isEmployeeProvider = Provider<bool>((ref) {
  final userContext = ref.watch(userProvider);
  return userContext.tieneRol(Rol.EMPLEADO.code);
});
