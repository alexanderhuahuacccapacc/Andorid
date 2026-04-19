import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tarea.dart';
import 'tarea_repository.dart';

class TareaRepoSharedPrefs implements TareaRepository {
  static const _claveTareas = 'tareas_lista';

  final SharedPreferences _prefs;

  TareaRepoSharedPrefs._(this._prefs);

  static Future<TareaRepoSharedPrefs> create() async {
    final prefs = await SharedPreferences.getInstance();
    return TareaRepoSharedPrefs._(prefs);
  }

  List<Tarea> _leerTareas() {
    final lista = _prefs.getStringList(_claveTareas) ?? [];
    return lista
        .map((jsonStr) => Tarea.fromJson(
        jsonDecode(jsonStr) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _guardarTodas(List<Tarea> tareas) async {
    final lista =
    tareas.map((t) => jsonEncode(t.toJson())).toList();
    await _prefs.setStringList(_claveTareas, lista);
  }

  @override
  Future<List<Tarea>> obtenerTodas() async {
    return _leerTareas();
  }

  @override
  Future<void> guardar(Tarea tarea) async {
    final actuales = _leerTareas();
    actuales.add(tarea);
    await _guardarTodas(actuales);
  }

  @override
  Future<void> actualizar(Tarea tarea) async {
    final actuales = _leerTareas();
    final i = actuales.indexWhere((t) => t.id == tarea.id);
    if (i != -1) {
      actuales[i] = tarea;
      await _guardarTodas(actuales);
    }
  }

  @override
  Future<void> eliminar(String id) async {
    final actuales =
    _leerTareas()..removeWhere((t) => t.id == id);
    await _guardarTodas(actuales);
  }
}