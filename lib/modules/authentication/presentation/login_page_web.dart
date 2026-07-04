import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/core/app_constants.dart';
import 'package:ithinkwash/core/models/user_model.dart';
import 'package:ithinkwash/core/services/shared_preferences_service.dart';
import 'package:ithinkwash/core/singleton/singleton_app.dart';
import 'package:ithinkwash/core/theme_app.dart';
import 'package:ithinkwash/core/utils/app_util.dart';
import 'package:ithinkwash/core/utils/snack_helper.dart';
import 'package:ithinkwash/modules/authentication/data/datasource/auth_remote_data_source.dart';
import 'package:ithinkwash/modules/authentication/data/repository/auth_repository_impl.dart';
import 'package:ithinkwash/modules/authentication/domain/providers/user_provider.dart';
import 'package:ithinkwash/modules/authentication/presentation/splash_page.dart';
import 'package:ithinkwash/modules/sucursales/data/datasource/sucursal_remote_datasource.dart';
import 'package:ithinkwash/shared/widgets/custom_buttom.dart';
import 'package:ithinkwash/shared/widgets/dialog_widget.dart';
import 'package:ithinkwash/modules/authentication/domain/repository/auth_repository.dart';

class LoginPageWeb extends ConsumerStatefulWidget {
  const LoginPageWeb({super.key});

  @override
  ConsumerState<LoginPageWeb> createState() => _LoginPageWebState();
}

class _LoginPageWebState extends ConsumerState<LoginPageWeb> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(ref: ref),
    );
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final usuario = _usuarioController.text.trim();
    final password = _passwordController.text.trim();

    if (usuario.isEmpty || password.isEmpty) {
      SnackHelper.show(context,
          message: "Complete todos los campos", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authRepository.login(usuario, password);

    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        DialogHelper.error(context,
            message: failure.message, onConfirmed: () {});
      },
      (user) async {
        await _loadUserDataAndNavigate(user);
      },
    );
  }

  Future<void> _loadUserDataAndNavigate(UserModel user) async {
    try {
      final rolesResult =
          await _authRepository.getRolesByUser(user.idUsuario!);
      final roles = rolesResult.getOrElse(() => []);
      ref.read(userProvider.notifier).setUser(user, roles: roles);

      String? sucursalNombre;
      try {
        if (user.idSucursal != null) {
          final sucursalDataSource = SucursalRemoteDataSource(ref: ref);
          final sucursalEntity =
              await sucursalDataSource.getSucursalById(user.idSucursal!);
          sucursalNombre = sucursalEntity?.nombre;
        }
      } catch (e) {
        debugPrint('Error obteniendo sucursal del usuario: $e');
      }

      SingletonApp.setUserData(
        user: user,
        roles: roles,
        rolPrincipal: roles.isNotEmpty ? roles.first.codigo : null,
        sucursalNombre: sucursalNombre,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplashPage()),
      );
      SnackHelper.show(context, message: 'Bienvenido ${user.nombres}!');
    } catch (e) {
      debugPrint("Error obteniendo roles: $e");
      DialogHelper.error(
        context,
        message: "Error al cargar la información del usuario",
        onConfirmed: () {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      backgroundColor: ThemeApp.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: isWide
              ? _buildWideLayout()
              : _buildCompactLayout(),
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildBrandingSection()),
        const SizedBox(width: 60),
        SizedBox(width: 400, child: _buildLoginForm()),
      ],
    );
  }

  Widget _buildCompactLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBrandingSection(),
        const SizedBox(height: 40),
        _buildLoginForm(),
      ],
    );
  }

  Widget _buildBrandingSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.water_drop, size: 80, color: ThemeApp.primary),
        const SizedBox(height: 16),
        Text(
          AppConstants.APP_NAME,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: ThemeApp.primary,
            fontFamily: ThemeApp.fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Sistema de Gestión de Lavandería",
          style: TextStyle(
            fontSize: 16,
            color: ThemeApp.textSecondary,
            fontFamily: ThemeApp.fontFamily,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Iniciar Sesión",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: ThemeApp.textPrimary,
                fontFamily: ThemeApp.fontFamily,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _usuarioController,
              decoration: ThemeApp.inputDecoration(
                "Usuario",
                "Ingrese su usuario",
                Icons.person_outline,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: ThemeApp.inputDecoration(
                "Contraseña",
                "Ingrese su contraseña",
                Icons.lock_outline,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: ThemeApp.primary.withOpacity(0.5),
                  ),
                  onPressed: () =>
                      setState(() => _obscureText = !_obscureText),
                ),
              ),
              onSubmitted: (_) => _iniciarSesion(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: _isLoading ? "Ingresando..." : "Ingresar",
                icon: _isLoading ? Icons.hourglass_empty : Icons.login,
                colorButton: ThemeApp.primary,
                onPressed: _isLoading
                    ? () {}
                    : () => _iniciarSesion(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
