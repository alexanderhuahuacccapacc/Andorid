class Sale {
  final int id;
  final int customerId;
  final int productId;
  final int quantity;        // ← NUEVO
  final String? date;
  final double total;
  final String? customerName;
  final String? productName;
  final bool isSynced;
  final int? serverId;

  Sale(this.id, this.customerId, this.productId, this.quantity, this.total,
      {this.date, this.customerName, this.productName,
        this.isSynced = false, this.serverId});

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      map['id'],
      map['customer_id'],
      map['product_id'],
      map['quantity'] ?? 1,         // ← NUEVO
      double.parse(map['total'].toString()),
      date: map['date'],
      customerName: map['customer_name'],
      productName: map['product_name'],
      isSynced: map['is_synced'] == 1,
      serverId: map['server_id'] as int?,
    );
  }

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      json['id'] ?? 0,
      json['customer'],
      json['product'],
      json['quantity'] ?? 1,        // ← NUEVO
      double.parse(json['total'].toString()),
      date: json['date'],
      customerName: json['customer_name'],
      productName: json['product_name'],
      isSynced: true,
      serverId: json['id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'customer_id': customerId,
      'product_id': productId,
      'quantity': quantity,         // ← NUEVO
      'total': total,
      'date': date,
      'customer_name': customerName,
      'product_name': productName,
      'is_synced': isSynced ? 1 : 0,
      'server_id': serverId,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'customer': customerId,
      'product': productId,
      'quantity': quantity,         // ← NUEVO
      'total': total,
    };
  }
}