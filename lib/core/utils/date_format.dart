import 'package:intl/intl.dart';

/// Formatos de fecha de la aplicacion, en espanol y en un solo sitio.
class Fechas {
  const Fechas._();

  static const String _locale = 'es';

  /// 15 de enero de 2026
  static String largo(DateTime fecha) =>
      DateFormat("d 'de' MMMM 'de' y", _locale).format(fecha);

  /// 15 ene 2026
  static String corto(DateTime fecha) => DateFormat('d MMM y', _locale).format(fecha);

  /// enero 2026
  static String mesYAno(DateTime fecha) => DateFormat('MMMM y', _locale).format(fecha);

  /// Lo que entiende la API: 2026-01-15
  static String iso(DateTime fecha) =>
      '${fecha.year.toString().padLeft(4, '0')}-'
      '${fecha.month.toString().padLeft(2, '0')}-'
      '${fecha.day.toString().padLeft(2, '0')}';

  /// Una fecha sin hora, para comparar dias sin sorpresas de zona horaria.
  static DateTime soloDia(DateTime fecha) =>
      DateTime(fecha.year, fecha.month, fecha.day);

  static bool mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
