import '../models/tarea.dart';
import 'tarea_repository.dart';
class TareaRepoMemory implements TareaRepository {
// Lista interna — solo visible dentro de esta clase
  final List<Tarea> _datos = [];
  @override
  Future<List<Tarea>> obtenerTodas() async {
// En una implementación real aquí iría:
// await db.query('tareas');
// await http.get(Uri.parse('api/tareas'));
// Por ahora devolvemos una copia de la lista en memoria.
    return List.unmodifiable(_datos);
  }
  @override
  Future<void> guardar(Tarea tarea) async {
    _datos.add(tarea);
     // En implementación real: await db.insert('tareas', tarea.toMap());
  }
  @override
  Future<void> actualizar(Tarea tarea) async {
    final i = _datos.indexWhere((t) => t.id == tarea.id);
    if (i != -1) _datos[i] = tarea;
    // En implementación real: await db.update('tareas', tarea.toMap());
  }
  @override
  Future<void> eliminar(String id) async {
    _datos.removeWhere((t) => t.id == id);
     // En implementación real: await db.delete('tareas', where: 'id = ?');
  }
}