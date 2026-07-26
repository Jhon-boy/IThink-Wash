import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/app/providers/provider.dart';
import 'package:ithinkwash/core/entities/concepto_entity.dart';
import 'package:ithinkwash/core/entities/orden_detalle_entity.dart';
import 'package:ithinkwash/core/entities/orden_detalle_adicional_entity.dart';
import 'package:ithinkwash/core/entities/orden_entity.dart';
import 'package:ithinkwash/core/entities/pago_entity.dart';
import 'package:ithinkwash/core/entities/persona_entity.dart';
import 'package:ithinkwash/core/entities/servicio_adicional_entity.dart';
import 'package:ithinkwash/core/singleton/singleton_app.dart';
import 'package:ithinkwash/core/theme_app.dart';
import 'package:ithinkwash/core/utils/formatters.dart';
import 'package:ithinkwash/core/utils/snack_helper.dart';
import 'package:ithinkwash/modules/conceptos/data/datasource/concepto_remote_datasource.dart';
import 'package:ithinkwash/modules/conceptos/data/repository/concepto_repository.dart';
import 'package:ithinkwash/modules/conceptos/domain/repository/concepto_repository.dart';
import 'package:ithinkwash/modules/ordenes/data/datasource/orden_remote_datasource.dart';
import 'package:ithinkwash/modules/ordenes/data/repository/orden_repository.dart';
import 'package:ithinkwash/modules/ordenes/domain/repository/orden_repository.dart';
import 'package:ithinkwash/modules/ordenes/presentation/orden_detalle_page.dart';
import 'package:ithinkwash/modules/servicios_adicionales/data/datasource/servicio_adicional_remote_datasource.dart';
import 'package:ithinkwash/modules/servicios_adicionales/data/repository/servicio_adicional_repository.dart';
import 'package:ithinkwash/modules/servicios_adicionales/domain/repository/servicio_adicional_repository.dart';
import 'package:ithinkwash/modules/user/data/datasource/persona_data_source.dart';
import 'package:ithinkwash/modules/user/data/repository/persona_repository_impl.dart';
import 'package:ithinkwash/modules/user/domain/repository/persona_repository.dart';
import 'package:ithinkwash/modules/user/presentation/crear_persona_page.dart';
import 'package:ithinkwash/shared/enums/estados_general.dart';
import 'package:ithinkwash/shared/enums/estados_orden.dart';
import 'package:ithinkwash/shared/enums/tipo_pago.dart';
import 'package:ithinkwash/shared/widgets/calendar_widget.dart';
import 'package:ithinkwash/shared/widgets/custom_buttom.dart';
import 'package:ithinkwash/shared/widgets/custom_dropdown.dart';
import 'package:ithinkwash/shared/widgets/dialog_widget.dart';
import 'package:ithinkwash/shared/widgets/input_dialog.dart';

class ServicioSeleccionado {
  TserServicioAdicionalEntity servicio;
  int cantidad;
  double precioAplicado;

  ServicioSeleccionado(
      {required this.servicio, this.cantidad = 1, double? precioAplicado})
      : precioAplicado = precioAplicado ?? servicio.precioBase;

  double get subtotal => cantidad * precioAplicado;
}

class PrendaTemp {
  String descripcion = '';
  TserConceptoEntity? concepto;
  double cantidad = 1;
  double subtotalManual = 0;
  String comentarioPrecio = '';
  bool precioModificado = false;
  List<ServicioSeleccionado> servicios = [];

  double get subtotalServicios =>
      servicios.fold(0.0, (s, sv) => s + sv.subtotal);
  double get subtotalCalculado =>
      (cantidad * (concepto?.precioBase ?? 0)) + subtotalServicios;
  double get subtotal => precioModificado ? subtotalManual : subtotalCalculado;
}

class NuevaOrdenPage extends ConsumerStatefulWidget {
  const NuevaOrdenPage({super.key});

  @override
  ConsumerState<NuevaOrdenPage> createState() => _NuevaOrdenPageState();
}

class _NuevaOrdenPageState extends ConsumerState<NuevaOrdenPage> {
  late final OrdenRepository _ordenRepo;
  late final ConceptoRepository _conceptoRepo;
  late final ServicioAdicionalRepository _servicioRepo;
  late final PersonasRepository _personaRepo;

