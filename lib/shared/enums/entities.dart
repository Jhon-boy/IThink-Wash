// ignore_for_file: constant_identifier_names
enum Entities {
  TORGSUCURSAL("torgsucursal"),
  TPERPERSONA("tperpersona"),
  TSEGROL("tsegrol"),
  TSEGCANAL("tsegcanal"),
  TSEGUSUARIO("tsegusuario"),
  TSEGROLUSUARIO("tsegrolusuario"),
  TSEGUSUARIOCANAL("tsegusuariocanal"),
  TSEGDISPOSITIVO("tsegdispositivo"),
  TSEGSESION("tsegsesion"),
  TSERCONCEPTO("tserconcepto"),
  TSERSERVICIOADICIONAL("tserservicioadicional"),
  TORDORDEN("tordorden"),
  TORDORDENDETALLE("tordordendetalle"),
  TORDORDENDETALLEADICIONAL("tordordendetalleadicional"),
  TORDPAGO("tordpago"),
  TFINMOVIMIENTO("tfinmovimiento");

  final String tableName;
  const Entities(this.tableName);
}
