class Tarea {
  final String id; // identificador único (timestamp ms)
  final String titulo; // texto de la tarea
  final bool completada; // false=pendiente, true=completada
  final DateTime creadaEn;
  const Tarea({
    required this.id,
    required this.titulo,
    this.completada = false,
    required this.creadaEn,
  });
// copyWith: retorna una COPIA con los campos modificados
  Tarea copyWith({bool? completada, String? titulo}) {
    return Tarea(
      id: this.id,
      titulo: titulo ?? this.titulo,
      completada: completada ?? this.completada,
      creadaEn: this.creadaEn,
    );
  }
}