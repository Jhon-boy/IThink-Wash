import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ithinkwash/app/providers/provider.dart';
import 'package:ithinkwash/core/app_constants.dart';
import 'package:ithinkwash/core/entities/orden_detalle_entity.dart';
import 'package:ithinkwash/core/entities/orden_entity.dart';
import 'package:ithinkwash/core/entities/persona_entity.dart';
import 'package:ithinkwash/core/entities/sucursal_entity.dart';
import 'package:ithinkwash/core/theme_app.dart';
import 'package:ithinkwash/core/utils/app_util.dart';
import 'package:ithinkwash/core/utils/snack_helper.dart';
import 'package:ithinkwash/modules/ordenes/data/datasource/orden_remote_datasource.dart';
import 'package:ithinkwash/modules/ordenes/data/repository/orden_repository.dart';
import 'package:ithinkwash/modules/ordenes/domain/repository/orden_repository.dart';
import 'package:ithinkwash/modules/sucursales/data/datasource/sucursal_remote_datasource.dart';
import 'package:ithinkwash/modules/sucursales/data/repository/sucursal_repository.dart';
import 'package:ithinkwash/modules/sucursales/domain/sucursal_repository.dart';
import 'package:ithinkwash/modules/user/data/datasource/persona_data_source.dart';
import 'package:ithinkwash/modules/user/data/datasource/usuario_data_source.dart';
import 'package:ithinkwash/modules/user/data/repository/persona_repository_impl.dart';
import 'package:ithinkwash/modules/user/data/repository/usuario_repository_impl.dart';
import 'package:ithinkwash/modules/user/domain/repository/persona_repository.dart';
import 'package:ithinkwash/modules/user/domain/repository/usuario_repository.dart';
import 'package:ithinkwash/shared/baseApp/pantalla_base.dart';
import 'package:ithinkwash/shared/enums/estados_orden.dart';
import 'package:ithinkwash/shared/widgets/custom_buttom.dart';
import 'package:url_launcher/url_launcher.dart';

class OrdenDetallePage extends ConsumerStatefulWidget {
  final TordOrdenEntity orden;

  const OrdenDetallePage({super.key, required this.orden});

  @override
  ConsumerState<OrdenDetallePage> createState() => _OrdenDetallePageState();
}

class _OrdenDetallePageState extends ConsumerState<OrdenDetallePage> {
  late final OrdenRepository _ordenRepository;
  late final PersonasRepository _personaRepo;
  late final UsuariosRepository _usuarioRepo;
  late final SucursalRepository _sucursalRepo;

