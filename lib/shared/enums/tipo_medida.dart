enum TipoMedida {
  LIBRA("Libra"),
  KILO("Kilo"),
  UNIDAD("Unidad"),
  PERSONALIZADO("Personalizado");

  final String state;
  const TipoMedida(this.state);

  static String getList() {
    return TipoMedida.values.map((e) => e.name).join(', ');
  }

  static List<String> getListValues() {
    return TipoMedida.values.map((e) => e.name).toList();
  }

  static String getTipoMedidaLabel(String tipoMedida) {
    switch (tipoMedida) {
      case 'LIBRA':
        return TipoMedida.LIBRA.state;
      case 'KILO':
        return TipoMedida.KILO.state;
      case 'UNIDAD':
        return TipoMedida.UNIDAD.state;
      case 'PERSONALIZADO':
        return TipoMedida.PERSONALIZADO.state;
      default:
        return tipoMedida; // Retorna el valor original si no coincide con ningún caso
    }
  }
}
