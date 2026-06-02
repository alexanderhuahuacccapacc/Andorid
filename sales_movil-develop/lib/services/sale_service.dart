import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:sales/config/app_config.dart';
import 'package:sales/models/sale.dart';

class SaleService {
  final String apiUrl = AppConfig.apiUrl;

  Future<List<Sale>> all() async {
    var url = Uri.http(apiUrl, '/sale/sales/');
    var res = await http.get(url);
    if (res.statusCode == 200) {
      final list = convert.jsonDecode(res.body) as List;
      return list.map((e) => Sale.fromJson(e)).toList();
    }
    throw Exception('Error al cargar ventas');
  }

  Future<Sale> getById(int id) async {
    var url = Uri.http(apiUrl, '/sale/sales/$id/');
    var res = await http.get(url);
    if (res.statusCode == 200) {
      return Sale.fromJson(convert.jsonDecode(res.body));
    }
    throw Exception('Error al cargar venta');
  }

  Future<int> save(Sale sale) async {
    var url = Uri.http(apiUrl, '/sale/sales/');
    var res = await http.post(
      url,
      body:    convert.jsonEncode(sale.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (res.statusCode != 201) {
      throw Exception('Error al guardar venta: ${res.body}');
    }
    final body = convert.jsonDecode(res.body) as Map<String, dynamic>;
    return body['id'] as int;
  }

  Future<void> delete(int id) async {
    var url = Uri.http(apiUrl, '/sale/sales/$id/');
    var res = await http.delete(url);
    if (res.statusCode != 204) {
      throw Exception('Error al eliminar venta');
    }
  }
}