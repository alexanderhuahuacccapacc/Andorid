import 'package:flutter/foundation.dart';
import '../models/gasto.dart';
import '../repositories/gastos_repository.dart';
const List<String> categorias = [
  'Alimentacion',
  'Transporte',
  'Entretenimiento',
  'Salud',
  'Otros',
];
class GastosViewModel extends ChangeNotifier {
  final List<Gasto> _gastos = [];

// El ViewModel recibe el Repository desde afuera (inyeccion de
// dependencias). No lo crea el mismo porque si el dia de mañana
// queremos usar un Repository diferente (SQLite, API), solo
// cambiamos lo que le pasamos aqui — el ViewModel no cambia.
  final GastosRepository _repository;

// El constructor recibe el repository como parametro requerido.
  GastosViewModel(this._repository);

  List<Gasto> get gastos => List.unmodifiable(_gastos);

  double get totalGeneral =>
      _gastos.fold(0.0, (suma, g) => suma + g.monto);

  double totalPorCategoria(String categoria) =>
      _gastos
          .where((g) => g.categoria == categoria)
          .fold(0.0, (suma, g) => suma + g.monto);

  bool get estaVacia => _gastos.isEmpty;

// Nuevo metodo: carga los gastos guardados en disco al iniciar.
// Es async porque lee de SharedPreferences (operacion de I/O).
  Future<void> cargarGastos() async {
    final gastos = await _repository.cargarGastos();
// Limpiamos la lista actual y agregamos los gastos cargados.
    _gastos.clear();
    _gastos.addAll(gastos);
// Notificamos a la UI para que se reconstruya con los datos cargados.
    notifyListeners();
  }

// Modificado: ahora tambien persiste en disco despues de agregar.
  Future<void> agregarGasto(Gasto gasto) async {
    _gastos.add(gasto);
// Primero guardamos en disco para no perder el dato si algo falla.
    await _repository.guardarGastos(_gastos);
// Luego notificamos a la UI.
    notifyListeners();
  }
}
