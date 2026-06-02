import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:sales/config/app_config.dart';
import 'package:sales/models/supplier.dart';

enum SyncResult { created, updated, duplicate, error }

class SupplierService {
  final String apiUrl = AppConfig.apiUrl;

  // GET /supplier/suppliers/
  Future<List<Supplier>> all() async {
    var url = Uri.http(apiUrl, '/supplier/suppliers/');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body) as List<dynamic>;
      return jsonResponse.map((e) => Supplier.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar suppliers');
    }
  }

  // GET /supplier/suppliers/:id/
  Future<Supplier> getById(int id) async {
    var url = Uri.http(apiUrl, '/supplier/suppliers/$id/');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      return Supplier.fromJson(convert.jsonDecode(response.body));
    } else {
      throw Exception('Error al cargar supplier');
    }
  }

  // POST /supplier/suppliers/
  Future<(SyncResult, int?)> save(Supplier supplier) async {
    var url = Uri.http(apiUrl, '/supplier/suppliers/');
    var response = await http.post(
      url,
      body: convert.jsonEncode(supplier.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 201) {
      final json = convert.jsonDecode(response.body);
      return (SyncResult.created, json['id'] as int);
    }
    if (response.statusCode == 400) {
      return (SyncResult.duplicate, null);
    }
    return (SyncResult.error, null);
  }

  // PUT /supplier/suppliers/:id/
  Future<SyncResult> edit(Supplier supplier) async {
    var url = Uri.http(apiUrl, '/supplier/suppliers/${supplier.serverId}/');
    var response = await http.put(
      url,
      body: convert.jsonEncode(supplier.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) return SyncResult.updated;
    return SyncResult.error;
  }

  // DELETE /supplier/suppliers/:id/
  Future<void> delete(int serverId) async {
    var url = Uri.http(apiUrl, '/supplier/suppliers/$serverId/');
    var response = await http.delete(url);
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar supplier');
    }
  }
}