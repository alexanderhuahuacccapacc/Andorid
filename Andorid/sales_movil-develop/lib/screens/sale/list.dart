import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/providers/sale_provider.dart';
import 'package:sales/models/sale.dart';
import 'form.dart';

class SaleListScreen extends StatefulWidget {
  const SaleListScreen({super.key});
  @override
  State<SaleListScreen> createState() => _SaleListScreenState();
}

class _SaleListScreenState extends State<SaleListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
            () => context.read<SaleProvider>().loadAll()
    );
  }

  Future<void> _confirmDelete(Sale s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(  // CORREGIDO: usar dialogContext
        title: const Text('Eliminar venta'),
        content: Text('¿Eliminar venta #${s.id}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),  // CORREGIDO
              child: const Text('Cancelar')
          ),
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),   // CORREGIDO
              child: const Text('Eliminar', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<SaleProvider>().delete(s.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SaleProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas'),
        backgroundColor: Colors.green,
        actions: [
          Consumer<SaleProvider>(
            builder: (ctx, prov, _) {
              // Cuenta cuántas ventas están pendientes
              final pendientes = prov.sales.where((s) => !s.isSynced).length;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.cloud_upload_outlined),
                    tooltip: 'Sincronizar',
                    onPressed: () async {
                      await prov.sincronizar();
                      if (mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Sincronización completada')),
                        );
                      }
                    },
                  ),
                  if (pendientes > 0)
                    Positioned(
                      top: 8, right: 8,
                      child: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.red,
                        child: Text('$pendientes',
                            style: const TextStyle(fontSize: 10, color: Colors.white)),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SaleFormScreen())),
        child: const Icon(Icons.add),
      ),
      body: prov.sales.isEmpty
          ? const Center(child: Text('Sin ventas registradas'))
          : ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: prov.sales.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          final s = prov.sales[i];
          return Card(
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[100],
                child: Text('#${s.id}',
                    style: const TextStyle(
                        fontSize: 11, color: Colors.green)),
              ),
              title: Text(s.clientName ?? 'Cliente #${s.clientId}'),
              subtitle: Text(s.createdAt ?? ''),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('S/ ${s.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red),
                    onPressed: () => _confirmDelete(s),
                  ),
                ],
              ),
              children: s.details.map((d) => ListTile(
                dense: true,
                leading: const Icon(Icons.circle, size: 8),
                title: Text(d.productName),
                trailing: Text(
                    '${d.quantity} x S/ ${d.price.toStringAsFixed(2)}'),
              )).toList(),
            ),
          );
        },
      ),
    );
  }
}