// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/gastos_viewmodel.dart';
import '../models/gasto.dart';
import 'registro_screen.dart';
import 'detalle_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Gastos'),
        backgroundColor: const Color(0xFF23373B),
        foregroundColor: Colors.white,
      ),
      // Consumer escucha cambios en GastosViewModel.
      // Se reconstruye automaticamente cuando notifyListeners() es llamado.
      body: Consumer<GastosViewModel>(
        builder: (context, vm, _) {
          return Column(
            children: [
              _TotalesCard(vm: vm),
              Expanded(
                child: vm.estaVacia
                    ? const _EstadoVacio()
                    : _ListaGastos(vm: vm),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // No necesita pasar argumentos: RegistroScreen
          // accede al ViewModel via Provider directamente.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegistroScreen()),
          );
        },
        backgroundColor: const Color(0xFFEB811B),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
} // Widget de totales — muestra total general y por categoria

class _TotalesCard extends StatelessWidget {
  final GastosViewModel vm;

  const _TotalesCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total general: S/. ${vm.totalGeneral.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Muestra solo categorias con gastos registrados
            ...categorias.map((cat) {
              final total = vm.totalPorCategoria(cat);
              if (total == 0) return const SizedBox.shrink();
              return Text(
                '$cat: S/. ${total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// Estado vacio: mensaje + icono cuando no hay gastos
class _EstadoVacio extends StatelessWidget {
  const _EstadoVacio();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.black26),
          SizedBox(height: 16),
          Text(
            'No tienes gastos registrados',
            style: TextStyle(fontSize: 16, color: Colors.black45),
          ),
          SizedBox(height: 8),
          Text(
            'Toca + para agregar tu primer gasto',
            style: TextStyle(fontSize: 13, color: Colors.black38),
          ),
        ],
      ),
    );
  }
}

// Lista de gastos con ListView.builder
class _ListaGastos extends StatelessWidget {
  final GastosViewModel vm;

  const _ListaGastos({required this.vm});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: vm.gastos.length,
      itemBuilder: (context, index) {
        final gasto = vm.gastos[index];
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0xFFEB811B),
            child: Icon(Icons.attach_money, color: Colors.white),
          ),
          title: Text(gasto.nombre),
          subtitle: Text(gasto.categoria),
          trailing: Text(
            'S/. ${gasto.monto.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () {
            // Pasamos el objeto Gasto completo como argumento al constructor
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetalleScreen(gasto: gasto)),
            );
          },
        );
      },
    );
  }
}
