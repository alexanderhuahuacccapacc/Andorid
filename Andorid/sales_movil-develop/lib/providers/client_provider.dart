import 'package:flutter/material.dart';
import 'package:sales/database/database_helper.dart';
import 'package:sales/models/client.dart';
import 'package:sales/services/client_service.dart';

class ClientProvider extends ChangeNotifier {
  List<Client> _clients = [];
  List<Client> get clients => _clients;
  final DatabaseHelper _db = DatabaseHelper();
  final ClientService _service = ClientService();
  final String _tableName = 'clients';

  Future<void> loadAll() async {
    final rows = await _db.queryAll(_tableName);
    _clients = rows.map((row) => Client.fromMap(row)).toList();
    notifyListeners();
  }

  Future<void> save(Client client) async {
    await _db.insert(_tableName, client.toMap());
    await loadAll();
  }

  Future<void> edit(int id, Client client) async {
    await _db.update(_tableName, id, {
      'name': client.name,
      'document_number': client.documentNumber,
      'is_synced': 0,
      'server_id': client.serverId,
    });
    await loadAll();
  }

  Future<void> delete(Client client) async {
    if (client.isSynced && client.serverId != null) {
      await _service.delete(client.serverId!);
    }
    await _db.delete(_tableName, client.id);
    await loadAll();
  }

  Future<Map<String, int>> sincronizar() async {
    final rows = await _db.queryPending(_tableName);
    final pending = rows.map((row) => Client.fromMap(row)).toList();
    int sincronizados = 0;
    int actualizados = 0;
    int duplicados = 0;
    int errores = 0;

    for (final client in pending) {
      if (client.serverId == null) {
        final (result, serverId) = await _service.save(client);
        if (result == SyncResult.created && serverId != null) {
          await _db.updateSynced(_tableName, client.id, serverId);
          sincronizados++;
        } else if (result == SyncResult.duplicate) {
          duplicados++;
        } else {
          errores++;
        }
      } else {
        final result = await _service.edit(client);
        if (result == SyncResult.updated) {
          await _db.updateSyncedOnly(_tableName, client.id);
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