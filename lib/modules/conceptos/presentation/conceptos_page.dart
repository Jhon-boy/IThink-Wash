import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/app/providers/provider.dart';
import 'package:ithinkwash/core/entities/concepto_entity.dart';
import 'package:ithinkwash/core/entities/servicio_adicional_entity.dart';
import 'package:ithinkwash/core/singleton/singleton_app.dart';
import 'package:ithinkwash/core/theme_app.dart';
import 'package:ithinkwash/core/utils/snack_helper.dart';
import 'package:ithinkwash/modules/conceptos/data/datasource/concepto_remote_datasource.dart';
import 'package:ithinkwash/modules/conceptos/data/repository/concepto_repository.dart';
import 'package:ithinkwash/modules/conceptos/domain/repository/concepto_repository.dart';
import 'package:ithinkwash/modules/conceptos/presentation/concepto_form_dialog.dart';
import 'package:ithinkwash/modules/conceptos/presentation/widgets/concepto_card_widget.dart';
import 'package:ithinkwash/modules/servicios_adicionales/data/datasource/servicio_adicional_remote_datasource.dart';
import 'package:ithinkwash/modules/servicios_adicionales/data/repository/servicio_adicional_repository.dart';
import 'package:ithinkwash/modules/servicios_adicionales/domain/repository/servicio_adicional_repository.dart';
import 'package:ithinkwash/modules/servicios_adicionales/presentation/servicio_adicional_form_dialog.dart';
import 'package:ithinkwash/modules/servicios_adicionales/presentation/widgets/servicio_adicional_card_widget.dart';
import 'package:ithinkwash/shared/baseApp/pantalla_base.dart';
import 'package:ithinkwash/shared/enums/estados_general.dart';
import 'package:ithinkwash/shared/widgets/dialog_widget.dart';
import 'package:ithinkwash/shared/widgets/shimer_producto.dart';

class ConceptosPage extends ConsumerStatefulWidget {
  const ConceptosPage({super.key, this.titulo = 'Servicios'});

  final String titulo;

  @override
  ConsumerState<ConceptosPage> createState() => _ConceptosPageState();
}

