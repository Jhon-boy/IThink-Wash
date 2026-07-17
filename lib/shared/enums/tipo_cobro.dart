enum TipoCobro {
  LIBRA("Libra"),
  KILO("Kilo"),
  PERSONALIZADO("Personalizado");

  final String state;
  const TipoCobro(this.state);

  static String getTipoCobroLabel(String tipoCobro) {
    switch (tipoCobro) {
      case 'LIBRA':
        return TipoCobro.LIBRA.state;
      case 'KILO':
        return TipoCobro.KILO.state;
      case 'PERSONALIZADO':
        return TipoCobro.PERSONALIZADO.state;
      default:
        return tipoCobro; // Retorna el valor original si no coincide con ningún caso
    }
  }

  static String getList() {
    return TipoCobro.values.map((e) => e.name).join(', ');
  }

  static List<String> getListValues() {
    return TipoCobro.values.map((e) => e.name).toList();
  }
}
