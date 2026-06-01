import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/providers/supplier_provider.dart';
import 'package:sales/models/supplier.dart';
import 'form.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    context.read<SupplierProvider>().loadAll();
  }

  Future<void> _sincronizar() async {
    setState(() => _syncing = true);
    final result = await context.read<SupplierProvider>().sincronizar();
    if (!mounted) return;
    setState(() => _syncing = false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sincronización completa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Creados: ${result['sincronizados']}'),
            Text('Actualizados: ${result['actualizados']}'),
            Text('Ya existían: ${result['duplicados']}'),
            Text('Errores: ${result['errores']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmarEliminar(BuildContext context, Supplier supplier) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar proveedor'),
        content: Text('¿Seguro que deseas eliminar a ${supplier.name}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return confirm ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = context.watch<SupplierProvider>().suppliers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Proveedores'),
        backgroundColor: Colors.orange,
        actions: [
          _syncing
              ? const Padding(
            padding: EdgeInsets.all(12.0),
            child: CircularProgressIndicator(color: Colors.white),
          )
              : IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar',
            onPressed: _sincronizar,
          ),
        ],
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SupplierFormScreen(),
            ),
          );
          if (!mounted) return;
          context.read<SupplierProvider>().loadAll();
        },
        child: const Icon(Icons.add),
      ),
      body: suppliers.isEmpty
          ? const Center(child: Text('No hay proveedores registrados'))
          : ListView.builder(
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          final supplier = suppliers[index];
          return Dismissible(
            key: Key(supplier.id.toString()),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) => _confirmarEliminar(context, supplier),
            onDismissed: (_) async {
              await context.read<SupplierProvider>().delete(supplier);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              leading: Icon(
                supplier.isSynced ? Icons.cloud_done : Icons.cloud_off,
                color: supplier.isSynced ? Colors.green : Colors.red,
              ),
              title: Text(supplier.name),
              subtitle: Text('${supplier.documentNumber} · ${supplier.email}'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SupplierFormScreen(supplier: supplier),
                  ),
                );
                if (!mounted) return;
                context.read<SupplierProvider>().loadAll();
              },
            ),
          );
        },
      ),
    );
  }
}