import 'dart:convert';
// Model: datos puros de una Tarea.
// Regla de oro: este archivo NO importa nada de Flutter.
// Solo usa tipos de Dart puro (String, bool, DateTime, etc.)
class Tarea {
  final String id;
  final String titulo;
  final String descripcion;
  final bool completada;
  final DateTime creadaEn;
// Constructor con todos los campos requeridos.
// 'id' se genera con un timestamp para garantizar unicidad.
  const Tarea({
    required this.id,
    required this.titulo,
    this.descripcion = '',
    this.completada = false,
    required this.creadaEn,
  });
// copyWith: crea una nueva Tarea modificando solo los campos indicados.
// Es el patrón correcto para objetos inmutables — nunca modificamos
// la instancia original, creamos una nueva copia con los cambios.
  Tarea copyWith({
    String? titulo,
    String? descripcion,
    bool? completada,
  }) {
    return Tarea(
      id: id, // el id nunca cambia
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      completada: completada ?? this.completada,
      creadaEn: creadaEn, // la fecha de creación nunca cambia
    );
  }
// toString útil para depuración en la consola
  @override
  String toString() =>
      'Tarea(id: $id, titulo: $titulo, completada: $completada)';

  Map<String, dynamic> toJson() => {
    'id': id,
    'titulo': titulo,
    'descripcion': descripcion,
    'completada': completada,
    'creadaEn': creadaEn.toIso8601String(),
  };
// Constructor de fábrica: crea una Tarea desde un Map.
// Se usa después de deserializar el String con jsonDecode().
  factory Tarea.fromJson(Map<String, dynamic> json) => Tarea(
    id: json['id'] as String,
    titulo: json['titulo'] as String,
    descripcion: json['descripcion'] as String? ?? '',
    completada: json['completada'] as bool? ?? false,
    creadaEn: DateTime.parse(json['creadaEn'] as String),
  );
}
