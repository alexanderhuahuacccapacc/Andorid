import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/providers/sale_provider.dart';
import 'package:sales/providers/client_provider.dart';
import 'package:sales/providers/product_provider.dart';

class SaleFormScreen extends StatefulWidget {
  const SaleFormScreen({super.key});
  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ClientProvider>().loadAll();
      context.read<ProductProvider>().loadAll();
      context.read<SaleProvider>().clearCart();
    });
  }

  Future<void> _confirm() async {
    setState(() => _loading = true);
    try {
      await context.read<SaleProvider>().confirmSale();
      await context.read<SaleProvider>().sincronizar();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()))
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final saleProv    = context.watch<SaleProvider>();
    final clientProv  = context.watch<ClientProvider>();
    final productProv = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva venta'),
        backgroundColor: Colors.green,
      ),
      body: Column(children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Cliente',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: saleProv.selectedClientId,
                hint: const Text('Selecciona un cliente'),
                items: clientProv.clients.map((c) =>
                    DropdownMenuItem<int>(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (int? v) {
                  if (v != null) {
                    final client = clientProv.clients.firstWhere((c) => c.id == v);
                    saleProv.setClient(v, client.name);
                  }
                },
                decoration: const InputDecoration(
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),

              const Text('Productos',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: productProv.products.map((p) =>
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 16),
                      label: Text('${p.name} S/${p.price.toStringAsFixed(2)}'),
                      onPressed: () => saleProv.addProduct(p),
                    )).toList(),
              ),
              const SizedBox(height: 20),

              if (saleProv.cart.isNotEmpty) ...[
                const Text('Carrito',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...saleProv.cart.map((item) => Card(
                  child: ListTile(
                    title: Text(item.product.name),
                    subtitle: Text(
                        'S/ ${item.subtotal.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => saleProv
                              .updateQty(item.product.id, item.quantity - 1),
                        ),
                        Text('${item.quantity}',
                            style: const TextStyle(fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => saleProv
                              .updateQty(item.product.id, item.quantity + 1),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () =>
                              saleProv.removeProduct(item.product.id),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8, offset: const Offset(0, -2))],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Subtotal'),
                  Text('S/ ${saleProv.cartSubtotal.toStringAsFixed(2)}'),
                ]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('IGV (18%)'),
                  Text('S/ ${saleProv.cartIgv.toStringAsFixed(2)}'),
                ]),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total',
                      style: TextStyle(fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  Text('S/ ${saleProv.cartTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16, color: Colors.green)),
                ]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: _loading ? null : _confirm,
                child: _loading
                    ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : const Text('Confirmar venta',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}