import 'package:flutter/cupertino.dart';

import '../database/database_helper.dart';
import '../models/supplier.dart';
import '../services/supplier_service.dart';

class SupplierProvider extends ChangeNotifier {
  List<Supplier> _suppliers = [];
  List<Supplier> get suppliers => _suppliers;
  final DatabaseHelper _db = DatabaseHelper();
  final SupplierService _service = SupplierService();
  final String _tableName = 'suppliers'; // Solo definimos la tabla aquí

  Future<void> loadAll() async {
    final rows = await _db.queryAll(_tableName); // Mismo método
    _suppliers = rows.map((row) => Supplier.fromMap(row)).toList();
    notifyListeners();
  }

  Future<void> save(Supplier supplier) async {
    await _db.insert(_tableName, supplier.toMap()); // Mismo método
    await loadAll();
  }

  Future<void> edit(int id, Supplier supplier) async {
    await _db.update(_tableName, id, { // Mismo método
      'name': supplier.name,
      'document_number': supplier.documentNumber,
      'email': supplier.email,
      'phone': supplier.phone,
      'address': supplier.address,
      'is_synced': 0,
      'server_id': supplier.serverId,
    });
    await loadAll();
  }

  Future<void> delete(Supplier supplier) async {
    if (supplier.isSynced && supplier.serverId != null) {
      await _service.delete(supplier.serverId!);
    }
    await _db.delete(_tableName, supplier.id); // Mismo método
    await loadAll();
  }

  Future<Map<String, int>> sincronizar() async {
    final rows = await _db.queryPending(_tableName); // Mismo método
    final pending = rows.map((row) => Supplier.fromMap(row)).toList();
    int sincronizados = 0;
    int actualizados = 0;
    int duplicados = 0;
    int errores = 0;

    for (final supplier in pending) {
      if (supplier.serverId == null) {
        final (result, serverId) = await _service.save(supplier);
        if (result == SyncResult.created && serverId != null) {
          await _db.updateSynced(_tableName, supplier.id, serverId); // Mismo método
          sincronizados++;
        } else if (result == SyncResult.duplicate) {
          duplicados++;
        } else {
          errores++;
        }
      } else {
        final result = await _service.edit(supplier);
        if (result == SyncResult.updated) {
          await _db.updateSyncedOnly(_tableName, supplier.id); // Mismo método
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