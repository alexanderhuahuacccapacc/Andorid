import 'package:flutter/material.dart';
import 'package:sales/database/database_helper.dart';
import 'package:sales/models/sale.dart';
import 'package:sales/services/sale_service.dart';

class SaleProvider extends ChangeNotifier {
  List<Sale> _sales = [];
  List<Sale> get sales => _sales;
  int quantity = 1;
  double unitPrice = 0;
  final DatabaseHelper _db = DatabaseHelper();
  final SaleService _service = SaleService();
  final String _tableName = 'sales';

  bool isLoading = false;
  int? selectedClientId;
  String? selectedClientName;
  int? selectedProductId;
  String? selectedProductName;
  double total = 0;

  void selectClient(int? id, String name) {
    selectedClientId = id;
    selectedClientName = name;
    notifyListeners();
  }

  void selectProduct(int? id, String name, double price) {
    selectedProductId = id;
    selectedProductName = name;
    unitPrice = price;            // ← guarda precio unitario
    total = price * quantity;     // ← total = precio x cantidad
    notifyListeners();
  }
  void updateQuantity(int qty) {
    quantity = qty < 1 ? 1 : qty;
    total = unitPrice * quantity; // ← recalcula total
    notifyListeners();
  }

  // ── CRUD local SQLite ──────────────────────────────────────

  Future<void> loadAll() async {
    final rows = await _db.queryAll(_tableName);
    _sales = rows.map((row) => Sale.fromMap(row)).toList();
    notifyListeners();
  }

  Future<void> save() async {
    if (selectedClientId == null || selectedProductId == null) return;

    final sale = Sale(
      0,
      selectedClientId!,
      selectedProductId!,
      quantity,                   // ← NUEVO
      total,
      customerName: selectedClientName,
      productName: selectedProductName,
      isSynced: false,
    );

    await _db.insert(_tableName, sale.toMap());

    // Limpia selección
    selectedClientId = null;
    selectedClientName = null;
    selectedProductId = null;
    selectedProductName = null;
    quantity = 1;                 // ← resetea cantidad
    unitPrice = 0;
    total = 0;

    await loadAll();
  }

  Future<void> delete(Sale sale) async {
    if (sale.isSynced && sale.serverId != null) {
      await _service.delete(sale.serverId!);
    }
    await _db.delete(_tableName, sale.id);
    await loadAll();
  }

  // ── Sincronización ─────────────────────────────────────────

  Future<Map<String, int>> sincronizar() async {
    final rows = await _db.queryPending(_tableName);
    final pending = rows.map((row) => Sale.fromMap(row)).toList();

    int sincronizados = 0;
    int actualizados = 0;
    int duplicados = 0;
    int errores = 0;

    for (final sale in pending) {
      if (sale.serverId == null) {
        // Es nueva — enviar al servidor
        final (result, serverId) = await _service.save(sale);
        if (result == SyncResult.created && serverId != null) {
          await _db.updateSynced(_tableName, sale.id, serverId);
          sincronizados++;
        } else if (result == SyncResult.duplicate) {
          duplicados++;
        } else {
          errores++;
        }
      } else {
        // Ya existe en servidor — actualizar
        final result = await _service.edit(sale);
        if (result == SyncResult.updated) {
          await _db.updateSyncedOnly(_tableName, sale.id);
          actualizados++;
        } else {
          errores++;
        }
      }
    }

    await loadAll();
    return {
      'sincronizados': sincronizados,
      'actualizados': actualizados,
      'duplicados': duplicados,
      'errores': errores,
    };
  }

}