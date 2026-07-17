// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/app/providers/provider.dart';
import 'package:ithinkwash/core/entities/persona_entity.dart';
import 'package:ithinkwash/core/entities/rol_entity.dart';
import 'package:ithinkwash/core/entities/sucursal_entity.dart';
import 'package:ithinkwash/core/models/empleados_model.dart';
import 'package:ithinkwash/core/theme_app.dart';
import 'package:ithinkwash/core/utils/snack_helper.dart';
import 'package:ithinkwash/modules/sucursales/presentation/widgets/crear_sucursal.dart';
import 'package:ithinkwash/modules/sucursales/presentation/widgets/sucursal_map_widget.dart';
import 'package:ithinkwash/modules/user/data/datasource/persona_data_source.dart';
import 'package:ithinkwash/modules/user/data/datasource/rol_usuario_data_source.dart';
import 'package:ithinkwash/modules/user/data/datasource/usuario_data_source.dart';
import 'package:ithinkwash/modules/user/data/repository/rol_usuario_impl.dart';
import 'package:ithinkwash/modules/user/data/repository/usuario_repository_impl.dart';
import 'package:ithinkwash/modules/user/domain/repository/rol_usuario.dart';
import 'package:ithinkwash/modules/user/domain/repository/usuario_repository.dart';
import 'package:ithinkwash/modules/user/presentation/widget/empleado_card_widget.dart';
import 'package:ithinkwash/shared/baseApp/pantalla_base.dart';
import 'package:ithinkwash/shared/enums/estados_general.dart';
import 'package:ithinkwash/shared/enums/roles.dart';
import 'package:ithinkwash/shared/widgets/custom_buttom.dart';
import 'package:ithinkwash/core/utils/app_util.dart';

class SucursalDetallePage extends ConsumerStatefulWidget {
  final SucursalEntity sucursal;

  const SucursalDetallePage({
    super.key,
    required this.sucursal,
  });

  static Future<void> navigate({
    required BuildContext context,
    required SucursalEntity sucursal,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SucursalDetallePage(sucursal: sucursal),
      ),
    );
  }

  @override
  ConsumerState<SucursalDetallePage> createState() =>
      _SucursalDetallePageState();
}

class _SucursalDetallePageState extends ConsumerState<SucursalDetallePage> {
  late UsuariosRepository _usuariosRepository;
  late PersonasRemoteDataSource _personaDataSource;
  late RolUsuarioRepository _rolUsuarioRepository;

  List<EmpleadoModel> _empleados = [];
  List<RolEntity> _roles = [];
  bool _isLoading = false;
  late SucursalEntity _sucursal;