  int _currentStep = 0;
  PersonaEntity? _cliente;
  List<TserConceptoEntity> _conceptos = [];
  List<TserServicioAdicionalEntity> _servicios = [];
  final List<PrendaTemp> _prendas = [];
  final _comentarioCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _pagoMontoCtrl = TextEditingController();
  final List<TextEditingController> _prendaCtrls = [];
  final List<TextEditingController> _cantCtrls = [];
  final List<TextEditingController> _subtotalCtrls = [];
  final Set<int> _editandoSubtotal = {};
  String _metodoPago = TipoPago.EFECTIVO.state;
  bool _pagoAhora = false;
  bool _guardando = false;
  static const STEP_PRENDAS = 0;
  static const STEP_PAGO = 1;
  static const STEP_CLIENTE = 2;

  @override
  void initState() {
    super.initState();
    final r = ref;
    _ordenRepo = OrdenRemoteRepository(OrdenRemoteDataSource(ref: r));
    _conceptoRepo = ConceptoRemoteRepository(ConceptoRemoteDataSource(ref: r));
    _servicioRepo = ServicioAdicionalRemoteRepository(
        ServicioAdicionalRemoteDataSource(ref: r));
    _personaRepo = PersonaRepositoryImpl(PersonasRemoteDataSource(ref: r));
    _cargarCatalogos();
  }

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    _fechaCtrl.dispose();
    _pagoMontoCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarCatalogos() async {
    final cR = await _conceptoRepo.getConceptosEntity();
    cR.fold(
        (l) => null,
        (r) => _conceptos =
            r.where((c) => c.estado.toUpperCase() == 'ACT').toList());
    final sR = await _servicioRepo.getServiciosAdicionalesEntity();
    sR.fold(
        (l) => null,
        (r) => _servicios =
            r.where((s) => s.estado.toUpperCase() == 'ACT').toList());
    _agregarPrenda();
    if (mounted) setState(() {});
  }

  void _agregarPrenda() => setState(() => _prendas.add(PrendaTemp()));
  void _eliminarPrenda(int i) => setState(
        () => _prendas.removeAt(i),
      );

  double get _subtotalCalculado =>
      _prendas.fold(0.0, (s, p) => s + p.subtotalCalculado);
  double get _subtotal => _prendas.fold(0.0, (s, p) => s + p.subtotal);
  double get _total => _subtotal;

  Future<void> _seleccionarCliente() async {
    final r = await InputDialog.showTextInput(
        context: context,
        title: 'Buscar Cliente',
        label: 'Identificación o teléfono');
    if (r == null || r.isEmpty) return;
    ref.read(appStateProvider.notifier).setLoading(true);
    try {
      List<PersonaEntity> encontradas = [];
      final r1 = await _personaRepo.searchPersonas(telefono: r);
      r1.fold((l) => null, (list) => encontradas = list);
      if (encontradas.isEmpty) {
        final r2 = await _personaRepo.getPersonaByIdentificacion(r);
        r2.fold((l) => null, (p) => encontradas = [p]);
      }
      if (encontradas.isEmpty) {
        if (mounted) {
          DialogHelper.confirm(context,
              message: 'Cliente no encontrado. ¿Crearlo?',
              onConfirm: () {
                CrearPersonaPage.navigate(
                  context: context,
                  identificacion: r,
                  titulo: 'Crear Cliente',
                ).then((nuevaPersona) {
                  if (nuevaPersona != null && mounted) {
                    setState(() => _cliente = nuevaPersona);
                    SnackHelper.show(context,
                        message: 'Cliente: ${_cliente!.nombres} ${_cliente!.apellidos}');
                  }
                });
              },
              onCancel: () {});
        }
        return;
      }
      if (mounted) {
        setState(() => _cliente = encontradas.first);
        SnackHelper.show(context,
            message: 'Cliente: ${_cliente!.nombres} ${_cliente!.apellidos}');
      }
    } catch (_) {
    } finally {
      ref.read(appStateProvider.notifier).setLoading(false);
    }
  }

