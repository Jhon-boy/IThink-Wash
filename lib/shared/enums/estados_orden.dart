// ignore_for_file: constant_identifier_names

import 'dart:ui';

import 'package:ithinkwash/core/theme_app.dart';

enum EstadosOrden {
  INGRESADO(1, "ING", "Ingresado"),
  EN_PROCESO(2, "PRO", "En Proceso"),
  LISTO_PARA_ENTREGA(3, "LIS", "Listo para Entrega"),
  ENTREGADO(4, "ENT", "Entregado"),
  CANCELADO(5, "CAN", "Cancelado");

  final int id;
  final String code;
  final String label;
  const EstadosOrden(this.id, this.code, this.label);

  static List<EstadosOrden> get all => EstadosOrden.values;
  static List<String> get allCodes => all.map((e) => e.code).toList();

  static EstadosOrden fromCode(String code) {
    return all.firstWhere(
      (e) => e.code.toUpperCase() == code.toUpperCase(),
      orElse: () => EN_PROCESO,
    );
  }

  static String getLabelFromCode(String code) {
    return fromCode(code).label;
  }

  EstadosOrden get siguiente {
    final idx = index + 1;
    if (idx < all.length) return all[idx];
    return this;
  }

  bool get esTerminal => this == ENTREGADO || this == CANCELADO;

  static Color getColorFromCode(String code) {
    final estado = fromCode(code);
    switch (estado) {
      case INGRESADO:
        return ThemeApp.primary; // Azul
      case EN_PROCESO:
        return ThemeApp.blue; // Azul
      case LISTO_PARA_ENTREGA:
        return ThemeApp.link; // Verde
      case ENTREGADO:
        return ThemeApp.success; // Gris
      case CANCELADO:
        return ThemeApp.error; // Rojo
    }
  }
}
