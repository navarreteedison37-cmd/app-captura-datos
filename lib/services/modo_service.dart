import 'package:shared_preferences/shared_preferences.dart';
import 'template_service.dart';

/// Guarda/recupera la eleccion de modo (Inspeccion Laboral o Control de
/// Ingresos) para que la pregunta solo aparezca UNA vez, la primera vez
/// que se abre la app.
class ModoService {
  static const _clave = 'modo_trabajo_seleccionado';

  Future<ModoTrabajo?> obtenerModoGuardado() async {
    final prefs = await SharedPreferences.getInstance();
    final valor = prefs.getString(_clave);
    if (valor == null) return null;
    return ModoTrabajo.values.firstWhere(
      (m) => m.name == valor,
      orElse: () => ModoTrabajo.inspeccionLaboral,
    );
  }

  Future<void> guardarModo(ModoTrabajo modo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clave, modo.name);
  }

  /// Solo para pruebas / boton de "cambiar modo" si lo necesitas despues.
  Future<void> borrarModo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clave);
  }
}
