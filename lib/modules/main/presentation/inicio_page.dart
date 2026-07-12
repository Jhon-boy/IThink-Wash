import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/core/entities/orden_entity.dart';
import 'package:ithinkwash/core/singleton/singleton_app.dart';
import 'package:ithinkwash/core/theme_app.dart';
import 'package:ithinkwash/modules/authentication/domain/providers/user_provider.dart';
import 'package:ithinkwash/modules/main/presentation/widget/no_producto_widget.dart';
import 'package:ithinkwash/modules/ordenes/data/datasource/orden_remote_datasource.dart';
import 'package:ithinkwash/modules/ordenes/data/repository/orden_repository.dart';
import 'package:ithinkwash/modules/ordenes/domain/providers/orden_notifier.dart';
import 'package:ithinkwash/modules/ordenes/domain/repository/orden_repository.dart';
import 'package:ithinkwash/modules/ordenes/presentation/orden_detalle_page.dart';
import 'package:ithinkwash/modules/ordenes/presentation/widgets/orden_card_widget.dart';
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
  List<TordOrdenEntity> _ordenes = [];

  @override
  void initState() {
    super.initState();
    repository = OrdenRemoteRepository(OrdenRemoteDataSource(ref: ref));
    _cargarOrdenes();
  }

  void _cargarOrdenes() {
    final idSucursal = SingletonApp.getUser()?.idSucursal ?? 1;
    final todas = ref.read(orderProvider.notifier).getOrdenesPorSucursal(idSucursal);
    _ordenes = todas..sort((a, b) => b.fechaRecepcion.compareTo(a.fechaRecepcion));
    _isLoading = false;
  }

  Future<void> _refreshOrdenes() async {
    setState(() => _isLoading = true);

    final idSucursal =
        ref.read(userProvider.notifier).getUser()?.idSucursal ?? 1;

    final result = await repository.getOrdenesBySucursalEntity(idSucursal);

    result.fold(
      (failure) {
        if (mounted) {
          DialogHelper.error(context,
              message: 'Error al obtener las órdenes: ${failure.message}',
              onConfirmed: () {});
        }
      },
      (ordenes) {
        if (mounted) {
          ref.read(orderProvider.notifier).setOrdenes(ordenes);
          _ordenes = ordenes
            ..sort((a, b) => b.fechaRecepcion.compareTo(a.fechaRecepcion));
          setState(() => _isLoading = false);
        }
      },
    );
  }

  void _abrirDetalle(TordOrdenEntity orden) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrdenDetallePage(orden: orden),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const ShimmerLoader();
    }

    if (_ordenes.isEmpty) {
      return RefreshIndicator(
        color: ThemeApp.primary,
        onRefresh: _refreshOrdenes,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          children: const [
            SizedBox(height: 100),
            NoProductosWidget(
              message:
                  'No existen órdenes para esta sucursal.',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: ThemeApp.primary,
      onRefresh: _refreshOrdenes,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: _ordenes.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Órdenes del día',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            );
          }
          final orden = _ordenes[index - 1];
          return OrdenCardWidget(
            orden: orden,
            onTap: () => _abrirDetalle(orden),
          );
        },
      ),
    );
  }
}