  String? _validarStep(int step) {
    if (step == STEP_PRENDAS) {
      if (_prendas.isEmpty) return 'Agregue al menos una prenda';
      for (final p in _prendas) {
        if (p.descripcion.trim().isEmpty) {
          return 'Complete la descripción de todas las prendas';
        }
        if (p.concepto == null) {
          return 'Seleccione un concepto para cada prenda';
        }
        if (p.precioModificado && p.comentarioPrecio.trim().isEmpty) {
          return 'Indique el motivo del cambio de subtotal';
        }
      }
    }
    if (step == STEP_PAGO) {
      if (_cliente == null) return 'Seleccione un cliente';
      if (_fechaCtrl.text.trim().isEmpty) {
        return 'Seleccione la fecha de recepción';
      }
      if (_pagoAhora) {
        final monto = double.tryParse(_pagoMontoCtrl.text) ?? 0;
        if (monto <= 0) return 'Indique un monto de pago válido';
        if (monto > _total) return 'El pago no puede ser mayor al total';
      }
    }
    if (step == STEP_CLIENTE) {
      // Solo confirmación, no hay más validación
    }
    return null;
  }

  void _avanzar() {
    final err = _validarStep(_currentStep);
    if (err != null) {
      DialogHelper.info(context, message: err, onConfirmed: () {});
      return;
    }
    if (_currentStep < STEP_CLIENTE) setState(() => _currentStep++);
    if (_currentStep == STEP_CLIENTE) {
      final err = _validarStep(STEP_PAGO);
      if (err != null) {
        DialogHelper.info(context, message: err, onConfirmed: () {});
        setState(() => _currentStep = STEP_PAGO);
        return;
      }
      _guardar();
    }
  }

  void _retroceder() {
    if (_currentStep > STEP_PRENDAS) setState(() => _currentStep--);
  }

  void limpiar() {
    _prendas.clear();
    _cliente = null;
    _currentStep = 0;
    _pagoAhora = false;
    _metodoPago = TipoPago.EFECTIVO.state;
    _comentarioCtrl.clear();
    _fechaCtrl.clear();
    _pagoMontoCtrl.clear();
    _editandoSubtotal.clear();
    for (final c in _prendaCtrls) {
      c.clear();
    }
    for (final c in _cantCtrls) {
      c.clear();
    }
    for (final c in _subtotalCtrls) {
      c.clear();
    }
    _agregarPrenda();
    setState(() {});
  }

  String? _buildComentario() {
    final partes = <String>[];
    if (_comentarioCtrl.text.trim().isNotEmpty) {
      partes.add(_comentarioCtrl.text.trim());
    }
    for (final p in _prendas) {
      if (p.precioModificado && p.comentarioPrecio.trim().isNotEmpty) {
        partes.add('${p.descripcion}: ${p.comentarioPrecio.trim()}');
      }
    }
    return partes.isEmpty ? null : partes.join(' | ');
  }

