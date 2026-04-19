import 'package:flutter/foundation.dart';
import '../models/tarea.dart';
import '../repositories/tarea_repository.dart';

enum FiltroTareas { todas, pendientes, completadas }

class TareasViewModel extends ChangeNotifier {
  // El repository se inyecta por constructor.
  // El ViewModel no lo crea — solo lo recibe y lo usa.
  final TareaRepository _repo;

  TareasViewModel(this._repo) {
    Future.microtask(() => cargarTareas());
  }

  List<Tarea> _tareas = [];
  FiltroTareas _filtroActivo = FiltroTareas.todas;
  bool _cargando = false; // ← nuevo: estado de carga

  // ── Getters ──────────────────────────────────────────────────
  List<Tarea> get tareas => List.unmodifiable(
    switch (_filtroActivo) {
      FiltroTareas.todas => _tareas,
      FiltroTareas.pendientes =>
          _tareas.where((t) => !t.completada).toList(),
      FiltroTareas.completadas =>
          _tareas.where((t) => t.completada).toList(),
    },
  );

  bool get cargando => _cargando;

  FiltroTareas get filtroActivo => _filtroActivo;

  int get totalTareas => _tareas.length;

  int get tareasCompletadas =>
      _tareas.where((t) => t.completada).length;

  int get tareasPendientes =>
      _tareas.where((t) => !t.completada).length;

  // ── Métodos ──────────────────────────────────────────────────
  Future<void> cargarTareas() async {
    _cargando = true;
    notifyListeners();
    // Corrección: obtenerTodas() ya devuelve List<Tarea>.
    // No necesita cast adicional.
    _tareas = await _repo.obtenerTodas();
    _cargando = false;
    notifyListeners();
  }

  Future<void> agregarTarea({
    required String titulo,
    String descripcion = '',
  }) async {
    if (titulo.trim().isEmpty) return;

    final nueva = Tarea(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: titulo.trim(),
      descripcion: descripcion.trim(),
      creadaEn: DateTime.now(),
    );

    await _repo.guardar(nueva);
    await cargarTareas(); // recarga desde el repo para mantener sincronía
  }

  Future<void> toggleCompletada(String id) async {
    final tarea = _tareas.firstWhere((t) => t.id == id);
    final actualizada =
    tarea.copyWith(completada: !tarea.completada);

    await _repo.actualizar(actualizada);
    await cargarTareas();
  }

  Future<void> eliminarTarea(String id) async {
    await _repo.eliminar(id);
    await cargarTareas();
  }

  void cambiarFiltro(FiltroTareas filtro) {
    if (_filtroActivo == filtro) return;

    _filtroActivo = filtro;
    notifyListeners();
  }
}