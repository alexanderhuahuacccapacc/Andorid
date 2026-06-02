import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/models/product.dart';
import 'package:sales/providers/category_provider.dart';
import 'package:sales/providers/product_provider.dart';
import '../../models/category.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerDescription = TextEditingController();
  TextEditingController controllerPrice = TextEditingController();
  Category? selectedCategory;

  @override
  void initState() {
    super.initState();
    context.read<CategoryProvider>().loadAll();

    final product = widget.product;
    if (product != null) {
      controllerName.text = product.name;
      controllerDescription.text = product.description;
      controllerPrice.text = product.price.toString();
    }
  }

  // ✅ Se ejecuta cada vez que un provider cambia (incluye cuando llegan las categorías)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final categories = context.read<CategoryProvider>().categories;

    if (categories.isNotEmpty && selectedCategory == null) {
      setState(() {
        if (widget.product != null) {
          selectedCategory = categories.firstWhere(
                (cat) => cat.id == widget.product!.category.id,
            orElse: () => categories.first,
          );
        } else {
          selectedCategory = categories.first;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? "Nuevo Producto" : "Editar Producto"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            categories.isEmpty || selectedCategory == null
                ? const CircularProgressIndicator()
                : DropdownButton<Category>(
              value: selectedCategory,
              items: categories
                  .map((cat) => DropdownMenuItem(
                value: cat,
                child: Text(cat.name),
              ))
                  .toList(),
              onChanged: (cat) => setState(() => selectedCategory = cat),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controllerName,
              decoration: const InputDecoration(
                labelText: "Nombre",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controllerPrice,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Precio",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controllerDescription,
              decoration: const InputDecoration(
                labelText: "Descripción",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (widget.product == null) {
                  await context.read<ProductProvider>().save(
                    Product(0, controllerName.text,
                        double.parse(controllerPrice.text),
                        controllerDescription.text, selectedCategory!),
                  );
                } else {
                  await context.read<ProductProvider>().edit(
                    widget.product!.id,
                    Product(widget.product!.id, controllerName.text,
                        double.parse(controllerPrice.text),
                        controllerDescription.text, selectedCategory!),
                  );
                }
                Navigator.pop(context);
              },
              child: Text(widget.product == null ? "Crear" : "Editar"),
            ),
          ],
        ),
      ),
    );
  }
}