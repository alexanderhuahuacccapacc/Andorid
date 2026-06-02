import 'package:flutter/material.dart';
import 'package:sales/database/database_helper.dart';
import 'package:sales/models/sale.dart';
import 'package:sales/models/product.dart';
import 'package:sales/services/sale_service.dart';

const String _tableName = 'sales';

// ─── Item temporal mientras el usuario arma la venta ──────────
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;

  SaleDetail toDetail() => SaleDetail(
    id:          0,
    productId:   product.id,
    productName: product.name,
    quantity:    quantity,
    price:       product.price,
    subtotal:    subtotal,
  );
}

class SaleProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final SaleService _saleService = SaleService();

  List<Sale> _sales = [];
  List<Sale> get sales => _sales;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CartItem> _cart = [];
  List<CartItem> get cart => _cart;

  int?    _selectedClientId;
  String? _selectedClientName;
  int?    get selectedClientId => _selectedClientId;

  double get cartSubtotal => _cart.fold(0, (sum, i) => sum + i.subtotal);
  double get cartIgv      => cartSubtotal * 0.18;
  double get cartTotal    => cartSubtotal + cartIgv;

  // ─────────────────────────────────────────────────────────────
  // Carga de datos desde DB local
  // ─────────────────────────────────────────────────────────────
  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      // getAllSalesWithDetails() ya devuelve mapas mutables (fix en database_helper)
      final rows = await _db.getAllSalesWithDetails();
      _sales = rows.map((row) => Sale.fromMap(row)).toList();
    } catch (e) {
      print('Error loading sales: $e');
      _sales = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─────────────────────────────────────────────────────────────
  // Carrito
  // ─────────────────────────────────────────────────────────────
  void setClient(int clientId, String clientName) {
    _selectedClientId   = clientId;
    _selectedClientName = clientName;
    notifyListeners();
  }

  void addProduct(Product product) {
    final idx = _cart.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      _cart[idx].quantity++;
    } else {
      _cart.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeProduct(int productId) {
    _cart.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void updateQty(int productId, int qty) {
    final idx = _cart.indexWhere((i) => i.product.id == productId);
    if (idx >= 0) {
      if (qty <= 0) {
        _cart.removeAt(idx);
      } else {
        _cart[idx].quantity = qty;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _cart               = [];
    _selectedClientId   = null;
    _selectedClientName = null;
    notifyListeners();
  }

  Future<void> confirmSale() async {
    if (_selectedClientId == null || _cart.isEmpty) {
      throw Exception('Selecciona un cliente y al menos un producto');
    }

    final now = DateTime.now().toIso8601String();

    final Map<String, dynamic> saleRow = {
      'client_id':   _selectedClientId,
      'client_name': _selectedClientName,
      'subtotal':    cartSubtotal,
      'igv':         cartIgv,
      'total':       cartTotal,
      'date':        now,
      'is_synced':   0,
      'server_id':   null,
    };

    final List<Map<String, dynamic>> detailsRows = _cart.map((item) => {
      'product_id':   item.product.id,
      'product_name': item.product.name,
      'quantity':     item.quantity,
      'price':        item.product.price,
      'subtotal':     item.subtotal,
    }).toList();

    await _db.insertSaleWithDetails(saleRow, detailsRows);
    clearCart();
    await loadAll();
  }

  Future<void> delete(int id) async {
    await _db.deleteSaleWithDetails(id);
    await loadAll();
  }

  Future<Map<String, int>> sincronizar() async {
    final pendingRows = await _db.queryPending(_tableName);
    int sincronizados = 0;
    int errores       = 0;

    for (final row in pendingRows) {
      try {
        final saleWithDetails = await _db.getSaleWithDetails(row['id']);
        if (saleWithDetails != null) {
          final sale = Sale.fromMap(saleWithDetails);
          final serverId = await _saleService.save(sale);
          await _db.updateSynced(_tableName, sale.id, serverId);
          sincronizados++;
        }
      } catch (e) {
        print('Error syncing sale ${row['id']}: $e');
        errores++;
      }
    }

    await loadAll();

    return {
      'sincronizados': sincronizados,
      'actualizados':  0,
      'duplicados':    0,
      'errores':       errores,
    };
  }
}