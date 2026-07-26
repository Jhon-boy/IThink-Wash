import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/core/entities/orden_entity.dart';
import 'package:ithinkwash/core/singleton/singleton_app.dart';
import 'package:ithinkwash/core/theme_app.dart';
import 'package:ithinkwash/modules/main/presentation/widget/no_producto_widget.dart';
import 'package:ithinkwash/modules/ordenes/data/datasource/orden_remote_datasource.dart';
import 'package:ithinkwash/modules/ordenes/data/repository/orden_repository.dart';
import 'package:ithinkwash/modules/ordenes/domain/repository/orden_repository.dart';
import 'package:ithinkwash/modules/ordenes/presentation/orden_detalle_page.dart';
import 'package:ithinkwash/modules/ordenes/presentation/widgets/orden_card_widget.dart';
import 'package:ithinkwash/shared/widgets/calendar_widget.dart';
import 'package:ithinkwash/shared/widgets/dialog_widget.dart';
import 'package:ithinkwash/shared/widgets/shimer_producto.dart';

class InicioPage extends ConsumerStatefulWidget {
  final Function(int)? onSectionChange;
  const InicioPage({super.key, this.onSectionChange});

  @override
  ConsumerState<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends ConsumerState<InicioPage> {
  bool _isLoading = true;
  late final OrdenRepository repository;
  List<TordOrdenEntity> _todasOrdenes = [];
  List<TordOrdenEntity> _ordenes = [];
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    repository = OrdenRemoteRepository(OrdenRemoteDataSource(ref: ref));
    _fechaDesde = DateTime.now().subtract(const Duration(days: 14));
    _fechaHasta = DateTime.now();
    _searchCtrl.addListener(_aplicarBusqueda);
    _cargarOrdenes();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  int get _idSucursal => SingletonApp.getUser()?.idSucursal ?? 1;
  DateTime get _fechaHastaFin => DateTime(_fechaHasta!.year, _fechaHasta!.month, _fechaHasta!.day, 23, 59, 59);

  Future<void> _cargarOrdenes() async {
    setState(() => _isLoading = true);
    final result = await repository.getOrdenesByFechaRangeEntity(_idSucursal, _fechaDesde!, _fechaHastaFin);
    result.fold(
      (l) { if (mounted) setState(() => _isLoading = false); },
      (r) {
        _todasOrdenes = r..sort((a, b) => b.fechaRecepcion.compareTo(a.fechaRecepcion));
        _aplicarBusqueda();
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  Future<void> _refreshOrdenes() async {
    setState(() => _isLoading = true);
    final result = await repository.getOrdenesByFechaRangeEntity(_idSucursal, _fechaDesde!, _fechaHastaFin);
    result.fold(
      (failure) { if (mounted) DialogHelper.error(context, message: 'Error: ${failure.message}', onConfirmed: () {}); },
      (r) {
        if (mounted) {
          _todasOrdenes = r..sort((a, b) => b.fechaRecepcion.compareTo(a.fechaRecepcion));
          _aplicarBusqueda();
          setState(() => _isLoading = false);
        }
      },
    );
  }

  void _aplicarBusqueda() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _ordenes = q.isEmpty
          ? _todasOrdenes
          : _todasOrdenes.where((o) {
              if (o.idOrden.toString().contains(q)) return true;
              if (o.numeroOrden != null && o.numeroOrden!.toLowerCase().contains(q)) return true;
              if (o.idPersona.toString().contains(q)) return true;
              if (o.comentario != null && o.comentario!.toLowerCase().contains(q)) return true;
              return false;
            }).toList();
    });
  }

  void _abrirDetalle(TordOrdenEntity orden) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => OrdenDetallePage(orden: orden)));
  }

  String _fmt(DateTime? d) => d != null ? '${d.day}/${d.month}/${d.year}' : '';

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildFiltros(),
      Expanded(
        child: _isLoading
            ? const ShimmerLoader()
            : _ordenes.isEmpty
                ? RefreshIndicator(color: ThemeApp.primary, onRefresh: _refreshOrdenes,
                    child: ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(16), children: const [
                      SizedBox(height: 100),
                      NoProductosWidget(message: 'No existen órdenes en este rango de fechas'),
                    ]))
                : RefreshIndicator(color: ThemeApp.primary, onRefresh: _refreshOrdenes,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: _ordenes.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(padding: const EdgeInsets.only(bottom: 12, top: 8), child: Row(children: [
                            const Text('Órdenes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: ThemeApp.fontFamily)),
                            const Spacer(),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(color: ThemeApp.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Text('${_ordenes.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: ThemeApp.primary, fontFamily: ThemeApp.fontFamily))),
                          ]));
                        }
                        return OrdenCardWidget(orden: _ordenes[index - 1], onTap: () => _abrirDetalle(_ordenes[index - 1]));
                      },
                    )),
      ),
    ]);
  }

  Widget _buildFiltros() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: [
          _chipFecha('Desde', _fechaDesde, () async {
            final d = await CalendarWidget.showDatePickerDialog(context: context, title: 'Fecha Inicio', firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)));
            if (d != null) setState(() => _fechaDesde = d);
          }),
          const SizedBox(width: 6),
          _chipFecha('Hasta', _fechaHasta, () async {
            final d = await CalendarWidget.showDatePickerDialog(context: context, title: 'Fecha Fin', firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)));
            if (d != null) setState(() => _fechaHasta = d);
          }),
          const SizedBox(width: 6),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _cargarOrdenes,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: ThemeApp.primary, borderRadius: BorderRadius.circular(10)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.search, size: 16, color: Colors.white),
                SizedBox(width: 4),
                Text('Buscar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: ThemeApp.fontFamily)),
              ]),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 180,
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Filtrar...',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                prefixIcon: Icon(Icons.filter_list, size: 18),
              ),
              style: const TextStyle(fontSize: 13, fontFamily: ThemeApp.fontFamily),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _chipFecha(String label, DateTime? valor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.calendar_today, size: 14, color: ThemeApp.textSecondary),
          const SizedBox(width: 5),
          Text(valor != null ? _fmt(valor) : label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: valor != null ? ThemeApp.textPrimary : ThemeApp.textSecondary, fontFamily: ThemeApp.fontFamily)),
        ]),
      ),
    );
  }
}