  Future<void> _guardar() async {
    final err = _validarStep(STEP_PAGO) ?? _validarStep(STEP_CLIENTE);
    if (err != null) {
      DialogHelper.info(context, message: err, onConfirmed: () {});
      return;
    }
    setState(() => _guardando = true);
    ref.read(appStateProvider.notifier).setLoading(true);
    try {
      final user = SingletonApp.getUser();
      final montoPago = double.tryParse(_pagoMontoCtrl.text) ?? 0;
      final orden = TordOrdenEntity(
        idSucursal: user?.idSucursal ?? 1,
        idPersona: _cliente!.idPersona ?? 0,
        idEmpleado: user?.idUsuario ?? 1,
        numeroOrden: null,
        fechaRecepcion: DateTime.tryParse(_fechaCtrl.text) ?? DateTime.now(),
        fechaEntregaEstimada: null,
        subtotal: _subtotal,
        total: _total,
        totalAbonado: _pagoAhora ? montoPago : 0,
        saldoPendiente: _pagoAhora ? _total - montoPago : _total,
        estado: EstadosOrden.INGRESADO.code,
        comentario: _buildComentario(),
      );
      final result = await _ordenRepo.registerOrdenEntity(orden);
      result.fold(
        (l) => DialogHelper.error(context,
            message: 'Error al crear orden: ${l.message}', onConfirmed: () {}),
        (ordenCreada) async {
          for (final p in _prendas) {
            final detalle = TordOrdenDetalleEntity(
              idOrden: ordenCreada.idOrden!,
              idConcepto: p.concepto!.idConcepto!,
              descripcionPrenda: p.descripcion,
              cantidad: p.cantidad,
              precioUnitario: p.concepto!.precioBase,
              subtotal: p.subtotal,
            );
            final dr = await _ordenRepo.registerDetalleEntity(detalle);
            dr.fold((l) => null, (dc) async {
              for (final sv in p.servicios) {
                await _ordenRepo
                    .registerAdicionalEntity(TordOrdenDetalleAdicionalEntity(
                  idOrdenDetalle: dc.idOrdenDetalle,
                  idServicioAdicional: sv.servicio.idServicioAdicional,
                  precioAplicado: sv.precioAplicado,
                ));
              }
            });
          }
          if (_pagoAhora && montoPago > 0) {
            await _ordenRepo.registerPagoEntity(TordPagoEntity(
              idOrden: ordenCreada.idOrden,
              tipoPago: 'PAGO',
              metodoPago: _metodoPago,
              monto: montoPago,
              fechaPago: DateTime.now(),
              estado: 'COMPLETADO',
            ));
          }
          if (mounted) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => OrdenDetallePage(orden: ordenCreada)));
          }
        },
      );
    } catch (e) {
      DialogHelper.error(context,
          message: 'Error inesperado: $e', onConfirmed: () {});
    } finally {
      setState(() => _guardando = false);
      ref.read(appStateProvider.notifier).setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStepper(),
        Expanded(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: _currentStep == STEP_PRENDAS
              ? _stepPrendas()
              : _currentStep == STEP_PAGO
                  ? _stepPago()
                  : _stepCliente(),
        )),
      ],
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
      child: Row(children: [
        _chip(STEP_PRENDAS, 'Prendas'),
        _connector(STEP_PRENDAS),
        _chip(STEP_PAGO, 'Pago'),
        _connector(STEP_PAGO),
        _chip(STEP_CLIENTE, 'Confirmación'),
      ]),
    );
  }

  Widget _chip(int step, String label) {
    final active = _currentStep == step;
    final done = _currentStep > step;
    final color = active
        ? ThemeApp.primary
        : (done ? ThemeApp.success : Colors.grey.shade300);
    return Expanded(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(15)),
          child: Center(
              child: done
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text('${step + 1}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: ThemeApp.fontFamily)))),
      const SizedBox(height: 2),
      Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: ThemeApp.fontFamily)),
    ]));
  }

  Widget _connector(int step) {
    return Container(
        height: 2,
        width: 20,
        color: _currentStep > step ? ThemeApp.success : Colors.grey.shade300);
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        if (_currentStep == 0)
          CustomButton(
            text: 'Limpiar',
            onPressed: limpiar,
            colorButton: ThemeApp.white,
            colorText: ThemeApp.textPrimary,
            icon: Icons.dry_cleaning,
          ),
        const SizedBox(height: 20),
        if (_currentStep > 0)
          CustomButton(
              text: 'Anterior',
              colorButton: ThemeApp.background,
              colorText: ThemeApp.textPrimary,
              icon: Icons.arrow_back,
              onPressed: _retroceder),
        if (_currentStep > 0) const SizedBox(height: 20),
        CustomButton(
          text: _currentStep == STEP_CLIENTE ? 'Guardar Orden' : 'Siguiente',
          colorButton: ThemeApp.primary,
          colorText: ThemeApp.white,
          icon: _currentStep == STEP_CLIENTE
              ? Icons.check_circle
              : Icons.arrow_forward,
          onPressed: _guardando ? () {} : _avanzar,
        )
      ]),
    );
  }

  // ================ STEP 0: PRENDAS ================

  Widget _stepPrendas() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
              color: ThemeApp.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Text('${_prendas.length} prendas',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: ThemeApp.primary,
                  fontFamily: ThemeApp.fontFamily)),
        ),
        const Spacer(),
        TextButton.icon(
            onPressed: _agregarPrenda,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Añadir',
                style: TextStyle(fontFamily: ThemeApp.fontFamily))),
      ]),
      const SizedBox(height: 8),
      ...List.generate(_prendas.length, (i) => _buildPrendaCard(i)),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: ThemeApp.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ThemeApp.primary.withOpacity(0.2))),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Subtotal calculado',
                  style: TextStyle(
                      fontSize: 14,
                      color: ThemeApp.textSecondary,
                      fontFamily: ThemeApp.fontFamily)),
              Text('\$${_subtotalCalculado.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: ThemeApp.textSecondary,
                      fontFamily: ThemeApp.fontFamily)),
            ]),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                  'Total ${_subtotalCalculado != _subtotal ? '(modificado)' : ''}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _subtotalCalculado != _subtotal
                          ? ThemeApp.error
                          : ThemeApp.textPrimary,
                      fontFamily: ThemeApp.fontFamily)),
              Text('\$${_subtotal.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _subtotalCalculado != _subtotal
                          ? ThemeApp.error
                          : ThemeApp.primary,
                      fontFamily: ThemeApp.fontFamily)),
            ]),
          ],
        ),
      ),
      _buildBottomNav(),
    ]);
  }

  Widget _buildPrendaCard(int i) {
    final p = _prendas[i];
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.grey.shade300, width: 1)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                    color: ThemeApp.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)),
                child: Center(
                    child: Text('${i + 1}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: ThemeApp.primary,
                            fontFamily: ThemeApp.fontFamily)))),
            const SizedBox(width: 8),
            const Text('Prenda',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    fontFamily: ThemeApp.fontFamily)),
            const Spacer(),
            IconButton(
                icon: const Icon(Icons.close, size: 20, color: ThemeApp.error),
                onPressed: () => _eliminarPrenda(i)),
          ]),
          const SizedBox(height: 8),
          _buildDescripcion(i),
          const SizedBox(height: 8),
          CustomDropdown<TserConceptoEntity>(
            value: p.concepto,
            label: 'Concepto',
            hint: 'Seleccione',
            items: _conceptos,
            displayText: (c) =>
                '${c.nombre}  (\$${c.precioBase.toStringAsFixed(2)})',
            subtitleText: (c) => c.tipoCobro,
            onChanged: (c) => setState(() {
              p.concepto = c;
              if (!p.precioModificado) p.subtotalManual = p.subtotalCalculado;
            }),
          ),
          const SizedBox(height: 8),
          _buildCantidad(i),
          const SizedBox(height: 10),
          _subtotalField(i),
          if (p.precioModificado) ...[
            const SizedBox(height: 8),
            _comentarioField(p),
          ],
          const SizedBox(height: 10),
          // Servicios
          _serviciosSection(p, i),
        ]),
      ),
    );
  }

  void _asegurarCtrl(int idx) {
    while (_prendaCtrls.length <= idx) {
      _prendaCtrls.add(TextEditingController());
    }
    while (_cantCtrls.length <= idx) {
      _cantCtrls.add(TextEditingController());
    }
    while (_subtotalCtrls.length <= idx) {
      _subtotalCtrls.add(TextEditingController());
    }
  }

  Widget _buildDescripcion(int i) {
    _asegurarCtrl(i);
    final p = _prendas[i];
    _prendaCtrls[i].text = p.descripcion;
    return TextField(
      controller: _prendaCtrls[i],
      decoration: ThemeApp.inputDecoration('Descripción', '', Icons.checkroom,
          helperText: 'Describa la prenda (color, tipo, detalle)'),
      onChanged: (v) => p.descripcion = v,
    );
  }

  Widget _buildCantidad(int i) {
    _asegurarCtrl(i);
    final p = _prendas[i];
    _cantCtrls[i].text = p.cantidad.toInt().toString();
    return TextField(
      controller: _cantCtrls[i],
      keyboardType: TextInputType.number,
      decoration: ThemeApp.inputDecoration('Cantidad', '', Icons.numbers,
          helperText: 'Solo números enteros'),
      onChanged: (v) {
        if (v.isEmpty) {
          _cantCtrls[i].text = '';
          p.cantidad = 0;
        } else {
          p.cantidad = (double.tryParse(v) ?? 0).toDouble();
        }
        if (!p.precioModificado) p.subtotalManual = p.subtotalCalculado;
        setState(() {});
      },
    );
  }

  Widget _subtotalField(int i) {
    _asegurarCtrl(i);
    final p = _prendas[i];
    if (!_editandoSubtotal.contains(i)) {
      _subtotalCtrls[i].text =
          (p.precioModificado ? p.subtotalManual : p.subtotalCalculado)
              .toStringAsFixed(2);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
          color: ThemeApp.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeApp.primary.withOpacity(0.15))),
      child: Column(children: [
        const Text('SUBTOTAL',
            style: TextStyle(
                fontSize: 10,
                color: ThemeApp.textSecondary,
                fontFamily: ThemeApp.fontFamily)),
        const SizedBox(height: 2),
        TextField(
          controller: _subtotalCtrls[i],
          maxLength: 6,
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyTextFormatter()],
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: ThemeApp.primary,
              fontFamily: ThemeApp.fontFamily),
          decoration: ThemeApp.inputDecoration('', '', Icons.attach_money),
          onChanged: (v) {
            _editandoSubtotal.add(i);
            if (v.isEmpty) {
              _subtotalCtrls[i].text = '';
              p.subtotalManual = 0;
            } else if (RegExp(r'^\d*\.?\d{0,2}$').hasMatch(v)) {
              final st = double.tryParse(v);
              if (st != null) {
                p.subtotalManual = st;
                p.precioModificado =
                    (p.subtotalManual - p.subtotalCalculado).abs() > 0.01;
              }
            }
            setState(() {});
          },
          onTapOutside: (_) {
            _editandoSubtotal.remove(i);
          },
          onSubmitted: (_) {
            _editandoSubtotal.remove(i);
          },
        ),
      ]),
    );
  }

  Widget _comentarioField(PrendaTemp p) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: ThemeApp.error.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ThemeApp.error.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.info_outline, size: 14, color: ThemeApp.error),
          const SizedBox(width: 6),
          const Text('Subtotal modificado - Indique la razón',
              style: TextStyle(
                  fontSize: 11,
                  color: ThemeApp.error,
                  fontFamily: ThemeApp.fontFamily)),
        ]),
        const SizedBox(height: 6),
        TextField(
          controller: TextEditingController(text: p.comentarioPrecio),
          decoration: ThemeApp.inputDecoration(
              'Motivo del cambio', '', Icons.description),
          onChanged: (v) => p.comentarioPrecio = v,
        ),
      ]),
    );
  }

  Widget _serviciosSection(PrendaTemp p, int idx) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Servicios Adicionales',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: ThemeApp.fontFamily)),
      const SizedBox(height: 2),
      Text('Cantidad y precio editables',
          style: TextStyle(
              fontSize: 10,
              color: ThemeApp.textSecondary,
              fontFamily: ThemeApp.fontFamily)),
      const SizedBox(height: 6),
      if (_servicios.isNotEmpty)
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _servicios
                  .where((s) =>
                      s.estado.toUpperCase() == EstadosGeneral.ACTIVO.state)
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          avatar: const Icon(Icons.add, size: 14),
                          label: Text(s.nombre,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: ThemeApp.fontFamily)),
                          onPressed: () => setState(() {
                            p.servicios.add(ServicioSeleccionado(servicio: s));
                            if (!p.precioModificado) {
                              p.subtotalManual = p.subtotalCalculado;
                            }
                          }),
                        ),
                      ))
                  .toList(),
            )),
      if (p.servicios.isNotEmpty)
        ...p.servicios
            .asMap()
            .entries
            .map((e) => _servicioRow(p, e.key, e.value)),
    ]);
  }

  Widget _servicioRow(PrendaTemp p, int i, ServicioSeleccionado sv) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Expanded(
            flex: 3,
            child: Text(sv.servicio.nombre,
                style: const TextStyle(
                    fontSize: 12, fontFamily: ThemeApp.fontFamily))),
        SizedBox(
            width: 44,
            child: TextField(
              controller: TextEditingController(text: sv.cantidad.toString()),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12, fontFamily: ThemeApp.fontFamily),
              decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 4)),
              onChanged: (v) => setState(() {
                p.servicios[i].cantidad = int.tryParse(v) ?? 1;
                if (!p.precioModificado) p.subtotalManual = p.subtotalCalculado;
              }),
            )),
        const Text(' x ',
            style: TextStyle(
                fontSize: 11,
                color: ThemeApp.textSecondary,
                fontFamily: ThemeApp.fontFamily)),
        SizedBox(
            width: 60,
            child: TextField(
              controller: TextEditingController(
                  text: sv.precioAplicado.toStringAsFixed(2)),
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              style: const TextStyle(
                  fontSize: 12, fontFamily: ThemeApp.fontFamily),
              decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 4)),
              inputFormatters: [CurrencyTextFormatter()],
              onChanged: (v) => setState(() {
                p.servicios[i].precioAplicado = double.tryParse(v) ?? 0;
                if (!p.precioModificado) p.subtotalManual = p.subtotalCalculado;
              }),
            )),
        SizedBox(
            width: 50,
            child: Text('\$${sv.subtotal.toStringAsFixed(2)}',
                textAlign: TextAlign.end,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: ThemeApp.fontFamily))),
        GestureDetector(
            onTap: () => setState(() {
                  p.servicios.removeAt(i);
                  if (!p.precioModificado) {
                    p.subtotalManual = p.subtotalCalculado;
                  }
                }),
            child: const Icon(Icons.close, size: 14, color: ThemeApp.error)),
      ]),
    );
  }

  // ================ STEP 1: PAGO ================

  Widget _stepPago() {
    final montoPago = double.tryParse(_pagoMontoCtrl.text) ?? 0;
    final totalAbonado = _pagoAhora ? montoPago : 0;
    final saldo = _total - totalAbonado;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 10),
      const Text('Cliente',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: ThemeApp.fontFamily)),
      const SizedBox(height: 10),
      _cliente != null
          ? Card(
              elevation: 1.5,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300)),
              child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(
                                    '${_cliente!.nombres} ${_cliente!.apellidos}',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: ThemeApp.fontFamily)),
                                Text('ID: ${_cliente!.identificacion}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: ThemeApp.textSecondary,
                                        fontFamily: ThemeApp.fontFamily)),
                                if (_cliente!.telefono != null)
                                  Text('Tel: ${_cliente!.telefono}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: ThemeApp.textSecondary,
                                          fontFamily: ThemeApp.fontFamily)),
                              ])),
                          TextButton(
                              onPressed: () => setState(() => _cliente = null),
                              child: const Text('Cambiar')),
                        ]),
                      ])))
          : SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Buscar Cliente',
                colorButton: ThemeApp.primary,
                colorText: ThemeApp.white,
                icon: Icons.person_search,
                onPressed: _seleccionarCliente,
              )),
      const SizedBox(height: 16),
      const Text('Pago',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: ThemeApp.fontFamily)),
      const SizedBox(height: 10),
      Card(
          elevation: 1.5,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300)),
          child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(children: [
                Row(children: [
                  const Text('¿Registrar pago ahora?',
                      style: TextStyle(fontFamily: ThemeApp.fontFamily)),
                  const Spacer(),
                  Switch(
                      value: _pagoAhora,
                      activeColor: ThemeApp.success,
                      onChanged: (v) => setState(() => _pagoAhora = v)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                      child: TextField(
                    controller: _pagoMontoCtrl,
                    inputFormatters: [CurrencyTextFormatter()],
                    keyboardType: TextInputType.number,
                    decoration: ThemeApp.inputDecoration(
                        'Monto', '0.00', Icons.attach_money),
                    onChanged: (_) => setState(() {}),
                  )),
                  const SizedBox(width: 10),
                  Expanded(
                      child: DropdownButtonFormField<String>(
                    value: _metodoPago,
                    decoration:
                        ThemeApp.inputDecoration('Método', '', Icons.payment),
                    items: TipoPago.values
                        .map((t) => DropdownMenuItem(
                            value: t.name,
                            child: Text(t.state,
                                style: const TextStyle(
                                    fontFamily: ThemeApp.fontFamily))))
                        .toList(),
                    onChanged: (v) => setState(() => _metodoPago = v!),
                  )),
                ]),
                const SizedBox(height: 10),
                TextField(
                  controller: _fechaCtrl,
                  decoration: ThemeApp.inputDecoration(
                      'Fecha de recepción', 'AAAA-MM-DD', Icons.calendar_today),
                  readOnly: true,
                  onTap: () async {
                    final date = await CalendarWidget.showDatePickerDialog(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                        withHours: true);
                    if (date != null) {
                      _fechaCtrl.text =
                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}  ${date.hour}: ${date.minute}';
                    }
                  },
                ),
              ]))),
      const SizedBox(height: 16),
      const Text('Resumen de Pagos',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: ThemeApp.fontFamily)),
      const SizedBox(height: 12),
      Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: ThemeApp.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeApp.primary.withOpacity(0.2))),
          child: Column(children: [
            _rRow('Subtotal', '\$${_subtotal.toStringAsFixed(2)}'),
            const Divider(height: 10),
            _rRow('Total', '\$${_total.toStringAsFixed(2)}', bold: false),
            const Divider(height: 10),
            _rRow('Total Abonado', '\$${totalAbonado.toStringAsFixed(2)}'),
            const Divider(height: 10),
            _rRow('Saldo Pendiente', '\$${saldo.toStringAsFixed(2)}',
                bold: true,
                color: saldo > 0 ? ThemeApp.error : ThemeApp.success),
          ])),
      _buildBottomNav(),
    ]);
  }

  Widget _rRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  fontSize: bold ? 15 : 13,
                  fontFamily: ThemeApp.fontFamily,
                  color: color)),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                  fontSize: bold ? 15 : 13,
                  fontFamily: ThemeApp.fontFamily,
                  color: color)),
        ]));
  }

  // ================ STEP 2: CLIENTE ================

  Widget _stepCliente() {
    final montoPago = double.tryParse(_pagoMontoCtrl.text) ?? 0;
    final totalAbonado = _pagoAhora ? montoPago : 0;
    final saldo = _total - totalAbonado;
    final fecha = _fechaCtrl.text.isNotEmpty ? _fechaCtrl.text : 'No definida';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Confirmación de Orden',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: ThemeApp.fontFamily)),
      const SizedBox(height: 14),
      Card(
          elevation: 1.5,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300)),
          child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Resumen de la Operación',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            fontFamily: ThemeApp.fontFamily)),
                    const Divider(height: 16),
                    _resumenRow('Prendas', '${_prendas.length}'),
                    _resumenRow(
                        'Subtotal', '\$${_subtotal.toStringAsFixed(2)}'),
                    const Divider(height: 10),
                    _resumenRow('Total', '\$${_total.toStringAsFixed(2)}',
                        bold: true),
                    const Divider(height: 10),
                    _resumenRow(
                        'Abonado', '\$${totalAbonado.toStringAsFixed(2)}'),
                    const Divider(height: 10),
                    _resumenRow(
                        'Saldo Pendiente', '\$${saldo.toStringAsFixed(2)}',
                        bold: true,
                        color: saldo > 0 ? ThemeApp.error : ThemeApp.success),
                    const Divider(height: 16),
                    _resumenRow(
                        'Cliente',
                        _cliente != null
                            ? '${_cliente!.nombres} ${_cliente!.apellidos}'
                            : 'No seleccionado'),
                    _resumenRow('Fecha Recepción', fecha),
                    if (_pagoAhora && montoPago > 0)
                      _resumenRow('Método Pago',
                          TipoPago.getTipoPagoLabel(_metodoPago)),
                    const SizedBox(height: 12),
                    const Text('Comentario',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            fontFamily: ThemeApp.fontFamily)),
                    const SizedBox(height: 6),
                    TextField(
                        controller: _comentarioCtrl,
                        maxLines: 2,
                        decoration: ThemeApp.inputDecoration(
                            '', 'Notas adicionales...', Icons.description)),
                  ]))),
      _buildBottomNav(),
    ]);
  }

  Widget _resumenRow(String label, String value,
      {bool bold = false, Color? color}) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  fontSize: bold ? 15 : 13,
                  fontFamily: ThemeApp.fontFamily,
                  color: color)),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                  fontSize: bold ? 15 : 13,
                  fontFamily: ThemeApp.fontFamily,
                  color: color)),
        ]));
  }
}
