/// Validadores de formularios transversales.
abstract final class Validators {
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
    if (!v.contains('@')) return 'Correo no válido';
    return null;
  }

  static String? passwordMin6(String? v) {
    if (v == null || v.length < 6) return 'Al menos 6 caracteres';
    return null;
  }
}
