// ignore_for_file: constant_identifier_names

enum TipoPago {
  EFECTIVO("EFECTIVO"),
  TRANSFERENCIA("TRANSFERENCIA"),
  OTRO("OTRO");

  final String state;
  const TipoPago(this.state);

  static String getTipoPagoLabel(String tipoPago) {
    switch (tipoPago) {
      case 'EFECTIVO':
        return TipoPago.EFECTIVO.state;
      case 'TRANSFERENCIA':
        return TipoPago.TRANSFERENCIA.state;
      case 'OTRO':
        return TipoPago.OTRO.state;
      default:
        return tipoPago;
    }
  }

  static String getList() {
    return TipoPago.values.map((e) => e.name).join(', ');
  }

  static List<String> getListValues() {
    return TipoPago.values.map((e) => e.name).toList();
  }
}
