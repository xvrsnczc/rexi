/// Formato de moneda, fechas, etc.
abstract final class Formatters {
  static String currency(double value, {String symbol = r'$'}) {
    return '$symbol${value.toStringAsFixed(2)}';
  }
}
