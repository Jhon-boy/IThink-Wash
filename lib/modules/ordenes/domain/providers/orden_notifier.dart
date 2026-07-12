import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ithinkwash/core/entities/orden_entity.dart';

class OrderNotifier extends StateNotifier<List<TordOrdenEntity>> {
  OrderNotifier() : super([]);

  void setOrdenes(List<TordOrdenEntity> ordenes) {
    state = List<TordOrdenEntity>.from(ordenes);
  }

  void agregarOrden(TordOrdenEntity orden) {
    state = [...state, orden];
  }

  void actualizarOrden(TordOrdenEntity orden) {
    state = state.map((o) => o.idOrden == orden.idOrden ? orden : o).toList();
  }

  void eliminarOrden(int idOrden) {
    state = state.where((o) => o.idOrden != idOrden).toList();
  }

  List<TordOrdenEntity> getOrdenesPorSucursal(int idSucursal) {
    return state.where((o) => o.idSucursal == idSucursal).toList();
  }

  void limpiar() {
    state = [];
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, List<TordOrdenEntity>>((ref) {
  return OrderNotifier();
});