  @override
  void initState() {
    super.initState();
    _sucursal = widget.sucursal;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _usuariosRepository = UsuariosRepositoryImpl(
        UsuariosRemoteDataSource(ref: ref),
      );
      _personaDataSource = PersonasRemoteDataSource(ref: ref);
      _rolUsuarioRepository = RolUsuarioRepositoryImpl(
        RolUsuarioRemoteDataSource(ref: ref),
      );
      _cargarRoles();
      _cargarDatos();
    });
  }

  Future<void> _editarSucursal() async {
    final sucursalActualizada = await CrearSucursal.show(
      context: context,
      isEdit: true,
      sucursal: _sucursal,
    );

    if (sucursalActualizada != null && mounted) {
      setState(() {
        _sucursal = sucursalActualizada;
      });
      await _cargarDatos();
    }
  }

  Future<void> _cargarRoles() async {
    try {
      final result = await _rolUsuarioRepository.getAllRoles();
      result.fold(
        (failure) {
          debugPrint('Error al cargar roles: ${failure.message}');
        },
        (roles) {
          setState(() {
            _roles = roles.where((rol) {
              final codigoCliente = Rol.CLIENTE.code;
              return rol.codigo.toUpperCase() != codigoCliente;
            }).toList();
          });
        },
      );
    } catch (e) {
      debugPrint('Error al cargar roles: $e');
    }
  }

  Future<void> _cargarDatos() async {
    if (_sucursal.idSucursal == null) return;

    final appState = ref.watch(appStateProvider);
    setState(() {
      _isLoading = true;
    });
    appState.setLoading(true);

    try {
 
      final usuariosResult = await _usuariosRepository
          .getUsuariosBySucursal(_sucursal.idSucursal!);
      usuariosResult.fold(
        (failure) {
          if (mounted) {
            SnackHelper.show(
              context,
              message: 'Error al cargar empleados: ${failure.message}',
              isError: true,
            );
          }
        },
        (usuarios) async {
          final empleados = <EmpleadoModel>[];

          for (final usuario in usuarios) {
            final personaData = await _personaDataSource
                .getPersonaById(usuario.idPersona.toString());
            final persona = personaData ?? PersonaEntity(
              identificacion: '',
              nombres: '',
              apellidos: '',
            );
            final rolesResult =
                await _rolUsuarioRepository.getRolesUsuario(usuario.idUsuario);

            rolesResult.fold(
              (l) => null,
              (roles) {
                empleados.add(EmpleadoModel(
                  usuario: usuario,
                  persona: persona,
                  roles: roles,
                ));
              },
            );
          }

          setState(() {
            _empleados = empleados;
            _isLoading = false;
          });
          appState.setLoading(false);
        },
      );
    } catch (e) {
      appState.setLoading(false);
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        SnackHelper.show(
          context,
          message: 'Error inesperado: $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      onBack: () => Navigator.of(context).pop(),
      title: _sucursal.nombre,
      body: contenido(),
    );
  }

  Widget contenido() {
    if (_isLoading  && _empleados.isEmpty) {
      return ThemeApp.buildShimmerLoading();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          _buildSucursalInfo(),
          const SizedBox(height: 24),
          _buildEmpleadosSection(),
          const SizedBox(height: 24),
          SucursalMapWidget(
            latitud: _sucursal.latitud,
            longitud: _sucursal.longitud,
            sucursalNombre: _sucursal.nombre,
            sucursalContacto: _sucursal.contacto,
            enableSelection: false,
            height: 220,
          ),
        ],
      ),
    );
  }

  Widget _buildSucursalInfo() {
    return Card(
      elevation: 3,
      color: ThemeApp.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _sucursal.isActiva
                      ? ThemeApp.primary
                      : Colors.grey.shade400,
                  child: const Icon(
                    Icons.store,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sucursal.nombre,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
        children: [
          const Divider(),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const Text(
                    'Información General',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ThemeApp.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_sucursal.idSucursal != null)
                    _buildInfoRow(
                      icon: Icons.tag,
                      label: 'Sucursal',
                      value: _sucursal.idSucursal.toString(),
                    ),
                  // Dirección
                  if (_sucursal.direccion != null &&
                      _sucursal.direccion!.isNotEmpty)
                    _buildInfoRow(
                      icon: Icons.location_on,
                      label: 'Dirección',
                      value: _sucursal.direccion!,
                    ),
                  _buildInfoRow(
                    icon: _sucursal.isActiva
                        ? Icons.check_circle
                        : Icons.cancel_rounded,
                    label: 'Estado',
                    value: _sucursal.estado == true ? EstadosGeneral.ACTIVO.state : EstadosGeneral.INACTIVO.state,
                  ),
                  if (_sucursal.fCreacion != null)
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: 'Fecha de Creación',
                      value: AppUtils.formatDate(_sucursal.fCreacion),
                    ),

                  _buildInfoRow(
                    icon: Icons.edit_calendar,
                    label: 'Fecha de Modificación',
                    value: AppUtils.formatDate(_sucursal.fModificacion),
                  ),
                  _buildInfoRow(
                    icon: Icons.person_add,
                    label: 'Usuario de Ingreso',
                    value: _sucursal.usuarioCreacion ?? 'No disponible',
                  ),
                  _buildInfoRow(
                    icon: Icons.edit_document,
                    label: 'Usuario de Modificación',
                    value: _sucursal.usuarioModificacion ?? 'No disponible',
                  ),
                  CustomButton(
                      icon: Icons.edit_document,
                      text: 'Editar Sucursal',
                      onPressed: _editarSucursal)
                ],
              ))
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: ThemeApp.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpleadosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.people,
              size: 24,
              color: ThemeApp.success,
            ),
            const SizedBox(width: 8),
            Text(
              'Empleados (${_empleados.length})',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ThemeApp.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          SizedBox(
            height: 200,
            child: Center(
              child: ThemeApp.buildShimmerLoading(itemCount: 2),
            ),
          )
        else if (_empleados.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 24,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No hay empleados registrados en esta sucursal',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          ..._empleados.map(
            (empleado) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: EmpleadoCardWidget(
                empleado: empleado,
                roles: _roles,
              ),
            ),
          ),
      ],
    );
  }
}