class _ConceptosPageState extends ConsumerState<ConceptosPage> {
  late final ConceptoRepository _conceptoRepo;
  late final ServicioAdicionalRepository _servicioRepo;
  List<TserConceptoEntity> _conceptos = [];
  List<TserConceptoEntity> _conceptosFiltrados = [];
  List<TserServicioAdicionalEntity> _servicios = [];
  List<TserServicioAdicionalEntity> _serviciosFiltrados = [];
  bool _isLoading = true;
  int _tabIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _conceptoRepo =
        ConceptoRemoteRepository(ConceptoRemoteDataSource(ref: ref));
    _servicioRepo = ServicioAdicionalRemoteRepository(
        ServicioAdicionalRemoteDataSource(ref: ref));
    _cargar();
    _searchCtrl.addListener(_filtrar);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    ref.read(appStateProvider.notifier).setLoading(true);
    try {
      setState(() => _isLoading = true);
      final cResult = await _conceptoRepo.getConceptosEntity();
      cResult.fold((l) => null, (r) => _conceptos = r);
      final sResult = await _servicioRepo.getServiciosAdicionalesEntity();
      sResult.fold((l) => null, (r) => _servicios = r);
      _filtrar();
    } catch (_) {
    } finally {
      ref.read(appStateProvider.notifier).setLoading(false);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filtrar() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _conceptosFiltrados = q.isEmpty
          ? _conceptos
          : _conceptos
              .where((c) =>
                  c.nombre.toLowerCase().contains(q) ||
                  (c.descripcion?.toLowerCase().contains(q) ?? false))
              .toList();
      _serviciosFiltrados = q.isEmpty
          ? _servicios
          : _servicios
              .where((s) =>
                  s.nombre.toLowerCase().contains(q) ||
                  (s.descripcion?.toLowerCase().contains(q) ?? false))
              .toList();
    });
  }

  Future<void> _crearConcepto() async {
    try {
      final result = await ConceptoFormDialog.show(context, null);
      if (result == null) return;
      ref.read(appStateProvider.notifier).setLoading(true);
      final r = await _conceptoRepo.registerConceptoEntity(result);
      r.fold(
        (l) => SnackHelper.show(context,
            message: 'Error al crear: ${l.message}', isError: true),
        (_) {
          SnackHelper.show(context, message: 'Concepto creado');
          _cargar();
        },
      );
    } catch (_) {
    } finally {
      ref.read(appStateProvider.notifier).setLoading(false);
    }
  }

  Future<void> _editarConcepto(TserConceptoEntity concepto) async {
    try {
      final result = await ConceptoFormDialog.show(context, concepto);
      if (result == null) return;
      ref.read(appStateProvider.notifier).setLoading(true);
      final r = await _conceptoRepo.updateConceptoEntity(result);
      r.fold(
        (l) => SnackHelper.show(context,
            message: 'Error al actualizar: ${l.message}', isError: true),
        (_) {
          SnackHelper.show(context, message: 'Concepto actualizado');
          _cargar();
        },
      );
    } catch (_) {
    } finally {
      ref.read(appStateProvider.notifier).setLoading(false);
    }
  }

  void _toggleConcepto(TserConceptoEntity concepto) {
    final activo = concepto.estado.toUpperCase() == EstadosGeneral.ACTIVO.state;
    DialogHelper.confirm(context,
        message: activo
            ? '¿Desactivar concepto "${concepto.nombre}"?'
            : '¿Activar concepto "${concepto.nombre}"?',
        onConfirm: () async {
          ref.read(appStateProvider.notifier).setLoading(true);
          try {
            final r = await _conceptoRepo.toggleEstadoConceptoEntity(
                concepto.idConcepto!,
                !activo,
                SingletonApp.getUser()?.idUsuario.toString() ?? '');
            r.fold(
              (l) => SnackHelper.show(context,
                  message: 'Error: ${l.message}', isError: true),
              (_) {
                SnackHelper.show(context,
                    message:
                        activo ? 'Concepto desactivado' : 'Concepto activado');
                _cargar();
              },
            );
          } catch (_) {
          } finally {
            ref.read(appStateProvider.notifier).setLoading(false);
          }
        },
        onCancel: () => {});
  }

  Future<void> _crearServicio() async {
    try {
      final result = await ServicioAdicionalFormDialog.show(context, null);
      if (result == null) return;
      ref.read(appStateProvider.notifier).setLoading(true);
      final r = await _servicioRepo.registerServicioAdicionalEntity(result);
      r.fold(
        (l) => SnackHelper.show(context,
            message: 'Error al crear: ${l.message}', isError: true),
        (_) {
          _cargar();
          DialogHelper.success(context,
              message: 'Servicio adicional creado', onConfirmed: () {});
        },
      );
    } catch (l) {
      SnackHelper.show(context, message: 'Error al crear: $l', isError: true);
    } finally {
      ref.read(appStateProvider.notifier).setLoading(false);
    }
  }

  Future<void> _editarServicio(TserServicioAdicionalEntity servicio) async {
    try {
      final result = await ServicioAdicionalFormDialog.show(context, servicio);
      if (result == null) return;
      ref.read(appStateProvider.notifier).setLoading(true);
      final r = await _servicioRepo.updateServicioAdicionalEntity(result);
      r.fold(
        (l) => SnackHelper.show(context,
            message: 'Error al actualizar: ${l.message}', isError: true),
        (_) {
          SnackHelper.show(context, message: 'Servicio actualizado');
          _cargar();
        },
      );
    } catch (ex) {
      SnackHelper.show(context,
          message: 'Error al actualizar: $ex', isError: true);
    } finally {
      ref.read(appStateProvider.notifier).setLoading(false);
    }
  }

  void _toggleServicio(TserServicioAdicionalEntity servicio) {
    final activo = servicio.estado.toUpperCase() == EstadosGeneral.ACTIVO.state;
    DialogHelper.confirm(context,
        message: activo
            ? '¿Desactivar servicio "${servicio.nombre}"?'
            : '¿Activar servicio "${servicio.nombre}"?',
        onConfirm: () async {
          ref.read(appStateProvider.notifier).setLoading(true);
          try {
            final r = await _servicioRepo.toggleEstadoServicioAdicionalEntity(
                servicio.idServicioAdicional!,
                !activo,
                SingletonApp.getUser()?.idUsuario.toString() ?? '');
            r.fold(
              (l) => SnackHelper.show(context,
                  message: 'Error: ${l.message}', isError: true),
              (_) {
                SnackHelper.show(context,
                    message:
                        activo ? 'Servicio desactivado' : 'Servicio activado');
                _cargar();
              },
            );
          } catch (_) {
          } finally {
            ref.read(appStateProvider.notifier).setLoading(false);
          }
        },
        onCancel: () => {});
  }

  @override
  Widget build(BuildContext context) {
    return PantallaBase(
      title: widget.titulo,
      body: _isLoading
          ? const ShimmerDetalle()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: ThemeApp.inputDecoration(
                        'Buscar', 'Buscar...', Icons.search),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildTab(0, 'Conceptos', Icons.local_laundry_service,
                          _conceptosFiltrados.length),
                      const SizedBox(width: 8),
                      _buildTab(1, 'Servicios Adicionales', Icons.dry_cleaning,
                          _serviciosFiltrados.length),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _tabIndex == 0
                      ? _buildConceptosList()
                      : _buildServiciosList(),
                ),
              ],
            ),
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton(
              heroTag: 'btn_add_concepto',
              backgroundColor: ThemeApp.primary,
              onPressed: _crearConcepto,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : FloatingActionButton(
              heroTag: 'btn_add_servicio',
              backgroundColor: ThemeApp.success,
              onPressed: _crearServicio,
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon, int count) {
    final selected = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? ThemeApp.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: selected ? Colors.white : ThemeApp.textSecondary),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : ThemeApp.textPrimary,
                  fontFamily: ThemeApp.fontFamily,
                )),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count',
                  style: TextStyle(
                      fontSize: 11,
                      color: selected ? Colors.white : ThemeApp.textSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConceptosList() {
    return RefreshIndicator(
      onRefresh: _cargar,
      child: _conceptosFiltrados.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 80),
                Center(
                    child: Text('Sin conceptos',
                        style: TextStyle(
                            color: ThemeApp.textSecondary,
                            fontFamily: ThemeApp.fontFamily))),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _conceptosFiltrados.length,
              itemBuilder: (_, i) => ConceptoCardWidget(
                concepto: _conceptosFiltrados[i],
                onDelete: () => _toggleConcepto(_conceptosFiltrados[i]),
                onEdit: () => _editarConcepto(_conceptosFiltrados[i]),
              ),
            ),
    );
  }

  Widget _buildServiciosList() {
    return RefreshIndicator(
      onRefresh: _cargar,
      child: _serviciosFiltrados.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 80),
                Center(
                    child: Text('Sin servicios adicionales',
                        style: TextStyle(
                            color: ThemeApp.textSecondary,
                            fontFamily: ThemeApp.fontFamily))),
              ],
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _serviciosFiltrados.length,
              itemBuilder: (_, i) => ServicioAdicionalCardWidget(
                servicio: _serviciosFiltrados[i],
                onDelete: () => _toggleServicio(_serviciosFiltrados[i]),
                onEdit: () => _editarServicio(_serviciosFiltrados[i]),
              ),
            ),
    );
  }
}
