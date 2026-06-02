import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/providers/product_provider.dart';
import 'package:sales/screens/product/detail.dart';
import 'package:sales/screens/product/form.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductProvider>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().products;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          "Productos",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductFormScreen()),
          );
          context.read<ProductProvider>().loadAll();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.inventory_2, color: Colors.blue),
              ),
              title: Text(
                product.name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.category.name,
                          style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "S/. ${product.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.blue),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProductDetailScreen(idProduct: product.id),
                  ),
                );
                context.read<ProductProvider>().loadAll();
              },
            ),
          );
        },
      ),
    );
  }
}