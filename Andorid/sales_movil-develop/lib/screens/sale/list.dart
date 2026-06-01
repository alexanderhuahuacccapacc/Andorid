import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/providers/sale_provider.dart';
import 'package:sales/providers/client_provider.dart';
import 'package:sales/providers/product_provider.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SaleProvider>().loadAll();
      context.read<ClientProvider>().loadAll();
      context.read<ProductProvider>().loadAll();
    });
  }

  Future<void> _sincronizar(BuildContext context) async {
    final saleP = context.read<SaleProvider>();
    final result = await saleP.sincronizar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sincronizados: ${result['sincronizados']}  '
              'Actualizados: ${result['actualizados']}  '
              'Duplicados: ${result['duplicados']}  '
              'Errores: ${result['errores']}',
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saleP = context.watch<SaleProvider>();
    final clientP = context.watch<ClientProvider>();
    final productP = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar',
            onPressed: () => _sincronizar(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // Dropdown Cliente
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Cliente'),
              value: saleP.selectedClientId,
              items: clientP.clients
                  .map((c) => DropdownMenuItem(
                value: c.id,
                child: Text(c.name),
              ))
                  .toList(),
              onChanged: (val) {
                final client = clientP.clients.firstWhere((c) => c.id == val);
                saleP.selectClient(val, client.name);
              },
            ),
            const SizedBox(height: 12),

            // Dropdown Producto
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(labelText: 'Producto'),
              value: saleP.selectedProductId,
              items: productP.products
                  .map((p) => DropdownMenuItem(
                value: p.id,
                child: Text(p.name),
              ))
                  .toList(),
              onChanged: (val) {
                final product = productP.getById(val!);
                saleP.selectProduct(val, product.name, product.price);
              },
            ),
            const SizedBox(height: 12),

            // Campo Cantidad
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => saleP.updateQuantity(saleP.quantity - 1),
                ),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Cantidad'),
                    keyboardType: TextInputType.number,
                    key: ValueKey(saleP.quantity),
                    initialValue: saleP.quantity.toString(),
                    onChanged: (val) =>
                        saleP.updateQuantity(int.tryParse(val) ?? 1),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => saleP.updateQuantity(saleP.quantity + 1),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Total (solo lectura)
            TextFormField(
              decoration: const InputDecoration(labelText: 'Total'),
              readOnly: true,
              key: ValueKey(saleP.total),
              initialValue: saleP.total.toStringAsFixed(2),
            ),
            const SizedBox(height: 16),

            // Botón GUARDAR
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Guardar Venta'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                onPressed: () async {
                  if (saleP.selectedClientId == null ||
                      saleP.selectedProductId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Selecciona cliente y producto'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  await saleP.save();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Venta guardada localmente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 32),
            const Text(
              'Listado de Ventas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Lista
            saleP.isLoading
                ? const CircularProgressIndicator()
                : Expanded(
              child: ListView.builder(
                itemCount: saleP.sales.length,
                itemBuilder: (ctx, i) {
                  final s = saleP.sales[i];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        s.isSynced
                            ? Icons.cloud_done
                            : Icons.cloud_upload,
                        color: s.isSynced
                            ? Colors.green
                            : Colors.orange,
                      ),
                      title: Text(
                        '${s.customerName ?? 'Cliente'} — ${s.productName ?? 'Producto'}',
                      ),
                      subtitle: Text(
                        'Cantidad: ${s.quantity}  •  ${s.date ?? ''}',
                      ),
                      trailing: Text(
                        'S/ ${s.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}