class Gasto {
  final String nombre; // Nombre descriptivo (ej: "Almuerzo")
  final double monto; // Monto en soles, siempre > 0
  final String categoria; // Una de las 5 categorias predefinidas
  final String descripcion; // Opcional — puede ser cadena vacia
  final DateTime fechaRegistro; // Generada automaticamente al crear el objeto
  Gasto({
    required this.nombre,
    required this.monto,
    required this.categoria,
    this.descripcion = '', // Valor por defecto: vacio
    DateTime? fechaRegistro, // Si no se pasa, se usa DateTime.now()
  }) : fechaRegistro = fechaRegistro ?? DateTime.now();
// ↑ Initializer list: se ejecuta ANTES del cuerpo del constructor.
// El operador ?? significa: "si es null, usar el valor de la derecha".
// Es la unica forma de inicializar un campo final con logica condicional.
  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'monto': monto,
    'categoria': categoria,
    'descripcion': descripcion,
// DateTime no es un tipo JSON valido, lo convertimos
// a String en formato ISO 8601: "2026-04-12T14:30:00.000"
// Este formato es estandar internacional y DateTime.parse()
// puede convertirlo de vuelta sin perder informacion.
    'fecha': fechaRegistro.toIso8601String(),
  };
  factory Gasto.fromJson(Map<String, dynamic> json) {
    return Gasto(
      nombre: json['nombre'] as String,
      monto: json['monto'] as double,
      categoria: json['categoria'] as String,
      descripcion: json['descripcion'] as String,
// Convertimos el String ISO 8601 de vuelta a DateTime.
      fechaRegistro: DateTime.parse(json['fecha'] as String),
    );
  }

}