  List<TordOrdenDetalleEntity> _detalles = [];
  PersonaEntity? _cliente;
  PersonaEntity? _empleadoPersona;
  SucursalEntity? _sucursal;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final r = ref;
    _ordenRepository = OrdenRemoteRepository(OrdenRemoteDataSource(ref: r));
    _personaRepo = PersonaRepositoryImpl(PersonasRemoteDataSource(ref: r));
    _usuarioRepo = UsuariosRepositoryImpl(UsuariosRemoteDataSource(ref: r));
    _sucursalRepo = SucursalRemoteRepository(SucursalRemoteDataSource(ref: r));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatos();
    });
  }

  Future<void> _cargarDatos() async {
    final appState = ref.watch(appStateProvider);
    setState(() {
      _isLoading = true;
    });
    appState.setLoading(true);

    try {
      final orden = widget.orden;

      final detallesResult =
          await _ordenRepository.getDetallesByOrdenEntity(orden.idOrden!);
      PersonaEntity? cliente;
      final clienteResult = await _personaRepo.getPersonaById(orden.idPersona);
      clienteResult.fold((failure) {
        appState.setLoading(false);
        if (!mounted) return;

        SnackHelper.show(
          context,
          message: 'Error al cargar cliente: ${failure.message}',
          isError: true,
        );
      }, (r) => cliente = r);

      PersonaEntity? empPersona;
      final empUserResult = await _usuarioRepo.getUsuarioById(orden.idEmpleado);
      empUserResult.fold((failure) {
        appState.setLoading(false);
        if (!mounted) return;

        SnackHelper.show(
          context,
          message: 'Error al cargar empleado: ${failure.message}',
          isError: true,
        );
      }, (r) async {
        final empPersonaResult = await _personaRepo
            .getPersonaByIdentificacion(r.idPersona.toString());
        empPersonaResult.fold((failure) {
          appState.setLoading(false);
          if (!mounted) return;

          SnackHelper.show(
            context,
            message: 'Error al cargar empleado: ${failure.message}',
            isError: true,
          );
        }, (r) => empPersona = r);
      });

      SucursalEntity? suc;
      final sucResult =
          await _sucursalRepo.getSucursalesbyIdEntity(orden.idSucursal);
      sucResult.fold((failure) {
        appState.setLoading(false);
        if (!mounted) return;

        SnackHelper.show(
          context,
          message: 'Error al cargar sucursal: ${failure.message}',
          isError: true,
        );
      }, (r) => suc = r);

      detallesResult.fold((failure) {
        appState.setLoading(false);
        if (!mounted) return;

        SnackHelper.show(
          context,
          message: 'Error al cargar detalles: ${failure.message}',
          isError: true,
        );
      }, (r) => _detalles = r);

      if (mounted) {
        setState(() {
          _cliente = cliente;
          _empleadoPersona = empPersona;
          _sucursal = suc;
          _isLoading = false;
        });
      }
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
    } finally {
      appState.setLoading(false);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cambiarEstado(String nuevoEstado) async {
    final o = widget.orden;
    final updated = TordOrdenEntity(
      idOrden: o.idOrden,
      idSucursal: o.idSucursal,
      idPersona: o.idPersona,
      idEmpleado: o.idEmpleado,
      fechaRecepcion: o.fechaRecepcion,
      fechaEntregaEstimada: o.fechaEntregaEstimada,
      fechaEntregaReal: nuevoEstado == EstadosOrden.ENTREGADO.code
          ? DateTime.now()
          : o.fechaEntregaReal,
      subtotal: o.subtotal,
      total: o.total,
      totalAbonado: o.totalAbonado,
      saldoPendiente: o.saldoPendiente,
      estado: nuevoEstado,
      comentario: o.comentario,
      fCreacion: o.fCreacion,
      usuarioCreacion: o.usuarioCreacion,
    );
    final result = await _ordenRepository.updateOrdenEntity(updated);
    result.fold((l) => null, (r) {
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Orden $nuevoEstado')));
      }
    });
  }

  Future<void> _contactarWhatsApp() async {
    if (_cliente?.telefono == null || _cliente!.telefono!.isEmpty) return;
    final phone = _cliente!.telefono!.replaceAll(RegExp(r'[^0-9]'), '');
    final msg = Uri.encodeComponent(
        'Hola ${_cliente!.nombres}, tu orden #${widget.orden.idOrden} está lista.');
    final url = 'https://wa.me/$phone?text=$msg';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      title: 'Orden #${widget.orden.idOrden}',
      body: _isLoading
          ? ThemeApp.buildShimmerLoading()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _buildTicket(),
                const SizedBox(height: 20),
                _buildAcciones(),
              ]),
            ),
    );
  }

  Widget _buildTicket() {
    final o = widget.orden;
    final estado = EstadosOrden.fromCode(o.estado);
    final now = AppUtils.formatDate(DateTime.now());
    final empNombre = _empleadoPersona != null
        ? '${_empleadoPersona!.nombres} ${_empleadoPersona!.apellidos}'
        : 'ID: ${o.idEmpleado}';
    final sucNombre = _sucursal?.nombre ?? 'Sucursal #${o.idSucursal}';
    final clienteNombre = _cliente != null
        ? '${_cliente!.nombres} ${_cliente!.apellidos}'
        : 'ID: ${o.idPersona}';
    final clienteIdentificacion = _cliente?.identificacion ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(children: [
              const Icon(Icons.water_drop, size: 28, color: ThemeApp.primary),
              Text(AppConstants.APP_NAME,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: ThemeApp.fontFamily)),
              Text('SISTEMA DE LAVANDERÍA',
                  style: TextStyle(
                      fontSize: 8,
                      letterSpacing: 2,
                      color: ThemeApp.textSecondary,
                      fontFamily: ThemeApp.fontFamily)),
            ]),
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(o.numeroOrden ?? 'FACTURA #${o.idOrden}',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: ThemeApp.fontFamily)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppUtils.getColorEstado(o.estado).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(estado.label,
                    style: TextStyle(
                        fontSize: 10,
                        color: AppUtils.getColorEstado(o.estado),
                        fontWeight: FontWeight.w600,
                        fontFamily: ThemeApp.fontFamily)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Factura #${o.idOrden}',
                style: const TextStyle(
                    fontSize: 10,
                    color: ThemeApp.textSecondary,
                    fontFamily: ThemeApp.fontFamily)),
            const SizedBox(height: 2),
            Row(children: [
              const Text('Cliente: ',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontFamily: ThemeApp.fontFamily)),
              Expanded(
                  child: Text(clienteNombre,
                      style: const TextStyle(
                          fontSize: 12, fontFamily: ThemeApp.fontFamily))),
            ]),
            if (clienteIdentificacion.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Row(children: [
                  const Text('ID: ',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: ThemeApp.textSecondary,
                          fontFamily: ThemeApp.fontFamily)),
                  Text(clienteIdentificacion,
                      style: const TextStyle(
                          fontSize: 11,
                          color: ThemeApp.textSecondary,
                          fontFamily: ThemeApp.fontFamily)),
                ]),
              ),
          ]),
          if (_cliente?.telefono != null && _cliente!.telefono!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(children: [
                const Text('Contacto: ',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        fontFamily: ThemeApp.fontFamily)),
                Text(_cliente!.telefono!,
                    style: const TextStyle(
                        fontSize: 12, fontFamily: ThemeApp.fontFamily)),
              ]),
            ),
          const Divider(height: 16),
          _ticketRow('Fecha Recepción', AppUtils.formatDate(o.fechaRecepcion)),
          if (o.fechaEntregaEstimada != null)
            _ticketRow('Fecha Est. Entrega',
                AppUtils.formatDate(o.fechaEntregaEstimada!)),
          if (o.fechaEntregaReal != null)
            _ticketRow(
                'Fecha Entrega Real', AppUtils.formatDate(o.fechaEntregaReal!)),
          const Divider(height: 16),
          _ticketRow('Subtotal (Abonado)',
              '\$${(o.totalAbonado ?? 0).toStringAsFixed(2)}'),
          _ticketRow('Total a Pagar', '\$${(o.total ?? 0).toStringAsFixed(2)}',
              bold: true),
          if (o.saldoPendiente != null && o.saldoPendiente! > 0)
            _ticketRow(
                'Saldo Pendiente', '\$${o.saldoPendiente!.toStringAsFixed(2)}',
                color: ThemeApp.error),
          const Divider(height: 12),
          const Text('Detalles',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: ThemeApp.fontFamily)),
          const SizedBox(height: 4),
          ..._detalles.map((d) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(children: [
                  Expanded(
                      child: Text(d.descripcionPrenda ?? 'Prenda',
                          style: const TextStyle(
                              fontSize: 11, fontFamily: ThemeApp.fontFamily))),
                  if (d.cantidad != null)
                    Text('x${d.cantidad!.toStringAsFixed(0)}  ',
                        style: const TextStyle(
                            fontSize: 11,
                            color: ThemeApp.textSecondary,
                            fontFamily: ThemeApp.fontFamily)),
                  if (d.subtotal != null)
                    Text('\$${d.subtotal!.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            fontFamily: ThemeApp.fontFamily)),
                ]),
              )),
          const Divider(height: 16),
          Center(
            child: Text('$now  •  $empNombre  •  $sucNombre',
                style: const TextStyle(
                    fontSize: 9,
                    color: ThemeApp.textSecondary,
                    fontFamily: ThemeApp.fontFamily)),
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomButton(
                  width: MediaQuery.of(context).size.width * 0.35,
                  text: 'WhastApp',
                  onPressed: _contactarWhatsApp,
                  colorButton: ThemeApp.success,
                  colorText: ThemeApp.white,
                  icon: FontAwesomeIcons.whatsapp),
              CustomButton(
                  width: MediaQuery.of(context).size.width * 0.35,
                  text: 'Imprimir',
                  onPressed: () {
                    // Implementar la funcionalidad de impresión aquí
                  },
                  colorButton: ThemeApp.background,
                  colorText: ThemeApp.textPrimary,
                  icon: FontAwesomeIcons.print),
            ],
          )
        ],
      ),
    );
  }

  Widget _ticketRow(String label, String value,
      {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: ThemeApp.textSecondary,
                  fontFamily: ThemeApp.fontFamily)),
          Text(value,
              style: TextStyle(
                fontSize: 11,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                color: color ?? ThemeApp.textPrimary,
                fontFamily: ThemeApp.fontFamily,
              )),
        ],
      ),
    );
  }

  Widget _buildAcciones() {
    final o = widget.orden;
    final estado = EstadosOrden.fromCode(o.estado);

    return Column(children: [
      if (!estado.esTerminal) ...[
        CustomButton(
          text: 'Avanzar a ${estado.siguiente.label}',
          colorButton: ThemeApp.primary,
          colorText: ThemeApp.white,
          icon: FontAwesomeIcons.arrowRight,
          onPressed: () => _cambiarEstado(estado.siguiente.code),
        ),
        const SizedBox(height: 10),
      ],
      CustomButton(
        text: 'Regresar',
        colorButton: ThemeApp.background,
        colorText: ThemeApp.textPrimary,
        icon: Icons.arrow_back,
        onPressed: () => Navigator.pop(context),
      ),
    ]);
  }
}
