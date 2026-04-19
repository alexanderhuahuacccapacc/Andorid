import '../models/tarea.dart';
abstract class TareaRepository {
// Obtener todas las tareas almacenadas
  Future<List<Tarea>> obtenerTodas();
// Guardar una nueva tarea
  Future<void> guardar(Tarea tarea);
  // Actualizar una tarea existente (por id)
  Future<void> actualizar(Tarea tarea);
// Eliminar una tarea por su id
  Future<void> eliminar(String id);
}