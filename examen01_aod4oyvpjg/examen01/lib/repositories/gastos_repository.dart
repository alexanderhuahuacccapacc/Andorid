// repositories/gastos_repository.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gasto.dart';
// Esta clase es la UNICA responsable de leer y escribir gastos
// en el dispositivo. El ViewModel no sabe si usamos SharedPreferences,
// SQLite o una API — solo llama metodos de esta clase.
class GastosRepository {
// La clave bajo la cual guardaremos la lista en SharedPreferences.
// Es una constante porque nunca cambia. Usamos "_" porque es
// privada — solo esta clase la conoce.
  static const _clave = 'gastos_lista';
// Lee la lista de gastos guardada en disco.
// Es "async" porque SharedPreferences hace operaciones de I/O
// (lectura de archivo) que pueden tardar un momento.
// Siempre retornamos una lista, nunca null — si no hay datos,
// retornamos lista vacia.
  Future<List<Gasto>> cargarGastos() async {
// getInstance() obtiene la instancia de SharedPreferences.
// Es async porque la primera vez inicializa el archivo en disco.
    final prefs = await SharedPreferences.getInstance();
// getStringList retorna List<String>? (puede ser null si la
// clave no existe aun — por ejemplo, la primera vez que abre la app).
    final datos = prefs.getStringList(_clave);
// Si datos es null (no hay nada guardado), retornamos lista vacia.
    if (datos == null) return [];
// Convertimos cada String JSON de vuelta a un objeto Gasto:
// 1. jsonDecode(s) convierte el String a Map<String, dynamic>
// 2. Gasto.fromJson(map) convierte el Map a objeto Gasto
    return datos
        .map((s) => Gasto.fromJson(jsonDecode(s)))
        .toList();
  }
  // Reemplaza lo que habia antes — siempre guardamos la lista entera.
  Future<void> guardarGastos(List<Gasto> gastos) async {
    final prefs = await SharedPreferences.getInstance();
// Convertimos cada Gasto a String JSON:
// 1. gasto.toJson() convierte el Gasto a Map<String, dynamic>
// 2. jsonEncode(map) convierte el Map a String JSON
    final datos = gastos
        .map((g) => jsonEncode(g.toJson()))
        .toList();
// setStringList guarda la lista de Strings en disco.
    await prefs.setStringList(_clave, datos);
  }
}