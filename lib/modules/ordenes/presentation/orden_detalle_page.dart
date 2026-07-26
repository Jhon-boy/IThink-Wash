import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/app/providers/provider.dart';
import 'package:ithinkwash/core/app_constants.dart';
import 'package:ithinkwash/core/entities/orden_detalle_entity.dart';
import 'package:ithinkwash/core/entities/orden_entity.dart';
import 'package:ithinkwash/core/entities/persona_entity.dart';
import 'package:ithinkwash/core/entities/sucursal_entity.dart';
import 'package:ithinkwash/core/singleton/singleton_app.dart';
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
import 'package:ithinkwash/shared/widgets/dialog_widget.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final o = widget.orden;
    final dr = await _ordenRepository.getDetallesByOrdenEntity(o.idOrden!);
    dr.fold((l) => null, (r) => _detalles = r);

    PersonaEntity? cliente;
    final cr = await _personaRepo.getPersonaById(o.idPersona);
    cr.fold((l) => null, (r) => cliente = r);

    PersonaEntity? emp;
    final ur = await _usuarioRepo.getUsuarioById(o.idEmpleado);
    ur.fold((l) => null, (r) async {
      final er = await _personaRepo.getPersonaById(r.idPersona);
      er.fold((l) => null, (r) => emp = r);
    });

    SucursalEntity? suc;
    final sr = await _sucursalRepo.getSucursalesbyIdEntity(o.idSucursal);
    sr.fold((l) => null, (r) => suc = r);

    if (mounted) {
      setState(() {
        _cliente = cliente;
        _empleadoPersona = emp;
        _sucursal = suc;
        _isLoading = false;
      });
    }
  }

  void _finalizarOrden() {
    final user = SingletonApp.getUser();
    if (widget.orden.estado == EstadosOrden.ENTREGADO.code) {
      DialogHelper.info(context,
          message:
              "Esta orden ya fue finalizada y no es posible realizar modificaciones sobre ella",
          onConfirmed: () {});
      return;
    }
    DialogHelper.confirm(
      context,
      message:
          '¿Finalizar orden?\nSe marcará como ${EstadosOrden.ENTREGADO.label} y el saldo pendiente se registrará como pagado.',
      title: 'Confirmar Finalización',
      okText: 'Sí, Finalizar',
      cancelText: 'Cancelar',
      okColor: ThemeApp.success,
      onConfirm: () async {
        final o = widget.orden;
        final updated = TordOrdenEntity(
            idOrden: o.idOrden,
            idSucursal: o.idSucursal,
            idPersona: o.idPersona,
            idEmpleado: o.idEmpleado,
            fechaRecepcion: o.fechaRecepcion,
            fechaEntregaEstimada: o.fechaEntregaEstimada,
            fechaEntregaReal: DateTime.now(),
            subtotal: o.total,
            total: o.total,
            totalAbonado: o.total,
            saldoPendiente: 0,
            estado: EstadosOrden.ENTREGADO.code,
            comentario: o.comentario,
            fCreacion: o.fCreacion,
            usuarioCreacion: o.usuarioCreacion,
            fModificacion: DateTime.now(),
            usuarioModificacion:
                user?.idUsuario != null ? user?.idUsuario.toString() : "");
        ref.read(appStateProvider.notifier).setLoading(true);
        final r = await _ordenRepository.updateOrdenEntity(updated);
        ref.read(appStateProvider.notifier).setLoading(false);
        r.fold(
          (l) => SnackHelper.show(context,
              message: 'Error: ${l.message}', isError: true),
          (_) {
            if (mounted) {
              Navigator.pop(context, true);
              SnackHelper.show(context, message: 'Orden finalizada');
            }
          },
        );
      },
      onCancel: () {},
    );
  }

  Future<void> _imprimirTicket() async {
    final o = widget.orden;
    final font = await PdfGoogleFonts.nunitoRegular();
    final doc = pw.Document();
    doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(8),
        build: (ctx) {
          final now =
              '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}';
          final emp = _empleadoPersona != null
              ? '${_empleadoPersona!.nombres} ${_empleadoPersona!.apellidos}'
              : 'ID: ${o.idEmpleado}';
          return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                    child: pw.Column(children: [
                  pw.Text(AppConstants.APP_NAME,
                      style: pw.TextStyle(
                          font: font,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold)),
                  pw.Text('SISTEMA DE LAVANDERÍA',
                      style: pw.TextStyle(
                          font: font, fontSize: 8, color: PdfColors.grey600)),
                ])),
                pw.Divider(),
                pw.Text(o.numeroOrden ?? 'FACTURA #${o.idOrden}',
                    style: pw.TextStyle(
                        font: font,
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold)),
                pw.Text(EstadosOrden.fromCode(o.estado).label,
                    style: pw.TextStyle(font: font, fontSize: 10)),
                pw.Divider(),
                pw.Text(
                    'Cliente: ${_cliente != null ? '${_cliente!.nombres} ${_cliente!.apellidos}' : 'ID: ${o.idPersona}'}',
                    style: pw.TextStyle(font: font, fontSize: 10)),
                pw.Text('ID Factura: ${o.numeroOrden ?? '#${o.idOrden}'}',
                    style: pw.TextStyle(font: font, fontSize: 10)),
                pw.Text(
                    'Entrega est: ${o.fechaEntregaEstimada != null ? AppUtils.formatDate(o.fechaEntregaEstimada!) : 'Pendiente'}',
                    style: pw.TextStyle(font: font, fontSize: 10)),
                if (_cliente?.telefono != null &&
                    _cliente!.telefono!.isNotEmpty)
                  pw.Text('Tel: ${_cliente!.telefono}',
                      style: pw.TextStyle(font: font, fontSize: 10)),
                pw.Divider(),
                pw.Text('Recepción: ${AppUtils.formatDate(o.fechaRecepcion)}',
                    style: pw.TextStyle(font: font, fontSize: 10)),
                pw.Divider(),
                _pdfRow(font, 'Subtotal',
                    '\$${(o.totalAbonado ?? 0).toStringAsFixed(2)}'),
                _pdfRow(font, 'Total', '\$${(o.total ?? 0).toStringAsFixed(2)}',
                    bold: true),
                if (o.saldoPendiente != null && o.saldoPendiente! > 0)
                  _pdfRow(font, 'Saldo Pendiente',
                      '\$${o.saldoPendiente!.toStringAsFixed(2)}',
                      bold: true),
                if (_detalles.isNotEmpty) ...[
                  pw.Divider(),
                  pw.Text('Detalles',
                      style: pw.TextStyle(
                          font: font,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold)),
                  ..._detalles.map((d) => pw.Row(children: [
                        pw.Expanded(
                            flex: 3,
                            child: pw.Text(d.descripcionPrenda ?? 'Prenda',
                                style: pw.TextStyle(font: font, fontSize: 9))),
                        if (d.cantidad != null)
                          pw.Text('x${d.cantidad!.toStringAsFixed(0)}  ',
                              style: pw.TextStyle(font: font, fontSize: 9)),
                        if (d.subtotal != null)
                          pw.Text('\$${d.subtotal!.toStringAsFixed(2)}',
                              style: pw.TextStyle(font: font, fontSize: 9)),
                      ])),
                ],
                pw.Divider(),
                pw.Center(
                    child: pw.Text(
                        '$now  •  $emp  •  ${_sucursal?.nombre ?? ''}',
                        style: pw.TextStyle(
                            font: font,
                            fontSize: 8,
                            color: PdfColors.grey600))),
              ]);
        }));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/orden_${o.idOrden}.pdf');
    await file.writeAsBytes(await doc.save());
    await Share.shareXFiles([XFile(file.path)], text: 'Orden #${o.idOrden}');
  }

  pw.Widget _pdfRow(pw.Font font, String label, String value,
      {bool bold = false}) {
    return pw
        .Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      pw.Text(label,
          style: pw.TextStyle(
              font: font,
              fontSize: 10,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      pw.Text(value,
          style: pw.TextStyle(
              font: font,
              fontSize: 10,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
    ]);
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
              ])),
    );
  }

  Widget _buildTicket() {
    final o = widget.orden;
    debugPrint('ESTADO --> ${o.estado}');
    final estado = EstadosOrden.fromCode(o.estado);
    final now =
        '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    final emp = _empleadoPersona != null
        ? '${_empleadoPersona!.nombres} ${_empleadoPersona!.apellidos}'
        : 'ID: ${o.idEmpleado}';

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.grey.shade300)),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
                child: Column(children: [
              const Icon(Icons.water_drop, size: 40, color: ThemeApp.primary),
              const SizedBox(height: 4),
              Text(AppConstants.APP_NAME,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: ThemeApp.fontFamily,
                      color: ThemeApp.primary)),
              const Text('SISTEMA DE LAVANDERÍA',
                  style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      color: ThemeApp.textSecondary,
                      fontFamily: ThemeApp.fontFamily)),
            ])),
            const Divider(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(o.numeroOrden ?? 'FACTURA #${o.idOrden}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: ThemeApp.fontFamily)),
                const SizedBox(height: 2),
                Text('${_detalles.length} prendas',
                    style: const TextStyle(
                        fontSize: 13,
                        color: ThemeApp.textSecondary,
                        fontFamily: ThemeApp.fontFamily)),
              ]),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color:
                          AppUtils.getColorEstado(o.estado).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(estado.label,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppUtils.getColorEstado(o.estado),
                          fontFamily: ThemeApp.fontFamily))),
            ]),
            const Divider(height: 20),
            _section('CLIENTE'),
            const SizedBox(height: 6),
            _dr(
                Icons.person,
                'Nombre',
                _cliente != null
                    ? '${_cliente!.nombres} ${_cliente!.apellidos}'
                    : 'ID: ${o.idPersona}',
                bold: true),
            if (_cliente?.identificacion != null &&
                _cliente!.identificacion.isNotEmpty)
              _dr(Icons.badge_outlined, 'Identificación',
                  _cliente!.identificacion),
            if (_cliente?.telefono != null && _cliente!.telefono!.isNotEmpty)
              _dr(Icons.phone, 'Teléfono', _cliente!.telefono!),
            const SizedBox(height: 16),
            _section('DATOS DE LA ORDEN'),
            const SizedBox(height: 6),
            _dr(Icons.receipt, 'ID Factura', o.numeroOrden ?? '#${o.idOrden}'),
            _dr(Icons.calendar_today, 'Fecha Recepción',
                AppUtils.formatDate(o.fechaRecepcion)),
            _dr(
                Icons.local_shipping,
                'Entrega Estimada',
                o.fechaEntregaEstimada != null
                    ? AppUtils.formatDate(o.fechaEntregaEstimada!)
                    : 'Pendiente'),
            if (o.fechaEntregaReal != null)
              _dr(Icons.check_circle, 'Entrega Real',
                  AppUtils.formatDate(o.fechaEntregaReal!)),
            _dr(Icons.badge, 'Empleado', emp),
            _dr(Icons.store, 'Sucursal',
                _sucursal?.nombre ?? 'Sucursal #${o.idSucursal}'),
            const SizedBox(height: 16),
            _section('COMENTARIO'),
            if (o.comentario != null && o.comentario!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('"${o.comentario!}"',
                      style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: ThemeApp.textSecondary,
                          fontFamily: ThemeApp.fontFamily))),
            ],
            const SizedBox(height: 16),
            _section('DETALLES'),
            const SizedBox(height: 6),
            if (_detalles.isEmpty)
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text('Sin detalles',
                      style: TextStyle(
                          fontSize: 13,
                          color: ThemeApp.textSecondary,
                          fontFamily: ThemeApp.fontFamily)))
            else
              ..._detalles.asMap().entries.map((e) {
                final d = e.value;
                return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8)),
                    child: Row(children: [
                      Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                              color: ThemeApp.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6)),
                          child: Center(
                              child: Text('${e.key + 1}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: ThemeApp.primary,
                                      fontFamily: ThemeApp.fontFamily)))),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(d.descripcionPrenda ?? 'Prenda',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    fontFamily: ThemeApp.fontFamily)),
                            const SizedBox(height: 2),
                            Row(children: [
                              if (d.cantidad != null)
                                Text('Cant: ${d.cantidad!.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: ThemeApp.textSecondary,
                                        fontFamily: ThemeApp.fontFamily)),
                              if (d.cantidad != null &&
                                  d.precioUnitario != null)
                                const Text('  •  ',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: ThemeApp.textSecondary)),
                              if (d.precioUnitario != null)
                                Text(
                                    'P/U: \$${d.precioUnitario!.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: ThemeApp.textSecondary,
                                        fontFamily: ThemeApp.fontFamily)),
                            ]),
                          ])),
                      if (d.subtotal != null)
                        Text('\$${d.subtotal!.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: ThemeApp.primary,
                                fontFamily: ThemeApp.fontFamily)),
                    ]));
              }),
            const SizedBox(
              height: 16,
            ),
            _section('PAGOS'),
            const Divider(height: 24),
            Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: ThemeApp.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  _tr('Subtotal', o.subtotal ?? 0),
                  const SizedBox(height: 4),
                  _tr('Total Abonado', o.totalAbonado ?? 0),
                  const Divider(height: 12),
                  _tr('TOTAL', o.total ?? 0, bold: true, size: 18),
                  if (o.saldoPendiente != null && o.saldoPendiente! > 0) ...[
                    const Divider(height: 12),
                    _tr('Saldo Pendiente', o.saldoPendiente!,
                        bold: true, color: ThemeApp.error),
                  ],
                ])),
            const SizedBox(height: 12),
            Center(
                child: Text('$now  •  $emp  •  ${_sucursal?.nombre ?? ''}',
                    style: const TextStyle(
                        fontSize: 11,
                        color: ThemeApp.textSecondary,
                        fontFamily: ThemeApp.fontFamily))),
          ])),
    );
  }

  Widget _section(String label) => Text(label,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: ThemeApp.textSecondary,
          fontFamily: ThemeApp.fontFamily));

  Widget _dr(IconData icon, String label, String value, {bool bold = false}) =>
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            Icon(icon, size: 15, color: ThemeApp.textSecondary),
            const SizedBox(width: 8),
            SizedBox(
                width: 110,
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 13,
                        color: ThemeApp.textSecondary,
                        fontFamily: ThemeApp.fontFamily))),
            Expanded(
                child: Text(value,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
                        fontFamily: ThemeApp.fontFamily))),
          ]));

  Widget _tr(String label, double value,
          {bool bold = false, double size = 15, Color? color}) =>
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label,
            style: TextStyle(
                fontSize: size,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: color ?? ThemeApp.textPrimary,
                fontFamily: ThemeApp.fontFamily)),
        Text('\$${value.toStringAsFixed(2)}',
            style: TextStyle(
                fontSize: size,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                color: color ?? ThemeApp.primary,
                fontFamily: ThemeApp.fontFamily)),
      ]);

  Widget _buildAcciones() {
    return Column(children: [
      CustomButton(
          text: 'Finalizar Orden',
          colorButton: ThemeApp.success,
          colorText: ThemeApp.white,
          icon: Icons.check_circle,
          onPressed: _finalizarOrden),
      const SizedBox(height: 10),
      CustomButton(
          text: 'Ticket PDF',
          colorButton: ThemeApp.primary,
          colorText: ThemeApp.white,
          icon: Icons.print,
          onPressed: _imprimirTicket),
      const SizedBox(height: 10),
      CustomButton(
          text: 'Regresar',
          colorButton: ThemeApp.background,
          colorText: ThemeApp.textPrimary,
          icon: Icons.arrow_back,
          onPressed: () => Navigator.pop(context)),
    ]);
  }
}
