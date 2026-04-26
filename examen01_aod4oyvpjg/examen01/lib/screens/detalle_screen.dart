

// screens/detalle_screen.dart
import 'package:flutter/material.dart';
import '../models/gasto.dart';
class DetalleScreen extends StatelessWidget {
// El objeto Gasto llega como parametro del constructor.
// Navigator lo pasa en: MaterialPageRoute(builder: (_) => DetalleScreen(gasto: g))
  final Gasto gasto;
  const DetalleScreen({super.key, required this.gasto});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Gasto'),
        backgroundColor: const Color(0xFF23373B),
        foregroundColor: Colors.white,
// El boton de retroceso llama Navigator.pop automaticamente
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Fila(etiqueta: 'Nombre', valor: gasto.nombre),
            _Fila(etiqueta: 'Categoria', valor: gasto.categoria),
            _Fila(
              etiqueta: 'Monto',
              valor: 'S/. ${gasto.monto.toStringAsFixed(2)}',
            ),
            _Fila(
              etiqueta: 'Descripcion',
// Caso borde: descripcion vacia muestra texto alternativo
              valor: gasto.descripcion.isEmpty
                  ? 'Sin descripcion'
                  : gasto.descripcion,
            ),
            _Fila(
              etiqueta: 'Registrado el',
              valor: '${gasto.fechaRegistro.day}/'
                  '${gasto.fechaRegistro.month}/'
                  '${gasto.fechaRegistro.year} '
                  '${gasto.fechaRegistro.hour}:'
                  '${gasto.fechaRegistro.minute.toString().padLeft(2, "0")}',
            ),
          ],
        ),
      ),
    );
  }
}
// Widget auxiliar para cada fila de informacion
class _Fila extends StatelessWidget {
  final String etiqueta;
  final String valor;
  const _Fila({required this.etiqueta, required this.valor});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text('$etiqueta:',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF23373B))),
          ),
          Expanded(
            child: Text(valor, style: const TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}