import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:sales/config/app_config.dart';
import 'package:sales/models/sale.dart';

enum SyncResult { created, updated, duplicate, error }

class SaleService {
  final String apiUrl = AppConfig.apiUrl;

  Future<List<Sale>> all() async {
    var url = Uri.http(apiUrl, '/sale/sales/');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body) as List<dynamic>;
      return jsonResponse.map((e) => Sale.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar ventas');
    }
  }

  Future<(SyncResult, int?)> save(Sale sale) async {
    var url = Uri.http(apiUrl, '/sale/sales/');
    var response = await http.post(
      url,
      body: convert.jsonEncode(sale.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 201) {
      final json = convert.jsonDecode(response.body);
      return (SyncResult.created, json['id'] as int);
    } else if (response.statusCode == 400) {
      return (SyncResult.duplicate, null);
    } else {
      return (SyncResult.error, null);
    }
  }

  Future<SyncResult> edit(Sale sale) async {
    var url = Uri.http(apiUrl, '/sale/sales/${sale.serverId}/');
    var response = await http.put(
      url,
      body: convert.jsonEncode(sale.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return SyncResult.updated;
    } else {
      return SyncResult.error;
    }
  }

  Future<void> delete(int serverId) async {
    var url = Uri.http(apiUrl, '/sale/sales/$serverId/');
    var response = await http.delete(url);
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar venta');
    }
  }
}