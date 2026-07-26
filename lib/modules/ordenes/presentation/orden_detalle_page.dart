import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ithinkwash/core/app_constants.dart';
import 'package:ithinkwash/core/entities/orden_detalle_entity.dart';
import 'package:ithinkwash/core/entities/orden_entity.dart';
import 'package:ithinkwash/core/entities/pago_entity.dart';
import 'package:ithinkwash/core/entities/persona_entity.dart';
import 'package:ithinkwash/core/entities/sucursal_entity.dart';
import 'package:ithinkwash/core/theme_app.dart';
import 'package:ithinkwash/core/utils/app_util.dart';
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
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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
  List<TordPagoEntity> _pagos = [];
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
    final pr = await _ordenRepository.getPagosByOrdenEntity(o.idOrden!);
    pr.fold((l) => null, (r) => _pagos = r);

    PersonaEntity? cliente;
    final cr =
        await _personaRepo.getPersonaById(o.idPersona);
    cr.fold((l) => null, (r) => cliente = r);

    PersonaEntity? emp;
    final ur = await _usuarioRepo.getUsuarioById(o.idEmpleado);
    ur.fold((l) => null, (r) async {
      final er =
          await _personaRepo.getPersonaByIdentificacion(r.idPersona.toString());
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
    final r = await _ordenRepository.updateOrdenEntity(updated);
    r.fold((l) => null, (_) {
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Orden $nuevoEstado')));
      }
    });
  }

  Future<void> _imprimirTicket() async {
    final o = widget.orden;
    final font = await PdfGoogleFonts.nunitoRegular();
    final doc = pw.Document();

    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.roll80,
      margin: const pw.EdgeInsets.all(8),
      build: (ctx) {
        final now = '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}';
        final emp = _empleadoPersona != null ? '${_empleadoPersona!.nombres} ${_empleadoPersona!.apellidos}' : 'ID: ${o.idEmpleado}';

        return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
          pw.Center(child: pw.Column(children: [
            pw.Text(AppConstants.APP_NAME, style: pw.TextStyle(font: font, fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text('SISTEMA DE LAVANDERÍA', style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600)),
          ])),
          pw.Divider(),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text(o.numeroOrden ?? 'FACTURA #${o.idOrden}', style: pw.TextStyle(font: font, fontSize: 12, fontWeight: pw.FontWeight.bold)),
            pw.Text(EstadosOrden.fromCode(o.estado).label, style: pw.TextStyle(font: font, fontSize: 10)),
          ]),
          pw.Divider(),
          pw.Text('Cliente: ${_cliente != null ? '${_cliente!.nombres} ${_cliente!.apellidos}' : 'ID: ${o.idPersona}'}', style: pw.TextStyle(font: font, fontSize: 10)),
          pw.Text('ID Factura: ${o.numeroOrden ?? '#${o.idOrden}'}', style: pw.TextStyle(font: font, fontSize: 10)),
          pw.Text('Entrega est: ${o.fechaEntregaEstimada != null ? AppUtils.formatDate(o.fechaEntregaEstimada!) : 'Pendiente'}', style: pw.TextStyle(font: font, fontSize: 10)),
          if (_cliente?.telefono != null && _cliente!.telefono!.isNotEmpty) pw.Text('Tel: ${_cliente!.telefono}', style: pw.TextStyle(font: font, fontSize: 10)),
          pw.Divider(),
          pw.Text('Recepción: ${AppUtils.formatDate(o.fechaRecepcion)}', style: pw.TextStyle(font: font, fontSize: 10)),
          pw.Divider(),
          _pdfRow(font, 'Subtotal', '\$${(o.totalAbonado ?? 0).toStringAsFixed(2)}'),
          _pdfRow(font, 'Total', '\$${(o.total ?? 0).toStringAsFixed(2)}', bold: true),
          if (o.saldoPendiente != null && o.saldoPendiente! > 0) _pdfRow(font, 'Saldo Pendiente', '\$${o.saldoPendiente!.toStringAsFixed(2)}', bold: true),
          if (_detalles.isNotEmpty) ...[pw.Divider(), pw.Text('Detalles', style: pw.TextStyle(font: font, fontSize: 10, fontWeight: pw.FontWeight.bold)),
            ..._detalles.map((d) => pw.Row(children: [
              pw.Expanded(flex: 3, child: pw.Text(d.descripcionPrenda ?? 'Prenda', style: pw.TextStyle(font: font, fontSize: 9))),
              if (d.cantidad != null) pw.Text('x${d.cantidad!.toStringAsFixed(0)}  ', style: pw.TextStyle(font: font, fontSize: 9)),
              if (d.subtotal != null) pw.Text('\$${d.subtotal!.toStringAsFixed(2)}', style: pw.TextStyle(font: font, fontSize: 9)),
            ])),
          ],
          if (_pagos.isNotEmpty) ...[pw.Divider(), pw.Text('Pagos', style: pw.TextStyle(font: font, fontSize: 10, fontWeight: pw.FontWeight.bold)),
            ..._pagos.map((p) => pw.Row(children: [
              pw.Expanded(child: pw.Text(p.metodoPago ?? 'Pago', style: pw.TextStyle(font: font, fontSize: 9))),
              pw.Text('\$${(p.monto ?? 0).toStringAsFixed(2)}', style: pw.TextStyle(font: font, fontSize: 9)),
            ])),
          ],
          pw.Divider(),
          pw.Center(child: pw.Text('$now  •  $emp  •  ${_sucursal?.nombre ?? ''}', style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600))),
        ]);
      },
    ));

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/orden_${o.idOrden}.pdf');
    await file.writeAsBytes(await doc.save());
    await Share.shareXFiles([XFile(file.path)], text: 'Orden #${o.idOrden}');
  }

  pw.Widget _pdfRow(pw.Font font, String label, String value, {bool bold = false}) {
    return pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      pw.Text(value, style: pw.TextStyle(font: font, fontSize: 10, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
    ]);
  }

  Future<void> _contactarWhatsApp() async {
    if (_cliente?.telefono == null || _cliente!.telefono!.isEmpty) return;
    final phone = _cliente!.telefono!.replaceAll(RegExp(r'[^0-9]'), '');
    final msg = Uri.encodeComponent(
        'Hola ${_cliente!.nombres}, tu orden #${widget.orden.idOrden} está lista.');
    final url = 'https://wa.me/$phone?text=$msg';
    if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
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
    final now =
        '${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year} ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    final emp = _empleadoPersona != null
        ? '${_empleadoPersona!.nombres} ${_empleadoPersona!.apellidos}'
        : 'ID: ${o.idEmpleado}';
    const b = TextStyle(
        fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87);
    const n = TextStyle(fontSize: 11, color: Colors.black87);
    const s = TextStyle(fontSize: 9, color: Colors.black54);

    return Container(
        width: 320,
        color: Colors.white,
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
              child: Column(children: [
            Text(AppConstants.APP_NAME, style: b.copyWith(fontSize: 16)),
            Text('SISTEMA DE LAVANDERÍA', style: s),
          ])),
          const Divider(height: 12),
          Text(o.numeroOrden ?? 'FACTURA #${o.idOrden}', style: b.copyWith(fontSize: 14)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppUtils.getColorEstado(o.estado).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(estado.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppUtils.getColorEstado(o.estado))),
          ),
          const Divider(height: 12),
          _ln('Cliente', _cliente != null ? '${_cliente!.nombres} ${_cliente!.apellidos}' : 'ID: ${o.idPersona}', b),
          _ln('ID Factura', o.numeroOrden ?? '#${o.idOrden}', n),
          _ln('Entrega est.', o.fechaEntregaEstimada != null ? AppUtils.formatDate(o.fechaEntregaEstimada!) : 'Pendiente', n),
          if (_cliente?.telefono != null && _cliente!.telefono!.isNotEmpty) _ln('Tel', _cliente!.telefono!, n),
          if (o.comentario != null && o.comentario!.isNotEmpty)
            Padding(padding: const EdgeInsets.only(top: 4), child: Text('"${o.comentario!}"', style: s.copyWith(fontStyle: FontStyle.italic))),
          const Divider(height: 8),
          _ln('Recepción', AppUtils.formatDate(o.fechaRecepcion), n),
          _ln('Subtotal', '\$${(o.totalAbonado ?? 0).toStringAsFixed(2)}', n),
          _ln('Total', '\$${(o.total ?? 0).toStringAsFixed(2)}', b),
          if (o.saldoPendiente != null && o.saldoPendiente! > 0)
            _ln('Saldo Pendiente', '\$${o.saldoPendiente!.toStringAsFixed(2)}',
                b.copyWith(color: Colors.red)),
          if (_detalles.isNotEmpty) ...[
            const Divider(height: 8),
            const Text('Detalles', style: b),
            const SizedBox(height: 4),
            ..._detalles.map((d) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Row(children: [
                  Expanded(
                      flex: 3,
                      child: Text(d.descripcionPrenda ?? 'Prenda', style: n)),
                  if (d.cantidad != null)
                    Text('x${d.cantidad!.toStringAsFixed(0)}  ', style: s),
                  if (d.subtotal != null)
                    Text('\$${d.subtotal!.toStringAsFixed(2)}', style: n),
                ]))),
          ],
          if (_pagos.isNotEmpty) ...[
            const Divider(height: 8),
            const Text('Pagos', style: b),
            const SizedBox(height: 4),
            ..._pagos.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Row(children: [
                  Expanded(child: Text(p.metodoPago ?? 'Pago', style: n)),
                  Text('\$${(p.monto ?? 0).toStringAsFixed(2)}', style: n),
                ]))),
          ],
          const Divider(height: 12),
          Center(
              child: Text('$now  •  $emp  •  ${_sucursal?.nombre ?? ''}',
                  style: s, textAlign: TextAlign.center)),
        ]));
  }

  Widget _ln(String label, String value, TextStyle ts) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(label, style: ts), Text(value, style: ts)]));
  }

  Widget _buildAcciones() {
    final estado = EstadosOrden.fromCode(widget.orden.estado);
    return Column(children: [
      if (!estado.esTerminal) ...[
        CustomButton(
            text: 'Avanzar a ${estado.siguiente.label}',
            colorButton: ThemeApp.primary,
            colorText: ThemeApp.white,
            icon: FontAwesomeIcons.arrowRight,
            onPressed: () => _cambiarEstado(estado.siguiente.code)),
        const SizedBox(height: 10),
      ],
      Row(children: [
        if (_cliente?.telefono != null && _cliente!.telefono!.isNotEmpty)
          Expanded(
              child: CustomButton(
                  text: 'WhatsApp',
                  colorButton: Colors.green,
                  colorText: ThemeApp.white,
                  icon: FontAwesomeIcons.whatsapp,
                  onPressed: _contactarWhatsApp)),
        if (_cliente?.telefono != null && _cliente!.telefono!.isNotEmpty)
          const SizedBox(width: 10),
        Expanded(
            child: CustomButton(
                text: 'Ticket PDF',
                colorButton: ThemeApp.background,
                colorText: ThemeApp.textPrimary,
                icon: FontAwesomeIcons.print,
                onPressed: _imprimirTicket)),
      ]),
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
