/// Cuantos recuerdos hay en un dia concreto.
///
/// El calendario no necesita los recuerdos enteros para pintarse: solo el
/// recuento por dia.
class CalendarDay {
  const CalendarDay({required this.day, required this.count});

  final DateTime day;
  final int count;
}
