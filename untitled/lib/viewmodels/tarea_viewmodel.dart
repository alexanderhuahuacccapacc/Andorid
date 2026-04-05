import 'package:flutter/foundation.dart';
import '../models/tarea.dart';
enum FiltroTarea { todas, pendientes, completadas }
class TareasViewModel extends ChangeNotifier {
  final List<Tarea> _tareas = [];
  FiltroTarea _filtro = FiltroTarea.todas;
  FiltroTarea get filtro => _filtro;
  int get pendientes =>
      _tareas.where((t) => !t.completada).length;
  List<Tarea> get tareas {
    switch (_filtro) {
      case FiltroTarea.pendientes:
        return _tareas.where((t) => !t.completada).toList();
      case FiltroTarea.completadas:
        return _tareas.where((t) => t.completada).toList();
      default:
        return List.unmodifiable(_tareas);
    }
  }
  void agregar(String titulo) {
    if (titulo.trim().isEmpty) return;
    _tareas.add(Tarea(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: titulo.trim(),
      creadaEn: DateTime.now(),
    ));
    notifyListeners();
  }
  void toggleCompletada(String id) {
    final idx = _tareas.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _tareas[idx] = _tareas[idx].copyWith(
      completada: !_tareas[idx].completada,
    );
    notifyListeners();
  }
  void eliminar(String id) {
    _tareas.removeWhere((t) => t.id == id);
    notifyListeners();
  }
  void cambiarFiltro(FiltroTarea f) {
    _filtro = f;
    notifyListeners();
  }
}
final tareasVM = TareasViewModel();
