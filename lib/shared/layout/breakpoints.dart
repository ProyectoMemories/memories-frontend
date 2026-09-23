import 'package:flutter/widgets.dart';

/// Un solo codigo para movil y web (RNF-05): lo que cambia es el ancho.
enum TamanoPantalla { movil, tableta, escritorio }

class Breakpoints {
  const Breakpoints._();

  static const double tableta = 600;
  static const double escritorio = 1024;

  /// Ancho maximo del contenido: en una pantalla de 27 pulgadas, una columna de
  /// texto de lado a lado no hay quien la lea.
  static const double anchoMaximoContenido = 900;

  static TamanoPantalla de(BuildContext context) {
    final double ancho = MediaQuery.sizeOf(context).width;
    if (ancho >= escritorio) {
      return TamanoPantalla.escritorio;
    }
    if (ancho >= tableta) {
      return TamanoPantalla.tableta;
    }
    return TamanoPantalla.movil;
  }

  static bool esMovil(BuildContext context) =>
      de(context) == TamanoPantalla.movil;

  static bool esAncha(BuildContext context) =>
      de(context) != TamanoPantalla.movil;

  /// Cuantas columnas de fotografias caben.
  static int columnas(BuildContext context) {
    switch (de(context)) {
      case TamanoPantalla.movil:
        return 2;
      case TamanoPantalla.tableta:
        return 3;
      case TamanoPantalla.escritorio:
        return 4;
    }
  }
}
