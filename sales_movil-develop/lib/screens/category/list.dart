import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sales/providers/category_provider.dart';
import 'package:sales/screens/category/detail.dart';
import 'package:sales/screens/category/form.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryProvider>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<CategoryProvider>().categories;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Categorías",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CategoryFormScreen()),
          );
          context.read<CategoryProvider>().loadAll();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: categories.isEmpty
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.category, color: Colors.orange),
              ),
              title: Text(cat.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text(cat.description,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
              trailing: const Icon(Icons.chevron_right, color: Colors.orange),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryDetailScreen(idCategory: cat.id),
                  ),
                );
                context.read<CategoryProvider>().loadAll();
              },
            ),
          );
        },
      ),
    );
  }
}